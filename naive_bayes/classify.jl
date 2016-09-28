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

function classify(training, example)
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
    println(classStats[2])
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

absPath, file = splitdir(@__FILE__())
classifyDataPath = string(absPath, "/test/ham/aaa.txt") 
trainingDataPath = string(absPath, "/probabilities/")

training = getTraining(trainingDataPath)

println(classify(training, classifyDataPath))
