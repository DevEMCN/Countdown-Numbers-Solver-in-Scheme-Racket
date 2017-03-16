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

;(define combs '((1 1 +)(4 2 5 * + 1 3 2 * + /)))
(define combs (combinations l))
(define answer 2)
(define a '())

; adpated from http://stackoverflow.com/questions/14506831/whats-the-fastest-way-to-check-if-input-string-is-a-correct-rpn-expression
; basically if this function does not return 1 then it is not valid rpn
; for example (3 4 + 1 *) count will start at 0 then goes 1-2-1-2-1 ending in 1, so this is valid
; (2 3 4 + 1) starts at 0 then goes 1-2-3-2-3 ending in 3, so this is not valid
; or if it goes to 0 at any time inside the loop then it is not vali

(define valence-opr -1)
(define valence-opd 1)

(define (validate-rpn l count) ;reworked version of count which is more functional looking and has the check to see if count goes below 0
  (cond [(null? l) count]  ; if the list is empty, return the count
        ;  ; otherwise, check of the next item in the list is a number and set the correct valence for count
        [(if (number? (car l)) (set! count (+ count valence-opd))(set! count (+ count valence-opr)))
         ; otherwise if the count is <= 0 the epression is invalid so return count which above will be filtered out
         (if (<= count 0) count (validate-rpn (cdr l) count))])) ; otherwise keep looping around

;(validate-rpn l 0)

(define perms (filter (lambda (x) (= (validate-rpn x 0) 1)) combs)) ;function filters valid rpn expressions

perms

(define (find-ans) ; loop through the list of lists, a being a list that will contain the answers
    (filter
     (lambda (x)
       (let ((s (make-stack))) ; give the evalrpn a stack to use
       (let ((an (evalrpn x s)))
       (= (car an) answer))) ; the reason for finding the length of stack is that my count function has a slight bug in it. see note 3
     )perms))

;(find-ans)
