using TextAnalysis
using DataFrames
# TODO:
# 1 - implementar tokenizer - DONE
# 2 - implementar o leitor e separador de arquivo - DONE
# 3 - entender algoritmo de classificação - DONE
# 4 - implementar trainamento - DONE
  # 4.1 - implementar priori - DONE
  # 4.2 - implementar por classe - DONE
  # 4.3 - calcular construir - DONE
# 5 - implementar classificador - DONE
# 5.05 - Passar entradas para linha de comando
# 5.09 - Documentar
# 5.1 refinar classificador -
function tokenizer(text)
  
  words = String[]
  sentence = (split(text))
  for word in sentence
    if isalpha(word) && word != "a" && word != "an" && word != "the"
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
    
    repeatedWord = newdf[newdf[:x1] .> 2,:]
    probabilities = DataFrame(word = repeatedWord[1],prob = repeatedWord[:x1]/total)
    
    probabilitiesByClass[class[1]] = probabilities
  end

  return probabilitiesByClass
end

function createProbabilityFiles(prob, absPath)
  for wordProbs in prob
    fileName = string(absPath, "/probabilities/",wordProbs[1], ".csv")
    writetable(fileName, wordProbs[2])
  end
end

if length(ARGS) == 1
  absPath, file = splitdir(@__FILE__())

  trainingDataPath = string(absPath,ARGS[1])
  
  prior = getPriorProbability(trainingDataPath)
  
  prob = getConditionalProbability(trainingDataPath)

  createProbabilityFiles(prob, absPath)
else
  println("incorrect arguments, try run:")
  println("julia naive_bayes.jl /data/training")
  println("for more info see the readme file, yes the file's name is README and I can't imagine why.")
end
