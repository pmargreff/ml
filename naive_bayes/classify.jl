
using DataFrames
using TextAnalysis

function getTraining(traningPath)
  files = (readdir(traningPath))
  
  training = Dict()
  
  for file in files
    df = readtable(string(traningPath,file)) 
    filename, fireformat = splitext(file)
    
    training[filename] =  df
  end
  return training
end

function classifyFile(training, example)
  prior = getPrior(training)
  file = open(example)
  text = tokenizer(readstring(file))
  close(file)
  
  words = DataFrame(word = text)
  stats = Dict()
  
  for class in training
    probability = 0.0
    classProb = class[2]
    
    for row in eachrow(words)
      wordProb = classProb[classProb[:word] .== row[:word],:]
      if nrow(wordProb) != 0
        if probability == 0.0
          probability = 1.0
        end
        probability *= wordProb[1,:prob]
      end
    end

    stats[class[1]] = probability
  end

  first = true
  label = ""
  value = 0.0
  for classStats in stats
    if first 
      value = classStats[2]
      label = classStats[1]
      first = false
    end
    if value < classStats[2]
      value = classStats[2]
      label = classStats[1]
    end
  end
  return label
end

function getPrior(trainingSet)
  first = true
  label = ""
  value = 0
  for class in trainingSet
    if first 
      first = false
      label = class[1]
      value = nrow(class[2])
    end
    if value < nrow(class[2])
      label = class[1]
      value = nrow(class[2])
    end
  end
  
  return label
end

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

function classifyFolder(training, path)
  absPath, file = splitdir(@__FILE__())
  
  files = readdir(path)
  df = DataFrame(file = "a", label = "teste")
  deleterows!(df, 1)
  for file in files
    filePath = string(path, file) 
    push!(df, @data([file, classifyFile(training, filePath)]))
  end
  
  outputFile = string(absPath, "/classification.csv")
  writetable(outputFile, df)
end

if length(ARGS) == 1
  absPath, file = splitdir(@__FILE__())
  
  println("absPath:" , absPath)
  classifyDataPath = string(absPath, ARGS[1]) 
  trainingDataPath = string(absPath, "/probabilities/")
  
  training = getTraining(trainingDataPath)
  
  classifyFolder(training, classifyDataPath)  
else
  println("incorrect arguments, try run:")
  println("julia classify.jl /data/test/spam/")
  println("for more info see the readme file, yes the file's name is README and I can't imagine why.")
end
