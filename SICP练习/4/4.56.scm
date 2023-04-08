#lang sicp

(and (supervisor ?person (Bitdiddle Ben))
     (address ?person ?where))
(or (salary (Bigdiddle Ben) ?amount)
     (lisp-value < salary ?amount))
(and (supervisor ?person ?boss)
     (not (job ?boss (computer . ?type)))
     (job ?boss ?job))