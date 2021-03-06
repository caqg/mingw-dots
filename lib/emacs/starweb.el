;;;; -*- Mode: Emacs-Lisp -*-

;;;; Support for Starweb playing

(provide 'starweb)

(defvar starweb-mode-map (copy-keymap text-mode-map))
(defvar starweb-mode-abbrev-table nil)
(defvar starweb-mode-hook nil)
(defvar starweb-mode-syntax-table (copy-syntax-table text-mode-syntax-table))

(define-abbrev-table 'starweb-mode-abbrev-table
  '(("a" "A" nil 0)
    ("cmw" "CMW" nil 0)
    ("faf" "FAF" nil 0)
    ("fah" "FAH" nil 0)
    ("fai" "FAI" nil 0)
    ("fap" "FAP" nil 0)
    ("fb" "FB" nil 0)
    ("fcf" "FCF" nil 0)
    ("fch" "FCH" nil 0)
    ("fcp" "FCP" nil 0)
    ("fd" "FD" nil 0)
    ("fg" "FG" nil 0)
    ("fhi" "FHI" nil 0)
    ("fj" "FJ" nil 0)
    ("fl" "FL" nil 0)
    ("fn" "FN" nil 0)
    ("fp" "FP" nil 0)
    ("fq" "FQ" nil 0)
    ("fr" "FR" nil 0)
    ("ftf" "FTF" nil 0)
    ("fti" "FTI" nil 0)
    ("ftp" "FTP" nil 0)
    ("fu" "FU" nil 0)
    ("fw" "FW" nil 0)
    ("fww" "FWW" nil 0)
    ("fwww" "FWWW" nil 0)
    ("fx" "FX" nil 0)
    ("iac" "IAC" nil 0)
    ("iaf" "IAF" nil 0)
    ("icc" "ICC" nil 0)
    ("icf" "ICF" nil 0)
    ("ip" "IP" nil 0)
    ("itf" "ITF" nil 0)
    ("itp" "ITP" nil 0)
    ("j" "J" nil 0)
    ("l" "L" nil 0)
    ("n" "N" nil 0)
    ("pac" "PAC" nil 0)
    ("paf" "PAF" nil 0)
    ("pcc" "PCC" nil 0)
    ("pcf" "PCF" nil 0)
    ("pmw" "PMW" nil 0)
    ("pp" "PP" nil 0)
    ("ptf" "PTF" nil 0)
    ("pti" "PTI" nil 0)
    ("vf" "VF" nil 0)
    ("vw" "VW" nil 0)
    ("wbf" "WBF" nil 0)
    ("wbi" "WBI" nil 0)
    ("wbp" "WBP" nil 0)
    ("wg" "WG" nil 0)
    ("wii" "WII" nil 0)
    ("wil" "WIL" nil 0)
    ("wir" "WIR" nil 0)
    ("ws" "WS" nil 0)
    ("wx" "WX" nil 0)
    ("x" "X" nil 0)
    ("z" "Z" nil 0)))

(defun starweb-syntax ()
  (interactive)
  (auto-fill-mode 0)
  (modify-syntax-entry ?\; "<   " starweb-mode-syntax-table)
  (local-set-key "\t" 'self-insert-command)
  (local-set-key "\C-z\C-w" 'linearize-world)
  (local-set-key "\C-z\C-r" 'linearize-region)
  (lsetq comment-start		";"
         comment-start-skip     ";+ *"
         comment-end		""
         comment-column		32))

(defun starweb-mode ()
  "Support for Starweb.  A descendant of text-mode.

\\{starweb-mode-map}

FP	fleet world             expend a ship from the fleet
IP	from to                 expend an Iship
PP	from to                 expend a Pship

CMW	from pop to             migrate converts
PMW	from pop to             migrate regular people (or robots)

FW	fleet world             direct motion
FWW	fleet world world       one-stop motion
FWWW	fleet world world world two-stops motion

FTF	from num-ships to       fleet-to-fleet
FTI	from num-ships          fleet-to-Iships
FTP	from num-ships          fleet-to-Pships
ITF	world num-ships to      Iships-to-fleet
ITP	world num-ships         Iships-to-Pships
PTF	world num-ships to      Pships-to-fleet
PTI	world num-ships         Pships-to-Iships

FJ	fleet num-RM            jettison (destroy) raw materials
FL	fleet [num-RM]          load raw materials (default maximum possible)
FN	fleet num-RM            unload RMs as consumer goods
FU	fleet num-RM            unload raw materials

VF	artifact to             attach it to the fleet
VW	artifact                attach it to the world it is currently at

WBF	world num-ships fleet   build ships onto fleet (each costs 1 IA)
WBI	world num-ships         build Iships (each costs 1 IA)
WBP	world num-ships         build Pships (each costs 1 IA)

WII	world num-new-industry  build industry (each costs 5 IA)
WIL	world increment         raise population limit (each costs 5 IA)
WIR	world num-IA            build robots (2 per IA used)
WS	world num-new-industry  build industry (each costs 6 Iships)

FB	fleet                   build a Planet Busting Bomb (costs 25 ships)

FAF	from at                 fire from -> at
FAH	fleet                   fire at home fleet and drive neutral
FAI	fleet                   fire the fleet at Iships then industry
FAP	fleet                   fire the fleet at Pships then population
FCF	from at                 conditional FAF
FCH	fleet   		conditional FAH
FCP     fleet                   conditional FAP
FD	fleet                   drop the Planet Busting Bomb!
FHI     fleet                   conditional FAI
FR	fleet num-ships         make a robot attack (2 ships -> 1robot)
IAC	world                   fire Iships at converts
IAF	world fleet             fire Iships at the fleet
ICC     world                   conditional IAC
ICF     world fleet             conditional IAF
PAC	world                   fire Pships at converts
PAF	world fleet             fire Pships at the fleet
PCC     world                   conditional PAC
PCF     world fleet             conditional PAF

WX	world                   plunder the world

A	player                  declare your alliance with the player
J	player                  declare a Jihad against the player
L	player                  allow the player to load RMs from your worlds
N	player                  un-declare your alliance with the player
X	player                  player is no longer a loader
Z	world [player]          don't ambush [player] at the world this turn.

FG	fleet player            give the fleet to the player
WG	world player            give the world to the player

FQ	fleet                   put the fleet at peace
FX	fleet                   make the fleet no longer at peace
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map starweb-mode-map)
  (setq local-abbrev-table starweb-mode-abbrev-table)
  (abbrev-mode 1)
  (set-syntax-table starweb-mode-syntax-table)
  (starweb-syntax)
  (setq mode-name "Starweb Orders"
        major-mode 'starweb-mode)
  (run-hooks 'starweb-mode-hook))

(fset 'linearize-world
   "^W n<R


R  *
 
R ,
,
R \\(F[0-9]+\\[\\)

	\\1
<R <A

		<A
>w")

(defun linearize-region (p1 p2)
  "Setup planets in a linear fashion"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region p1 p2)
      (goto-char p1)
      (replace-string "*" "@")
      (goto-char p1)
      (execute-kbd-macro 'linearize-world 0))))

;;;; end of starweb.el
