#lang racket

(define l '(3 4 + 2 *))

;following function adapted from http://stackoverflow.com/questions/29244677/implementation-of-lifo-list-in-scheme
; so this is the stack function with 3 options
(define (make-stack)
  (let ((stack '())) ; maintain the stack with this varible
    (lambda (msg . args)
      (cond
        
        [(eq? msg 'pop)  (let ((head (car stack))) (set! stack (cdr stack)) head)] ; this is the pop method
        [(eq? msg 'push) (set! stack (append (reverse args) stack))] ; this is the push method
        [(eq? msg 'stack) stack] ; this just returns the stack as it is
        [else "Not valid code"]))))


; adpated from https://github.com/paopao2/Algorithm-Practice/blob/master/Evaluate%20Reverse%20Polish%20Notation.java
; see note 2 on this function
(define (evalrpn lst stack) ; this is a recursive loop through the input l
 (cond ((null? lst)
      (stack 'stack)) ; return the stack
      ((if (number? (car lst)) ; if the next item in the list is a number
          (stack 'push (car lst)) ; push that number onto the stack
          (cond
              ((symbol=? '+ (car lst)) (let ((op2 (stack 'pop)))(stack 'push (+ (stack 'pop) op2))))  ;push the result of pop stack + pop stack back onto the stack
              ((symbol=? '- (car lst)) (let ((op2 (stack 'pop)))(stack 'push (- (stack 'pop) op2))))  ; and so on
              ((symbol=? '* (car lst)) (let ((op2 (stack 'pop)))(stack 'push (* (stack 'pop) op2))))  ; ..
              ((symbol=? '/ (car lst)) (let ((op2 (stack 'pop)))(stack 'push (/ (stack 'pop) op2))))  ; ..
              (else stack 'stack))) ; return the stack
      (evalrpn (cdr lst) stack)))) ;  back into the loop

;(define s (make-stack))
;(evalrpn l s)

;(define combs '((1 2 +)(4 2 5 * + 1 3 2 * + /)))
(define combs (combinations l))

(define answer 2)
;(define (find-answers l a) ; loop through the list of lists, a being a list that will contain the answers
;  (let ((s (make-stack))) ; give the evalrpn a stack to use
;    (if (null? l) a
;  (cond
;    [(null? (car l))(find-answers (cdr l) a)]
;    [(= (car(evalrpn (car l) s)) answer) (cons (car l) a)] ; if the the evalrpn returns a number = to the answer, cons the list item
;     ; if the list is now empty, return the answers list a othwise move onto the next item
;    [else #f]))))

(define a '())

;(find-answers combs a)

; adpated from http://stackoverflow.com/questions/14506831/whats-the-fastest-way-to-check-if-input-string-is-a-correct-rpn-expression
; basically if this function does not return 1 then it is not valid rpn
; for example (3 4 + 1 *) count will start at 0 then goes 1-2-1-2-1 ending in 1, so this is valid
; (2 3 4 + 1) starts at 0 then goes 1-2-3-2-3 ending in 3, so this is not valid

(define (validate-rpn lst count) ; function for validating if given list is valid rpn 
 (cond ((null? lst) ; if the list is empty return the count
      count) ; return the stack
      ((if (number? (car lst)) ; if the next item in the list is a number
          (set! count (add1 count)) ; push that number onto the stack
          (set! count (sub1 count))) ; return the stack
      (validate-rpn (cdr lst) count)))) ;  back into the loop

;(validate-rpn l 0)

 (define perms (filter (lambda (x) (= (validate-rpn x 0) 1)) combs))


(define (find-answers) ; loop through the list of lists, a being a list that will contain the answers
  (let ((s (make-stack))) ; give the evalrpn a stack to use
    (filter
     (lambda (x)
       (= (car(evalrpn x s)) answer))
     perms)))

(find-answers)
