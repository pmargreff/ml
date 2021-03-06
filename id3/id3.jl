using DataFrames

function entropy(set, target, class)
  nrows, ncolumns = size(set)
  totalEntropy = 0.0
  for subset in groupby(set, class)
    subset_nrows, subset_ncolumns = size(subset)
    partialEntropy = 0.0
    if subset[1,class] == target
      totalEntropy = pnEntropy(subset, :class) 
    end
  end
  return totalEntropy
end

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
  
  nrows, ncols = size(set)
  partialEntropy = 0.0
  for subset in groupby(set, target)
    subset_nrows, subset_ncolumns = size(subset)
    partialEntropy += (subset_nrows/nrows) * entropy(set, subset[1, target], target)
  end
  return pnEntropy(set, class) - partialEntropy
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
  
  for attribute in attributes
    if class != attribute
      if major < (gain(set, attribute, class)) 
        major = (gain(set, attribute, class))
        target = attribute
      end
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
  
  return newDf
end

function isUniqueClass(set, class)
  nrows, ncols = size(set)
  subset = by(set, class, nrow)
  
  instances = subset[1,:x1]
  if instances == nrows
    return true
  end
  return false
end

function buildTree(set, attributes, class)
  nrows, ncols = size(set)
  
  
  # test if attributes are empty 
  if ncols == 1 
    return Dict("final" => majority(set, class))
    
    # test if all elements from a class are the same 
  elseif isUniqueClass(set, class) 
    return Dict("final" => set[1,class])
  else
    best = chooseAttribute(set, attributes, class)
    bestValues = (Set(set[best]))
    nodes = Dict()
    
    for value in bestValues
      nodes[value] = Dict()
    end
    
    tree = Dict{Any, Any}
    tree = (string(best) => nodes)
    newSet = DataFrame()
    
    for node in bestValues
      newSet = createNewSet(set, best, node)
      newAttributes = copy(attributes)
      deleteat!(newAttributes, findfirst(newAttributes, best))
      nodes[node] = buildTree(newSet, newAttributes, class)
    end
  end
  return tree
end


function createDecisionTreeFile(tree, decisionTreeFile)
  outputFile = open(decisionTreeFile, "w")  
  
  inputFile = open("decisionTree.jl")
  
  for ln in eachline(inputFile)
    if contains(ln,"# replace this line")
      write(outputFile, "tree = Dict(")
      write(outputFile, string(tree))
      write(outputFile, ")\n")
      
    else 
      write(outputFile, ln)
    end
  end
  
  close(inputFile)
  close(outputFile)
end


if length(ARGS) == 1
  inputFile = readtable(ARGS[1])
  outputTree = buildTree(inputFile, names(inputFile), :class) 
  createDecisionTreeFile(outputTree,"id3Test.jl")
else
  println("incorrect arguments, try run:")
  println("julia id3.jl data/beachTraining.csv ")
  println("for more info see the readme file, yes the file's name is README and I can't imagine why.")
end
