using DataFrames

tree = Dict{Any,Any}("Outlook"=>Dict{Any,Any}("Rain"=>"Wind"=>Dict{Any,Any}("Strong"=>Dict("final"=>"No"),"Weak"=>Dict("final"=>"Yes")),"Sunny"=>"Humidity"=>Dict{Any,Any}("High"=>Dict("final"=>"No"),"Normal"=>Dict("final"=>"Yes")),"Overcast"=>Dict("final"=>"Yes")))

inputFile = readtable("guess.csv")

function getPrediction(tree, row)
  nodeKey = string(keys(tree))
  nodeKey = replace(nodeKey, "Any[\"" , "")
  nodeKey = replace(nodeKey, "\"]" , "")
  
  rowNames = names(row)
  
  # test if some node is final
  for node in tree[nodeKey]
    testeFinal = Dict(node[2])
    if get(testeFinal, "final", false) != false
      return get(testeFinal, "final", false) 
    end
  end
  
  for node in tree[nodeKey]
    subtree = Dict{Any,Any}(node[1] => node[2]) 
    # println(subtree)
    testeFinal = Dict(node[2])
    if get(testeFinal, "final", false) != false
      println(get(testeFinal, "final", false))
      # return get(testeFinal, "final", false) 
    end
  end
  # if rowNames[1] == symbol(nodeKey)
  # end
  # println(row[symbol(nodeKey)])
  # dump((testeFinal))
  # dump(tree[nodeKey])
end

function testValue(tree, row)
  if tree == row
    body
  else 
    return testValue(subtree, subrow)
  end
end

getPrediction(tree, inputFile)
