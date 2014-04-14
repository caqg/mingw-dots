;;;; -*- Mode: lisp; indent-tabs-mode: nil -*-
;;;
;;; swank-gray.lisp --- Gray stream based IO redirection.
;;;
;;; Created 2003
;;;
;;; This code has been placed in the Public Domain.  All warranties
;;; are disclaimed.
;;;

(in-package :swank-backend)

(defclass slime-output-stream (fundamental-character-output-stream)
  ((output-fn :initarg :output-fn)
   (buffer :initform (make-string 8000))
   (fill-pointer :initform 0)
   (column :initform 0)
   (lock :initform (make-lock :name "buffer write lock"))))

(defmacro with-slime-output-stream (stream &body body)
  `(with-slots (lock output-fn buffer fill-pointer column) ,stream
     (call-with-lock-held lock (lambda () ,@body))))

(defmethod stream-write-char ((stream slime-output-stream) char)
  (with-slime-output-stream stream
    (setf (schar buffer fill-pointer) char)
    (incf fill-pointer)
    (incf column)
    (when (char= #\newline char)
      (setf column 0))
    (when (= fill-pointer (length buffer))
      (finish-output stream)))
  char)

(defmethod stream-write-string ((stream slime-output-stream) string
                                &optional start end)
  (with-slime-output-stream stream
    (let* ((start (or start 0))
           (end (or end (length string)))
           (len (length buffer))
           (count (- end start))
           (free (- len fill-pointer)))
      (when (>= count free)
        (stream-finish-output stream))
      (cond ((< count len)
             (replace buffer string :start1 fill-pointer
                      :start2 start :end2 end)
             (incf fill-pointer count))
            (t
             (funcall output-fn (subseq string start end))))
      (let ((last-newline (position #\newline string :from-end t
                                    :start start :end end)))
        (setf column (if last-newline 
                         (- end last-newline 1)
                         (+ column count))))))
  string)
              
(defmethod stream-line-column ((stream slime-output-stream))
  (with-slime-output-stream stream column))

(defmethod stream-line-length ((stream slime-output-stream))
  75)

(defmethod stream-finish-output ((stream slime-output-stream))
  (with-slime-output-stream stream 
    (unless (zerop fill-pointer)
      (funcall output-fn (subseq buffer 0 fill-pointer))
      (setf fill-pointer 0)))
  nil)

(defmethod stream-force-output ((stream slime-output-stream))
  (stream-finish-output stream))

(defmethod stream-fresh-line ((stream slime-output-stream))
  (with-slime-output-stream stream
    (cond ((zerop column) nil)
          (t (terpri stream) t))))

(defclass slime-input-stream (fundamental-character-input-stream)
  ((input-fn :initarg :input-fn)
   (buffer :initform "") (index :initform 0)
   (lock :initform (make-lock :name "buffer read lock"))))

(defmethod stream-read-char ((s slime-input-stream))
  (call-with-lock-held
   (slot-value s 'lock)
   (lambda ()
     (with-slots (buffer index input-fn) s
       (when (= index (length buffer))
         (let ((string (funcall input-fn)))
           (cond ((zerop (length string))
                  (return-from stream-read-char :eof))
                 (t
                  (setf buffer string)
                  (setf index 0)))))
       (assert (plusp (length buffer)))
       (prog1 (aref buffer index) (incf index))))))

(defmethod stream-listen ((s slime-input-stream))
  (call-with-lock-held
   (slot-value s 'lock)
   (lambda ()
     (with-slots (buffer index) s
       (< index (length buffer))))))

(defmethod stream-unread-char ((s slime-input-stream) char)
  (call-with-lock-held
   (slot-value s 'lock)
   (lambda ()
     (with-slots (buffer index) s
       (decf index)
       (cond ((eql (aref buffer index) char)
              (setf (aref buffer index) char))
             (t
              (warn "stream-unread-char: ignoring ~S (expected ~S)"
                    char (aref buffer index)))))))
  nil)

(defmethod stream-clear-input ((s slime-input-stream))
  (call-with-lock-held
   (slot-value s 'lock)
   (lambda ()
     (with-slots (buffer index) s 
       (setf buffer ""  
             index 0))))
  nil)

(defmethod stream-line-column ((s slime-input-stream))
  nil)

(defmethod stream-line-length ((s slime-input-stream))
  75)


;;; CLISP extensions

;; We have to define an additional method for the sake of the C
;; function listen_char (see src/stream.d), on which SYS::READ-FORM
;; depends.

;; We could make do with either of the two methods below.

(defmethod stream-read-char-no-hang ((s slime-input-stream))
  (call-with-lock-held
   (slot-value s 'lock)
   (lambda ()
     (with-slots (buffer index) s
       (when (< index (length buffer))
         (prog1 (aref buffer index) (incf index)))))))

;; This CLISP extension is what listen_char actually calls.  The
;; default method would call STREAM-READ-CHAR-NO-HANG, so it is a bit
;; more efficient to define it directly.

(defmethod stream-read-char-will-hang-p ((s slime-input-stream))
  (with-slots (buffer index) s
    (= index (length buffer))))


;;;

(defimplementation make-output-stream (write-string)
  (make-instance 'slime-output-stream :output-fn write-string))

(defimplementation make-input-stream (read-string)
  (make-instance 'slime-input-stream :input-fn read-string))
