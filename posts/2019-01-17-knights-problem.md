---
title: A naïve approach to the knights problem
author: Efraim Rodrigues
tags: chess, data structure, combinatorics
---

Available on <a href="http://github.com/efraimrodrigues/knights-problem" target="_blank">GitHub<img width="2%" src="/files/GitHub-Mark-64px.png"/></a>

### Intro
This problem was given to me in my sophomore year at college during one of my data structure courses with <a href="http://lia.ufc.br/~tiberius/" target="_blank">Prof. Tibérius Bonates</a>. At the time my programming skills weren't that advanced and this was a very difficult problem for me, though I already had the knowledge to solve it. However, this was a great application of basic data structures as you will see.

Consider the traditional chess game played over a chessboard of eight columns and eight rows. Each piece can attack a set of positions around it. In particular, the knight attacks in L. This move consists of moving one line and then two columns or two lines and one column.

The idea here is to allow the chessboard to have forbidden cells. This is more fun since the solution will not be the same for different configurations of the chessboard. In order to do that, our code receives a configuration file. So given an initial configuration of the chessboard our approach is to try all the possible configurations such that we find the maximum number of knights that can be placed in the initial chessboard.

The first line indicates the size of the chessboard and the second line indicates the number of forbidden positions for knights to be placed. The following lines point to the positions which cannot have knights placed. The x axis is represented by letters as the y axis is represented by numbers.

This is very basic example file:
<pre>
4
2
b4
d1
</pre>

### The solution
In this approach we attempt to test all the possible configurations of knights in the chessboard and this is what makes our approach so naïve. One might wonder how it is possible to test all possible configurations. When we think of all possible solutions we think of the tree of combinations. In graph theory a tree is a graph such that it is connected and is acyclic. In this context, the root of our tree is the initial set up received from the configuration file.

To illustrate the algorithm let us consider a chessboard without any forbidden cells. To keep track of each node of our tree we use a <a href="https://en.wikipedia.org/wiki/Stack_(abstract_data_type)" target="_blank">stack data structure</a>. As each cell can be placed with a knight or not this is where the algorithm branches. If we take the initial set up, the first chessboard configuration is push into the stack. So the algorithm will take the head chessboard and create two new chessboards. The first one is where the first cell is forbidden of taking any knights and the second is where the first cell does get a knight. The operation of placing a knight is done of course if it is not in the attack zone of any other knight. If a knight cannot be placed in the current cell, the next cells will be taken in consideration.

In terms of data structure, the code keeps the chessboard in a matrix of integers. There are four possible values a cell to receive:

- -1 means this cell is forbidden for taking any knight;
- 0 means the absence of knights in the cell;
- 1 means there is a knight in the cell;
- 2 means that this is the attack zone of a knight.

This is the pseudocode for this solution:

<pre>
chessboard = loadConfigurationFile();
chessboard.i = 0;
chessboard.j = 0;

stack.push(chessboard);

max = 0;
res = null;

while(!stack.empty()) {

    chessboard = stack.pop();

    if(chessboard.getSlots() == 0) {
        if(chessboard.getKnights() > max)
            max = chessboard.getKnights();
            res = chessboard;
    } else {
        chessboard_1 = chessboard;

        chessboard_1.addKnight();
        chessboard_1.j = (chessboard_1.j + 1)%chessboard.size();
        if(chessboard_1.j == 0)
            chessboard_1.i++;

        stack.push(chessboard_1);

        chessboard_2 = chessboard;
        
        chessboard_2.forbidKnight();

        stack.push(chessboard_2);
    }
}

return max, res;
</pre>

You can find the implementation in *C++* on <a href="http://github.com/efraimrodrigues/knights-problem" target="_blank">GitHub<img width="2%" src="/files/GitHub-Mark-64px.png"/></a> and run it yourself.

### Complexity analysis
As you can see for each chessboard (node) the algorithm branches into other two nodes. Taking *n* as the number of cells in the chessboard, we can see that as the following recursive function:

<pre>
T(n) = T(n-1) + T(n-1) + k
T(n) = 2T(n-1) + k
</pre>

Considering *T(0) = 1*, if we use direct substitution in *T(n) = 2T(n-1) + k* we will have:

<pre>
T(n) = 2T(n-1) + k
     = 2(2T(n-2) + k) + k
     = 2(2(2T(n-3) + k) + k) + k
     = ...
     = 2<sup>n</sup>T(n-n) + k(2<sup>n</sup> - 1)
     = O(2<sup>n</sup>)
</pre>


Thus, we can conclude this algorithm is O(2<sup>n</sup>) and runs in exponential time, which is not very good because *n* increases to the power of two according to the size of the chessboard. If we take the default chessboard with eight columns and eight rows, the algorithm has to go through 2<sup>64</sup> nodes.

<style>
pre {
    padding-left: 5%;
}
</style>