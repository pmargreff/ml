# Single Layer Perceptron in Julia
Machine Learning algorithms

## Synopsis

This is a simple implementation of Simple Layer Perceptron using Julia.

## Installation

All algorithms built on [Julia](http://julialang.org/) programming language, so you will need instal Julia and the follow package:
- Dataframes

## Run

To make the train:

```
julia slp/slp.jl train data/mnist_train.csv 
```

The first parameter is the mode, it could be train or test, the second parameter is the file to training. The train will be generated on directory train, and it will use that to classify the tests.

To test is similar:

```
julia slp/slp.jl test data/mnist_test.csv 
```

## File Format

The file format of the input files need to be a csv without a header. The first column have the label to class, the anothers the values. 


## TODO:
- [ ] alterar comparação da label para strings

- [ ] normalizar números

- [ ] matriz de confusão e outras estátisticas
