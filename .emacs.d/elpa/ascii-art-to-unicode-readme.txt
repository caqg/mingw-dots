The command `aa2u' converts simple ASCII art line drawings in
the {active,accessible} region of the current buffer to Unicode.

Example use case:
- M-x artist-mode RET
- C-c C-a r               ; artist-select-op-rectangle
- (draw two rectangles)

  +---------------+
  |               |
  |       +-------+--+
  |       |       |  |
  |       |       |  |
  |       |       |  |
  +-------+-------+  |
          |          |
          |          |
          |          |
          +----------+

- C-c C-c                 ; artist-mode-off (optional)
- C-x n n                 ; narrow-to-region
- M-x aa2u RET

  ┌───────────────┐
  │               │
  │       ┌───────┼──┐
  │       │       │  │
  │       │       │  │
  │       │       │  │
  └───────┼───────┘  │
          │          │
          │          │
          │          │
          └──────────┘

TODO:
- Add phase 0, to grok and lock label (as opposed to line) text.
- Add interactive mode, to choose per-line light vs heavy.
- Improve neighbor-determining heuristic.
- Choose plus-replacement by composing "VERTICAL", "LEFT", etc.
