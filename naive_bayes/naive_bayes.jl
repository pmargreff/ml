# Pkg.add("TextAnalysis")
using TextAnalysis
using DataFrames
# TODO:
# 1 - implementar tokenizer - DONE
# 2 - implementar o leitor e separador de arquivo - DONE
# 3 - entender algoritmo de classificação - DONE
# 4 - implementar trainamento -
  # 4.1 - implementar priori - DONE
  # 4.2 - implementar por classe - 
  # 4.3 - calcular construir -
# 5 - implementar classificador -
# 5.1 refinar classificador -

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

function getPriorProbability(path)
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

function getConditionalProbability(path)
  wordsByClass = getWordsByClass(path)
  probabilitiesByClass = Dict()
  for class in wordsByClass
    total = 0
    
    df = DataFrame(word = class[2])
    newdf = by(df,:word, nrow)
    
    
    for value in newdf[:x1]
      total += value
    end
    
    probabilities = DataFrame(word = newdf[1],prob = newdf[:x1]/total)
    
    probabilitiesByClass[class[1]] = probabilities
  end

  return probabilitiesByClass
end

function createProbabilityFiles(prob)
  for wordProbs in prob
    fileName = string("probabilities/",wordProbs[1], ".csv")
    writetable(fileName, wordProbs[2])
  end
end

dataPath = "./data";

prior = getPriorProbability(dataPath)

prob = getConditionalProbability(dataPath)

createProbabilityFiles(prob)
