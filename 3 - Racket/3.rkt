#lang racket

;; This was pretty fun. Interleaving the tests is probably wrong from a readability point of view but
;; for iterating through a file on a puzzle it's very pleasant.


(require rackunit)

(define input-txt (file->lines "input.txt"))

(define input-char-array (map (lambda (in-list) (map char->integer in-list)) (map string->list input-txt)))

(define input
  (map (lambda (in-list)
         (map (lambda (chr)
                (if (= chr 48) 0 1))
              in-list)) input-char-array))

(define (count-ones binary-lists) (foldl (lambda (next totals) (map (lambda (t n) (+ t (if (= n 1) 1 -1))) totals next))
                                         (map (lambda (a) 0) (range (length (car binary-lists))))
                                         binary-lists))

(check-equal? (count-ones '(
              (1 0 0 0 0 1 1 1 1 0 1 1)
              )) '(1 -1 -1 -1 -1 1 1 1 1 -1 1 1))

(check-equal? (count-ones '(
              (1 0 0 0 0 1 1 1 1 0 1 1)
              (0 0 0 0 0 1 1 1 1 0 1 1)
              )) '(0 -2 -2 -2 -2 2 2 2 2 -2 2 2))


(define (calculate-gamma count-list) (map (lambda (count) (if (< count 0) 0 1)) count-list))
(define (calculate-epsilon count-list) (map (lambda (count) (if (< count 0) 1 0)) count-list))

(check-equal? (calculate-gamma '(1 -5 3)) '(1 0 1))
(check-equal? (calculate-epsilon '(1 -5 3)) '(0 1 0))

(check-equal? (calculate-gamma (count-ones '(
              (0 0 0 0 0 1 1 1 1 0 1 1)
              (1 0 0 0 0 1 1 1 1 0 1 1)
              (1 0 0 0 0 1 1 1 1 0 1 1)
              ))) '(1 0 0 0 0 1 1 1 1 0 1 1))

(check-equal? (calculate-epsilon (count-ones'(
              (1 0 0 0 0 1 1 1 1 0 1 1)
              ))) '(0 1 1 1 1 0 0 0 0 1 0 0))

(define (binary-to-dec input) (foldl (lambda (val index agg) (+ agg (* val (expt 2 index)))) 0 input (reverse (range (length input)))))

(check-equal? (binary-to-dec '(1 0 0)) 4)
(check-equal? (binary-to-dec '(1 1 0)) 6)
(check-equal? (binary-to-dec '(1 0 1)) 5)

(define counted-input (count-ones input))


(define (get-most-common-nth input-lists n) (if (<= 0 (list-ref (count-ones input-lists) n)) 1 0))
(define (get-least-common-nth input-lists n) (if (<= 0 (list-ref (count-ones input-lists) n)) 0 1))

(check-equal? (get-most-common-nth '((0 1 1) (0 1 1) (1 1 1)) 0) 0)
(check-equal? (get-least-common-nth '((1 0 1) (1 1 1) (0 1 1)) 1) 0)
(check-equal? (get-least-common-nth '((0 0 1) (0 1 1) (0 1 1)) 0) 1)

(define (filter-lists-by-nth-number list-of-lists n number) (filter (lambda (list) (= (list-ref list n) number)) list-of-lists))


(define (filter-for-oxygen-incr input n) (filter-lists-by-nth-number input n (get-most-common-nth input n)))
(define (filter-for-co2-incr input n) (filter-lists-by-nth-number input n (get-least-common-nth input n)))

(check-equal? (filter-for-oxygen-incr '((0 1 1) (0 1 0) (1 0 0)) 0) '((0 1 1) (0 1 0)))
(check-equal? (filter-for-co2-incr '((0 1 1) (0 1 0) (1 0 0)) 0) '((1 0 0)))

(define (hunt-for-number input step step-fn)
  (define result (step-fn input step))
  (if (= (length result) 1) (car result) (hunt-for-number result (+ step 1) step-fn))
)

(define (filter-for-oxygen input) (hunt-for-number input 0 filter-for-oxygen-incr))
(define (filter-for-co2 input) (hunt-for-number input 0 filter-for-co2-incr))

(check-equal? (filter-for-oxygen '((1 0 1 1 0) (1 0 1 1 1) (1 0 1 0 1))) '(1 0 1 1 1))
(check-equal? (filter-for-co2 '((1 0 1 0 0) (1 1 1 1 1) (1 0 1 1 1) (0 0 0 1 0) (0 1 0 1 0))) '(0 0 0 1 0))

;;P1
(* (binary-to-dec (calculate-gamma counted-input)) (binary-to-dec (calculate-epsilon counted-input)))
;;P2
(* (binary-to-dec (filter-for-oxygen input)) (binary-to-dec (filter-for-co2 input)))