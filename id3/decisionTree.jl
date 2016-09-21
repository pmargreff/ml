using DataFrames

# replace this line with tree (and the next one with the predictable) generated by id3.jl file

function getPrediction(tree, row)
  
  # test if is the final node
  if get(tree, "final", false) != false
    return get(tree, "final", false)
  end
  
  nodeKey = cleanType("ASCIIString", string(keys(tree)))
  
  atributeValue = cleanType("UTF8String", string(row[symbol(nodeKey)]))
  
  # test if the value of node atribute is the same in the next node
  for node in tree[nodeKey]
    subtree = Dict(node[2])
    if node[1] == atributeValue
      return getPrediction(subtree, row)
    end
  end
  
  return "Can't predict the value"
end

function cleanType(stringType, text)
  text = replace(text, stringType , "")
  text = replace(text, "[\"" , "")
  text = replace(text, "\"]" , "")
  return text
end

function guessFunction(tree, inputFile)
  # println(tree)
  for row in eachrow(inputFile)
    println(getPrediction(tree, row))
  end
end

guessFunction(tree, inputFile)
