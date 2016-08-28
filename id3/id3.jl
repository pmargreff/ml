using DataFrames, RDatasets

function entropy(set, target, class)
  nrows, ncolumns = size(set)
  totalEntropy = 0.0
  for subdf in groupby(set, target)
    subdf_nrows, subdf_ncolumns = size(subdf)
    partialEntropy = 0.0
    for subdf_class in groupby(subdf, class)
      partialEntropy += ((-nrow(subdf_class)/subdf_nrows) * log2(nrow(subdf_class)/subdf_nrows))
    end
    totalEntropy += (subdf_nrows/nrows) * partialEntropy
  end
  return totalEntropy
end


function gain(set)
  value = -entropy(file)
end

file = readtable("beach.csv")


println(entropy(file, :Outlook, :Beach))
