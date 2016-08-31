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
  return value
end

# find the majoritie class
function majority(set, class)
  df = (by(set, class, nrow))
  
  nrows, ncols = size(df)
  
  majorIndex = 1
  majorValue = 0
  
  for row in 1:nrows
    if majorValue < df[row,:x1] 
      majorValue = df[row,:x1]
      majorIndex = row
    end
    
  end
  return df[majorIndex, class]
end

function chooseAttribute(set, attributes, class)
  major = 0.0
  target = ""
  
  deleteat!(attributes, findfirst(attributes, class))
  for attribute in attributes
    if major < (gain(set, attribute, class)) 
      major = (gain(set, attribute, class))
      target = attribute    
    end
  end
  
  return target
end

# create a new set to a value and delete the best attribute column
function createNewSet(df, best, value)
  
  newDf = DataFrame()
  for subDf in groupby(df, best)
    if subDf[1,best] == value
      newDf = subDf
    end
  end
  
  delete!(newDf, best)
  
  return newDf
end

function buildTree(set, attributes, class)
  
  default = majority(set, class)
  # println(set)
  nrows, ncols = size(set)
  
  if 1 == 2
    # TODO: Pensar em alguma conversão, dicionário ou sl 
    return default
    
  elseif 1 == 3
    return "something"
    
  else
    
    best = chooseAttribute(file, attributes, class)
    bestValues = (Set(set[best]))
    
    nodes = Dict()
    
    for value in bestValues
      nodes[value] = Dict()
    end
    
    tree = Dict{Any, Any}
    tree = (string(best) => nodes)
    for node in bestValues
      newAttributes = copy(attributes)
      deleteat!(newAttributes, findfirst(newAttributes, best))
      newSet = createNewSet(set, best, value)
      println(nodes[node])
      # nodes[node] = buildTree(newSet, newAttributes, class)
    end
    # buildTree(set, attributes, class)
    # para cada valor de atributo na lista voltar para o passo dois 
  end
  return tree
end
file = readtable("beach.csv")

# println(majority(file, :Beach))
# println(buildTree(file, names(file),  :Beach))
println(createNewSet(file, names(file), :Outlook, "Rain"))
# make the tree finding the best attribute gain
