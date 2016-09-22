# TODO:
# 1 - implementar tokenizer - DONE
# 2 - implementar o leitor e separador de arquivo
# 3 - entender algoritmo de classificação
# 4 - implementar trainamento
# 5 - implementar classificador

function tokenizer(text)
  words = String[]
  sentence = (split(s))
  for word in sentence
    if isalnum(word)
      push!(words, lowercase(word))
    end
  end
  return words  
end

f = open("data/ham/0002.1999-12-13.farmer.ham.txt");
s = readstring(f)

println(tokenizer(s))


close(f)
