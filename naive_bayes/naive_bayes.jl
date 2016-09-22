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

function readData(dataPath)
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

readData("./data")
