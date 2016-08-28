using DataFrames, RDatasets

function entropy(set)
  dataEntropy = 1.0
  df = DataFrame(names = names(set))
  nrows, ncolumns = size(set)
  # for col in eachcol(set)
    # println(col[:1]) 
    # println(by(set, col[:1], nrow))
  # end
  resultEntropy = 0.0
  for subdf in groupby(set, [:Beach])
    # println(subdf)
    for test in groupby(subdf, [:Beach])
      # println(test)
    end
    resultEntropy += ((-nrow(subdf)/nrows) * log2(nrow(subdf)/nrows))
  end
  println(resultEntropy)

end

file = readtable("beach.csv")

# delete!(file, length(file))
(entropy(file))
  
