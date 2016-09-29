# ID3 in Julia
Machine Learning algorithms

## Synopsis

This is a simple implementation of ID3 using Julia. The trees are made with dictionaries, is only an abstraction, because we can't work with pointers.

## Installation

All algorithms built on [Julia](http://julialang.org/) programming language, so you will need instal Julia and the follow package:
- Dataframes

## Run

To built the tree run:

```
julia id3/id3.jl data/beachTraining.csv 
```

The first parameter is the training file. The command will make a file named `id3Test.jl` for predict new examples you need run this file.

```
julia id3/id3Test.jl data/beachTest.csv output.txt
```

The first parameter is the file containing new examples, and the second is the output file with the classification. 

## File Format

The file format of the input files need to be a csv with a header on columns. The column with the predictable attribute need be renamed to class. The file that will be predicted can't have the class column. Examples are on `id3/data/` directory.

## TODO
 - Pruning
 - Handle with N/A values
