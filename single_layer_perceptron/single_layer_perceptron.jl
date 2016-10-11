using DataFrames

type Perceptron
  w :: Array{Float64,1}
  x :: Array{Float64,1}
end

function get_response(x, w, value)
  total = sum(x.*w) / 28 * 28
  0 < total ? res = value : res = total
  return total
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
      response = get_response(perceptron.x,perceptron.w, label)
      
      iterError = class - response
      globalError += iterError   
      
      for i in 1:ncolumns
        perceptron.w[i] += iterError * eta * perceptron.x[i]
      end
      
    end
    
    
    println("Era " , era ," finished, error: " , globalError)
    
    saveTrain(target, perceptron.w)
    if abs(globalError) < 0.0015 || era >= eras
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
  hit = 0
  for class in train
    
    hit = getHit(class[2], example_array)
    
    if first
      major_acc = hit
      major_class = class[1]
      first = false
    end
    if hit > major_acc
      major_acc = hit
      major_class = class[1]
    end
  end
  
  return string(example[1]), major_class
end


function test(file)
  
  trainings = getTrainings()
  
  results = DataFrame(corelation = 1:10,predict_0 = 1:10,predict_1 = 1:10, predict_2 = 1:10, predict_3 = 1:10, predict_4 = 1:10, predict_5 = 1:10, predict_6 = 1:10, predict_7 = 1:10, predict_8 = 1:10, predict_9 = 1:10)
  
  for i = 1:10, j = 2:11
    results[i,j] = 0
  end
  
  for i = 1:10, j = 1:1
    results[i,j] = i - 1
  end
  
  df = readtable(file, header = false)
  i = 1
  for row in eachrow(df)
    correct, attempt = getLabel(trainings, row)
    results[parse(Int64, attempt) + 1,parse(Int64, correct) + 2] += 1 
  end

  outfile = string("out/",string(now()),".csv")
  writetable(outfile, results)  
end


if length(ARGS) == 2
  if ARGS[1] == "train"
    df = readtable(ARGS[2], header = false)
    for i in 1:9
      delta_rule(df,i,0.005,25)
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
