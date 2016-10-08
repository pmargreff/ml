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

function train(df,target,eta,eras)
  
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
    
    era += 1
    println("Era " , era ," finished, error: " , globalError)
    
    if globalError < 0.15 || era >= eras
      println("Label " , target ," learned in ", era , " eras")
      saveTrain(target, perceptron.w)
      learned = true
    end
    
    println("-------------------------------------------------")
    
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
  
  for class in train 
    hit = getHit(class[2], example_array)
    if hit > major_acc
      major_acc = hit
      major_class = class[1]
    end
  end
  
  return example[1], parse(Int64,major_class)
  
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

df = readtable("data/fast_mnist_train.csv", header = false)

for i in 0:9
  train(df,i,0.1,100)
end

# test("data/fast_mnist_train.csv")
