# Naive Bayes in Julia
Machine Learning algorithms

## Synopsis

This is a simple implementation of Naive Bayes using Julia. It could be used to classify label data text.

## Installation

All algorithms built on [Julia](http://julialang.org/) programming language, so you will need instal Julia and the follow package:
- Dataframes
- Text

## Run

To built the tree run:

```
julia naive_bayes/naive_bayes.jl /data/training 
```

The parameter is a directory containing directories. Each one is one different label (on the example spam and ham), but you can create other categories to classify, each directory need `.txt` files to get the worlds probability, have no difference if you create a lot of documents (the classificator will read each one) or if you use only one big file. 
```
julia naive_bayes/classify.jl /data/test
```

The parameter is the path to the directory with the new examples, it walks on the `probabilities/` directory and get the probability of each word for each class and make a file named `classification.csv` with the file name and the predicted label. 

## File Format

A simple txt file to the training and the same to the test. 

## TODO
 - Make a weight to each class
