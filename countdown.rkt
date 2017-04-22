#lang racket

;following function adapted from http://stackoverflow.com/questions/29244677/implementation-of-lifo-list-in-scheme
; so this is the stack function with 3 options
(define (make-stack)
  (let ((stack '())) ; maintain the stack with this varible
    (lambda (msg . args) ; depending on the message sent, do pop push or peek (called stack here)
      (cond
        
        [(eq? msg 'pop)  (let ((head (car stack))) (set! stack (cdr stack)) head)] ; this is the pop method
        [(eq? msg 'push) (set! stack (append (reverse args) stack))] ; this is the push method
        [(eq? msg 'stack) stack] ; this just returns the stack as it is
        [else "Not valid message"]))))

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

(define l '(3 4 + 2 *))
;(define combs '((1 1 +)(4 2 5 * + 1 3 2 * + /)))
;(define combs (combinations l))
;(define perms (permutations l))
;(define answer 14)

 ;function filters valid rpn expressions
;(define filtered-perms (filter (lambda (x) (= (validate-rpn x 0) 1)) perms))

;(define perms-nodups (remove-duplicates filtered-perms));

;perms-nodups

 ;countdown solver here, produces a list will that contain the solutions to the answer given 
;(define (find-answers) 
;  (let ((s (make-stack))) ; give the evalrpn a stack to use
;    (filter ; filter the list to find only epxressions in the permutations list that match the answer given
;     (lambda (x)
;       (= (car(evalrpn x s)) answer))
;     perms-nodups)))

;(find-answers)




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

;(ops-perms 5 '(+ - / *))

; start with 2 lists, 2 numbers 1 operator, then add 1 on to each list to generate permutations
(define a '(1 2 3))
(define ops '(+ - / *))

(define (countdown-three l answer)
  (let ((s (make-stack)))
  (let ((nums '())) ;list takes 1 num at a time
    (let ((numops '())) ; list should add 1 operator at a time to list, but only adds 1 operator right now
      (let ((permus '())) ; list for all the permutations
        (let ((permus-valid '()))
        (do ()                             
          ((null? l))
          (set! nums (cons (car l) nums)) ; take one number
          ; next add every possible permutation, through sizes 1 to 5 of operators to the list 1
          (let ((size 1)) ; size of the list of operators to add onto the list
            (let ((allow 1))
            (do ()
            ((= size 6))  ; max operators list size can be 5 for a list of 6 numbers
              (let ((opsperms (ops-perms size ops)))
                (do ()
                  ((null? opsperms))
                  (cond[(< allow (length nums))(set! numops (cons(append (car opsperms) nums)numops))])(set! opsperms (cdr opsperms))))
              (set! size (+ 1 size))(set! allow (+ 1 allow)))))
          ;(set! permus
        
          (set! l (cdr l))) (do ()
                              ((null? numops))
                              (let ((perms (permutations (car numops))))
                                (do ()
                                  ((null? perms))
                                  (cond [(= (validate-rpn (car perms) 0) 1)
                                         (cond [(= (car(evalrpn (car perms) s)) answer)(display (car perms))])])(set! perms (cdr perms)))) (set! numops (cdr numops)))))))))

(countdown-three '(5 6 6 4) 75)

;(do ()
;                                  ((null? perms))
;                                  (cond [(= (validate-rpn (car perms) 0) 1)
;                                         (display perms)])(set! perms (cdr perms)))
;(filter ; filter the list to find only epxressions in the permutations list that match the answer given
            ; (lambda (y)
            ;   (= (validate-rpn y 0) 1)
            ;   (display y)
            ; perms)))
          ;(display numops)











(define (countdown-two l answer)
  (let ((nums '())) ;list takes 1 num at a time
    (let ((numops '())) ; list should add 1 operator at a time to list, but only adds 1 operator right now
      (let ((permus '())) ; list for all the permutations
        (let ((permus-valid '()))
        (do ()                             
          ((null? l))
          (set! nums (cons (car l) nums)) ; get the first number
               (let ((ops-temp '(+ - / *))) ; give loop a temporary operators list
                (do ()
                  ((null? ops-temp))
                  ;(cond
                  ;  [(> (validate-rpn nums 0) 1) ; block a useless list generation
                     ;(set! numops(cons(cons (car ops-temp) nums) numops))
                     (set! numops (cons(append ops-temp nums) numops));]
                    ;) ; add operator to one of the list of numbers
                  (set! ops-temp (cdr ops-temp)))) ; deplete the temp ops list by 1 ; this must be wrong here
          ;(let (lambda (x) (set! permus (cons (permutations x) permus)) numops)
          (do ()
            ((null? numops))
            (set! permus (cons (permutations (car numops)) permus))
            ;(do ()
            ;  ((null? permus))
            ;  (cond[(= (validate-rpn (car (car permus)) 0) 1)
            ;        (set! permus-valid (cons (car permus)))])(set! permus (car (cdr permus))))
            (set! numops (cdr numops))) ; deplete numops by 1
          (display permus)
          (set! l (cdr l))))))))

;(countdown-two '(1 2) 12)


; start the loop through the numbers list
; take one number
; take the first operator
; generate permutations by seeing if its allowed take an operator
; check all permutations of answers
; if answer store it in final list
; try each of the rest of the operators seperatly with the number
; then try adding 2 operators on, then 3 then 4 and then the 5th using the function that checks if an operator can be added
; then take 2 numbers and do the same thing
; and so on