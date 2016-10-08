using DataFrames

type Perceptron
  w :: Array{Float64,1}
  x :: Array{Float64,1}
end

function sum_values(x,w)
  total = 0.0

  for i in 1:length(x)
    total += x[i] * w[i]
  end
  return total 

end

function get_response(x, w)
  total = sum_values(x,w)
  0 < total ? res = 1.0 : res = -1.0
  return res
end

function train(df,target,eta,eras)
  
  nrows, ncolumns = size(df)
  
  learned = false
  perceptron = Perceptron([],[])
  perceptron.w = rand(Float64,ncolumns)
  era = 1
  while !learned
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
    
    if globalError == 0.0 || era > eras
      println("Perceptron weights: " ,perceptron.w)
      println("Learned in ", era , " eras")
      learned = true
    end

  end
end


df = readtable("data/fast_mnist_train.csv", header = false)
train(df,1,0.1,1000)
