# Countdown-Numbers-Solver-in-Scheme-Racket
a program created with racket that can solve the numbers game from the tv show countdown on channel 4.


# Table of Contents
* [Introduction](#introduction)
* [Installation](#installation)
* [Research](#research)
* [Project Details](#details)
* [References](#references)

<a name="introduction"></a><b>Introduction</b><br/>
This project was created for the purposes of solving the numbers game from the tv show Countdown on Channel 4. A target is randomly generated and has to be between 101 and 999 inclusive and 6 randomly chosen numbers from a list of [1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 25, 50, 75, 100] are given to the player to reach that number. You can only use 4 operations (add, subtract, divide and multiply) and there can be no negatives or fractions.
<br/>


<a name="installation"></a><b>Installation</b><br/>
1. Clone this repo.
2. Open the racket file with DrRacket.
3. Run the racket file to see the solutions for randomly generated numbers and a randomly generated target answer

<a name="research"></a><b>Research and Project Details</b><br/>
When I first started researching this, I had remembered that I had seen the problem being posted last year on the r/dailyprogrammer section of the discussion website reddit.com [1]. The problem was posted with 3 different sub-problems with one of those sub-problems being that you had to use Reverse Polish Notation (RPN) and a stack to solve the game. From this I began researching the idea of using RPN (otherwise known as postfix notation) for my own project. 
  Reverse Polish Notation is the notation used for expressing arthmetic expressions without having to use brackets to prioritise the evaluation the operators. For example the expression (4 + 5) * (6 - 3) means that first the 4 and 5 must be added first followed by subtracting the 3 from the 6 and then you can multiply the answers from previous evalutations. However, with RPN notation the above expression can be rewritten as 
  `4 5 + 6 3 - *`. To evaluate this expression, use the idea of a stack, with the most recent numbers on the top of the stack. By reading from left to right it goes like this.<br/>
  1. Push 4 onto the stack
  2. Push 5 onto the stack. (stack looks like (4, 5)).
  3. apply the + operator to the two numbers taken off the top of the stack wich results in 9 and push that back onto the stack
  4. push 6 onto the stack
  5. push 3 onto the stack ( stack now looks like (9, 6, 3)).
  6. apply the - operator to the 2 most recently put on the stack, (6 and 3) which results in 3. push that onto the stack
  7. apply the * operator to the last 2 numbers on the stack (9,3) which results in 27. and push that onto the stack.

So naturally the first problem to solve in this project was to learn how to create a stack in Racket. This stack is marked note 1 in the project and was the adapted from the referenced stackoverflow link. It is a simple version of a stack (essentially a list), with pop, push and peek (called 'stack) functionality. The stack is used for the evaluate function but could also be used in the generation of permutations if used correctly (see further down on this point). 
<br/><br/>Next up was to figure out how to evaluate a given expression using the stack functionality created (Note 2 in the code). The code for this function (called evalrpn) is based on the link referenced which was a Java version of how to do it. It is a recursive function that takes two parameters 1) a list and 2) a copy of the stack. It works by first checking if the expression is empty, and if so returning the only item on the stack (see further down about vaidalting rpn expressions for what there is only 1 item on the stack here). Otherwise, if the the first item in the expression is a number, push that onto the stack, and if its not a number, find out what operator has been passed in and pop the last 2 items on the stack to be evaulated with the operator. Note that the order of popping off the stack is important here. The last item item put on the stack is the 2nd of the two numbers so this is accounted for in this function. It also doesn't allow divison by zero. Following these evaluations, the function is recursively called again, with a copy of the current stack and the rest of the list maninpulated above.
<br/><br/>
As mentioned above, it is important to validate the expressions to be perfect RPN as otherwise, you could end up with more than 1 number left on the stack. Hence I looked into ways of validating each expression created by the permutations generator function to filter out only valid expressions. The link for where the function is adapted from is provided in the code. The comments in the code explain how the function works but in essennce, it just checks that the validaity of an expression by counting the number of numbers and operators in the list. The count must be exactly 1 otherwise it is not valid. Note that this function could be used for checking whether a partially generated permutation could take another operator which I will talk about in more detail below.
<br/><br/>

Before explaining how the main function that generates the expressions works I will first look at what I tried to achieve with the creation of this function. From researching online about the problem, I came across the idea that the generation of the expressions could be done using the branch and bound algortithm. It's not that you need to create all the possible permutations of a list of 6 number and 5 operarators combined, to solve this problem efficently, the best solution would be not to generate as many permutations as you can instead. By using heuristics that block the branch paths of permutation generations that will not lead to the answer, or to a valid RPN expression, you only created expressions that might lead to the answer and would be valid RPN. 
<br/>Above I mentioned in both the section on the stack an the validaterpn function section that the both functions could be used in this possible solution. The stack for instance could be used to maintain a possible permutation path on the tree. Used in conjunction with the count method that could be changed to a function that tells whether an expression can take an operator at a certain point. For example, if the stack passed in is a length of 2 the it can take an operator. However at the same time it can also take another number. By using both these ideas, one could generate permutations that only lead to a possible solution to the answer provided. Unforuntately, the implementation of this strategy eluded me over the development of this project. I used only one of these ideas partially in my solution and it has a major limitation. That is, The function can only solve for maximum 6 numbers and 4 operators as generating permutations of a list of 11 is neither feasible or efficent for racket to do.
<br/><br/>
The main function works as follows. It first gets 1 number from the list provided, then generates permutations of N size of the operators in a loop from 1 to 5. if the size of the list of numbers is greater than the allow variable ( this variable is incremented from 1 to 5 also), which dictates how many operators the list of numbers is allowed take, then it appends the each permutation of operators from the list of operators to each combination of the list of numbers. Lastly, it generates permutations of these generated lists of numbers and operators ( and this is where my design flaw is, not allowing for a list of 11 numbers/operators), validates the that list of permutations and then checks for answers. If an answer is found it displays it to the screen.  
