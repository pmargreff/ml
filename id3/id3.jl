using DataFrames, RDatasets

# TODO: Adicionar parametro attribute, para saber sobre qual atributo alvo será feita a entropia
# TODO: Adicianar atributo class, para saber qual é a base desejada para a divisão
function entropy(set)
  df = DataFrame(names = names(set))
  nrows, ncolumns = size(set)
  totalEntropy = 0.0
  for subdf in groupby(set, [:Outlook])
    subdf_nrows, subdf_ncolumns = size(subdf)
    partialEntropy = 0.0
    for test in groupby(subdf, [:Beach])
      partialEntropy += ((-nrow(test)/subdf_nrows) * log2(nrow(test)/subdf_nrows))
    end
    totalEntropy += (subdf_nrows/nrows) * partialEntropy
  end
  return totalEntropy
end


function gain(attribute, set)
  body
end

file = readtable("beach.csv")

println(entropy(file))
