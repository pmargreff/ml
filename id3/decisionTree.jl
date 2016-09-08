using DataFrames

tree = Dict("Outlook"=>Dict{Any,Any}(
        "Rain"=>"Wind"=>Dict{Any,Any}("Strong"=>Dict("final"=>"No"),"Weak"=>Dict("final"=>"Yes")),
        "Sunny"=>"Humidity"=>Dict{Any,Any}("High"=>Dict("final"=>"No"),"Normal"=>Dict("final"=>"Yes")),
        "Overcast"=>Dict("final"=>"Yes")))

inputFile = readtable("guess.csv")

function getPrediction(tree, row)
  nodeKey = string(keys(tree))
  nodeKey = replace(nodeKey, "ASCIIString[\"" , "")
  nodeKey = replace(nodeKey, "\"]" , "")

  atributeValue = cleanType("UTF8String", string(row[symbol(nodeKey)]))

  # test if the value of node atribute is the same in the next node
  # and if it's the final node
  for node in tree[nodeKey]
    subtree = Dict(node[2])
    if node[1] == atributeValue
      if get(subtree, "final", false) != false
        return get(subtree, "final", false) 
      else
        return getPrediction(subtree, row)
      end
    end
  end
  return false
end


function cleanType(stringType, text)
  text = replace(text, stringType , "")
  text = replace(text, "[\"" , "")
  text = replace(text, "\"]" , "")
  return text
end

println(getPrediction(tree, inputFile))
