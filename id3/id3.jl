using DataFrames, RDatasets


# calculate entropy from a target argument
function entropy(set, target, class)
  nrows, ncolumns = size(set)
  totalEntropy = 0.0
  for subset in groupby(set, target)
    subset_nrows, subset_ncolumns = size(subset)
    partialEntropy = 0.0
    totalEntropy += (subset_nrows/nrows) * pnEntropy(subset, class)
  end
  return totalEntropy
end

# calculate the entropy of all positives and negatives (or choosed class) values in a set
function pnEntropy(set, class)
  nrows, ncolumns = size(set)
  totalEntropy = 0.0
  for subset in groupby(set, class)
    subset_nrows, subset_ncolumns = size(subset)
    totalEntropy += -(((subset_nrows/nrows)) * log2((subset_nrows/nrows)))
  end
  return totalEntropy
end


# calculate the gain of a set
function gain(set, target, class)
  value = pnEntropy(set, class) - entropy(set, target, class)
  println(value)
end

file = readtable("beach.csv")


gain(file, :Wind, :Beach)
