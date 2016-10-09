using DataFrames

type Perceptron
  w :: Array{Float64,1}
  x :: Array{Float64,1}
end

function get_response(x, w)
  total = sum(x.*w)
  0 < total ? res = 1.0 : res = -1.0
  return res
end

function training_rule(df,target,eta,eras)
  
  nrows, ncolumns = size(df)
  label = String
  learned = false
  perceptron = Perceptron([],[])
  perceptron.w = rand(Float64,ncolumns)
  era = 1
  while !learned
    println("Training era ",era)
    globalError = 0.0
    
    for row in 1:nrows
      label = (convert(Array,df[row,1:1]))
      label = label[1]
      
      class = Float64
      label == target ? class = 1.0 : class = -1.0 
      
      if row != 1 || era != 1
        splice!(perceptron.x,1:ncolumns)
      end
      
      push!(perceptron.x,1) 
      append!(perceptron.x, convert(Array,df[row,2:ncolumns])) 
      response = get_response(perceptron.x,perceptron.w)
      
      if response != class
        iterError = class - response
        for i in 1:ncolumns
          perceptron.w[i] += eta * iterError * perceptron.x[i]
        end
        globalError += abs(iterError)   
      end
    end
    
    println("Era " , era ," finished, error: " , globalError)
    
    if globalError < 0.15 || era >= eras
      println("Label " , target ," learned in ", era , " eras")
      saveTrain(target, perceptron.w)
      learned = true
    end
    
    println("-------------------------------------------------")
    era += 1
    
  end
end

function delta_rule(df,target,eta,eras)
  nrows, ncolumns = size(df)
  label = String
  learned = false
  perceptron = Perceptron([],[])
  perceptron.w = rand(Float64,ncolumns)
  era = 1
  while !learned
    println("Training era ",era)
    globalError = 0.0
    deltaw[] = 0 * rand(Float64,ncolumns)
    for row in 1:nrows
      label = (convert(Array,df[row,1:1]))
      label = label[1]
      
      class = Float64
      label == target ? class = 1.0 : class = -1.0 
      
      if row != 1 || era != 1
        splice!(perceptron.x,1:ncolumns)
      end
      
      push!(perceptron.x,1) 
      append!(perceptron.x, convert(Array,df[row,2:ncolumns])) 
      response = get_response(perceptron.x,perceptron.w)
      
      if response != class
        iterError = class - response
        for i in 1:ncolumns
          deltaw[i] += eta * iterError * perceptron.x[i]
        end
        globalError += abs(iterError)   
      end
    end
    
    for i in 1:ncolumns
      perceptron.w[i] += deltaw[i]
    end
    
    println("Era " , era ," finished, error: " , globalError)
    
    if globalError < 50 || era >= eras
      println("Label " , target ," learned in ", era , " eras")
      saveTrain(target, perceptron.w)
      learned = true
    end
    
    println("-------------------------------------------------")
    era += 1
    
  end
end

function saveTrain(label, w)
  iterator = 1
  
  outfile = string("train/",label,".csv")
  file = open(outfile, "w")
  
  for value in w 
    print(file, value)
    if iterator != length(w)
      print(file, ",")
      iterator += 1
    end
  end
  close(file)
end

function getTrainings()
  files = (readdir("train/"))
  
  train = Dict()
  
  for file in files 
    filename = splitext(file)
    filepath = string("train/",file)
    train_df = readtable(filepath, header = false)
    train_array = convert(Array, train_df)
    train[filename[1]] = train_array
  end
  
  return train
end

function getHit(class, example)
  example[1] = 1
  total = sum(class.*example)
  return total
end

function getLabel(train, example)
  example_array = convert(Array,example)
  
  major_acc = 0.0
  major_class = ""
  first = true
  for class in train
    
    hit = getHit(class[2], example_array)
    
    if first
      major_acc = hit
      major_class = class[1]
      first = false
    end
    if hit > major_acc
    end
  end

  return string(example[1]), major_class
end


function test(file)
  
  trainings = getTrainings()
  
  df = readtable(file, header = false)
  i = 1
  for row in eachrow(df)
    correct, attempt = getLabel(trainings, row)
    if correct != attempt
      println(i , " erro: ", correct ," ", attempt)
    end
    i += 1
  end
  
end




if length(ARGS) == 2
  if ARGS[1] == "train"
    df = readtable(ARGS[2], header = false)
    for i in 0:9
      training_rule(df,i,0.1,100)
    end
  elseif ARGS[1] == "test"
    test(ARGS[2])
  else
    println("README is calling you!!")
  end
  
else
  println("incorrect arguments, try run:")
  println("julia train data/fast_mnist_train.csv")
  println("for more info see the readme file, yes the file's name is README and I can't imagine the reason.")
end
