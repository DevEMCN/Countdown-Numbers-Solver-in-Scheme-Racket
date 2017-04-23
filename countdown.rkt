#lang racket

;following function adapted from http://stackoverflow.com/questions/29244677/implementation-of-lifo-list-in-scheme
; so this is the stack function with 3 options
; see note 1 in README on this function
(define (make-stack)
  (let ((stack '())) ; maintain the stack with this varible
    (lambda (msg . args) ; depending on the message sent, do pop push or peek (called stack here)
      (cond
        
        [(eq? msg 'pop)  (let ((head (car stack))) (set! stack (cdr stack)) head)] ; this is the pop method
        [(eq? msg 'push) (set! stack (append (reverse args) stack))] ; this is the push method
        [(eq? msg 'stack) stack] ; this just returns the stack as it is
        [else "Not valid message"]))))

; adpated from https://github.com/paopao2/Algorithm-Practice/blob/master/Evaluate%20Reverse%20Polish%20Notation.java
; see note 2 on this function in README on this functions
(define (evalrpn lst stack); this is a recursive loop through the input l
 (cond ((null? lst)
      (stack 'stack)) ; return the stack
      ((if (number? (car lst)) ; if the next item in the list is a number
          (stack 'push (car lst)) ; push that number onto the stack
          (cond
              ((symbol=? '+ (car lst)) (let ((op2 (stack 'pop)) (op1 (stack 'pop)))(stack 'push (+ op1 op2))))  ;push the result of pop stack + pop stack back onto the stack
              ((symbol=? '- (car lst)) (let ((op2 (stack 'pop)) (op1 (stack 'pop)))(stack 'push (- op1 op2))))  ; and so on
              ((symbol=? '* (car lst)) (let ((op2 (stack 'pop)) (op1 (stack 'pop)))(stack 'push (* op1 op2))))  ; ..
              ((symbol=? '/ (car lst)) (let ((op2 (stack 'pop)) (op1 (stack 'pop)))(cond [(not (zero? op2))(stack 'push (/ op1 op2))][stack 'push 'a])))  ; .
              (else stack 'stack))) ; return the stack
      (evalrpn (cdr lst) stack)))) ;  back into the loop

; adpated from http://stackoverflow.com/questions/14506831/whats-the-fastest-way-to-check-if-input-string-is-a-correct-rpn-expression
; basically if this function does not return 1 then it is not valid rpn
; for example (3 4 + 1 *) count will start at 0 then goes 1-2-1-2-1 ending in 1, so this is valid
; (2 3 4 + 1) starts at 0 then goes 1-2-3-2-3 ending in 3, so this is not valid
; or if it goes to 0 at any time inside the loop then it is not vali
; see note 3 on README on this function
(define valence-opr -1)
(define valence-opd 1)
(define (validate-rpn l count) ;reworked version of count which is more functional looking and has the check to see if count goes below 0
  (cond [(null? l) count]  ; if the list is empty, return the count
        ;  ; otherwise, check of the next item in the list is a number and set the correct valence for count
        [(if (number? (car l)) (set! count (+ count valence-opd))(set! count (+ count valence-opr)))
         ; otherwise if the count is <= 0 the epression is invalid so return count which above will be filtered out
         (if (<= count 0) count (validate-rpn (cdr l) count))])) ; otherwise keep looping around


; following 2 bits of adapted from here http://stackoverflow.com/questions/3179931/how-do-i-generate-all-permutations-of-certain-size-with-repetitions-in-scheme
(define (flatmap f lst)
  (apply append (map f lst)))

(define (ops-perms size elements)
  (if (zero? size)
      '(())
      (flatmap (lambda (p)            ; For each permutation we already have:
                 (map (lambda (e)     ;   For each element in the set:
                        (cons e p))   ;     Add the element to the perm'n.
                      elements))
               (ops-perms (- size 1) elements))))


(define ops '(+ - / *))

(define (countdown l answer)
  (let ((s (make-stack))) ; give the program a copy of the the stack
  (let ((nums '())) ;list takes 1 num at a time
    (let ((numops '())) ; list should add 1 operator at a time to list, but only adds 1 operator right now
      (let ((permus '())) ; list for all the permutations
        (let ((permus-valid '()))
        (do ()                             
          ((null? l))
          (set! nums (cons (car l) nums)) ; take one number
          ; next add every possible permutation, through sizes 1 to 5 of operators to the list 1
          (let ((size 1)) ; size of the list of operators to add onto the list
            (let ((allow 1)) ; the allow variable stops permutations being generated if the list of numbers cant take more operators
            (do ()
            ((= size 6))  ; max operators list size can be 5 for a list of 6 numbers
              (let ((opsperms (ops-perms size ops))) ; this is a list of lists of permutations of operators of allowed size
                (do ()
                  ((null? opsperms)) 
                  (let ((combs (combinations nums))) ; this is a list of list of combinations of the numbers 
                  (do ()
                    ((null? combs))
                    (let ((comb (car combs))) ; take one combination from the list
                      ; if the length of the combination is bigger than allow, then add permutations of operators to the combintation
                    (cond[(< allow (length comb))(set! numops (cons(append (car opsperms) comb)numops))]))(set! combs (cdr combs)))(set! opsperms (cdr opsperms))))
              (set! size (+ 1 size))(set! allow (+ 1 allow))))))
          ;(set! permus
        
          (set! l (cdr l))) (do ()
                              ((null? numops))
                              (let ((perms (permutations (car numops)))) ; permute each list of operators and numbers
                                (do ()
                                  ((null? perms)) 
                                  (cond [(= (validate-rpn (car perms) 0) 1) ; validate all permutations
                                         ; check each validated permutation to see if its the answer and display it
                                         (cond [(= (car(evalrpn (car perms) s)) answer)(display(car perms))])])(set! perms (cdr perms)))) (set! numops (cdr numops)))))))))


(countdown '(1 2 3) 3)


