# Pkg.add("TextAnalysis")
# using TextAnalysis
using DataFrames
# TODO:
# 1 - implementar tokenizer - DONE
# 2 - implementar o leitor e separador de arquivo - DONE
# 3 - entender algoritmo de classificação
# 4 - implementar trainamento
# 5 - implementar classificador

function tokenizer(text)
  
  words = String[]
  sentence = (split(text))
  for word in sentence
    if isalpha(word)
      push!(words, lowercase(word))
    end
  end
  return words  
end

function getWordsByClass(dataPath)
  dataDir = (readdir(dataPath))
  dict = Dict()
  for dir in dataDir
    subFold = string(dataPath,"/",dir)
    files = (readdir(subFold))
    allWords = String[]
    
      for fileName in files
      filepath = string(subFold,"/",fileName)
      f = open(filepath);
      text = readstring(f)
      append!(allWords, tokenizer(text))
      close(f)
    end
    
    dict[dir] = allWords
  end
  return dict
end

function getPriorProbality(path)
  dataDir = (readdir(path))
  occurenceDict = Dict()
  total = 0;
  for class in dataDir
    classDir = string(path,"/",class)
    total += length(readdir(classDir))
    occurenceDict[class] = length(readdir(classDir))
  end
  
  priorDict = Dict()
  
  for item in occurenceDict
    priorDict[item[1]] = item[2]/total 
  end
  
  return priorDict
end

 
dataPath = "./data";
finalDict = getWordsByClass(dataPath)

println(getPriorProbality(dataPath))

df = DataFrame(ham = finalDict["ham"])
newdf = by(df,:ham, nrow)

total = 0

for value in newdf[:x1]
  total += value
end

# println(total)
