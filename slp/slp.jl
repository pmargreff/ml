using DataFrames  
@everywhere using DistributedArrays

# normalize the file for 0 and 1
# dataset is the dataframe with the values
# cut is 0 when is < then passed and 1 for others
function normalize(dataset, cut = 1)
  
  nrows, ncols = size(dataset)
  
  for row in 1:nrows
    for col in 2:ncols
      if dataset[row, col] < cut
        dataset[row, col] = 0 
      else
        dataset[row, col] = 1 
      end
    end
  end
  
  return dataset
end

# train the data
# df is the dataframe with normalized data (between 0 and 1)
# learning_rate is the learning rate value 0.01 if isn't defined
# target is the label to be train
@everywhere function train(df, value, learning_rate = 0.01, eras = 1000, max_err = 0.05)
  nrows, ncols = size(df)
  
  weights = rand_range(1.0, ncols)
  
  # for era in 1:eras
  era = 1
  global_err = 1
  
  # run while do not get total eras or have < 5% error
  while (era < eras) && (global_err > 0.05)
    # for era in 1:eras
    
    println(" - era: " , era)
    err = 0
    for row in 1:nrows
      
      output = calc_output(df[row,:], weights, ncols)
      guess = activation(output)
      
      # define if target is true
      target = -1 
      if value == df[row, 1]
        target = 1
      end
      
      # test if the guess is wrong
      local_error = 0
      local_error = target - guess
      
      # adjust the weights
      if local_error != 0
        err += 1
        weights = update_weights(weights, df[row, :], learning_rate, local_error, ncols)
      end
    end
    
    err != 0 ? global_err = err/nrows : global_err = 0
    era+=1
  end
  
  return weights
end

@everywhere function update_weights(weight, input, lr, err, size)
  
  input[1] = 1 #rewrite the bias in label place
  for i in 1:size
    weight[i] += input[i] * err * lr
  end
  
  return weight
end

# get the weights, the inputs and generate the output
@everywhere function calc_output(input, weight, size)
  output = 0
  input[1] = 1 #rewrite the bias in label place
  
  for i in 1:size
    output+= input[i] * weight[i]
  end
  
  return output
end

# generate a array with values between -limit and limit
@everywhere function rand_range(limit, ncols)
  signal = bitrand(ncols)
  rand_arr = rand(ncols,1)
  for i in 1:ncols 
    if signal[i] == false
      rand_arr[i] -= limit 
    end
  end  
  return rand_arr
end

@everywhere function activation(n)
  if n > 0
    return 1
  else
    return -1
  end
end

function has_one_rigth(activation_arr)
  arr = [] 
  for val in activation_arr
    if val == 1
      push!(arr, 1)
    end
  end
  
  if length(arr) == 1 
    return true
  end
  return false
end

function get_right_index(activation_arr)
  for i in 1:length(activation_arr)
    if activation_arr[i] == 1
      return i
    end
  end
end

function count_result(row, col, confusion_matrix)
  confusion_matrix[row,col] += 1
  
  return confusion_matrix
end

function get_better_candidate(inputs, weights)
  vectorial_product = inputs * weights[1,:]
  high_value = vectorial_product[1]
  high_index = 1
  
  for i in 2:size(weights,1)
    vectorial_product = inputs * weights[i,:] 
    if vectorial_product[1] > high_value
      high_value = vectorial_product[1]
      high_index = i
    end
  end
  
  return high_index - 1
end

function test(test_df, weights_dir)
  files = readdir(weights_dir)
  
  n_labels = length(files)
  weights = Array{Float64}(n_labels,size(test_df,2))
  confusion_matrix = zeros(n_labels, n_labels)
  row = 1
  
  # each row (represent a train label)
  for file in files 
    filepath = string(ARGS[3],file)
    weights[row,:] = Array(readtable(filepath, header = false))
    row+=1
  end
  
  for row in eachrow(test_df)
    activation_arr = Array{Int64}(n_labels)
    
    for i in 1:size(weights,1)
      if activation(calc_output(Array(row), weights[i,:], size(test_df,2))) == 1
        activation_arr[i] = 1
      else
        activation_arr[i] = 0
      end
    end
    
    if has_one_rigth(activation_arr)
      guess = get_right_index(activation_arr)
    else
      guess = get_better_candidate(Array(row), weights)
    end
    confusion_matrix = count_result(row[1]+1, guess, confusion_matrix)
    
  end
  
  return confusion_matrix
end

function main()
  if ARGS[1] == "normalize"    
    if length(ARGS) == 2
      
      df = readtable(ARGS[2], header = false)
      newdf = normalize(df)
      
      filename, fileformat = splitext(ARGS[2])
      newfilename = string(filename, "_normalized", fileformat)
      
      writetable(newfilename, newdf, header = false)
      
    elseif length(ARGS) == 3
      df = readtable(ARGS[3])
      newdf = normalize(df,ARGS[2])
      
      filename, fileformat = splitext(ARGS[3])
      newfilename = string(filename, "_normalized", fileformat)
      
      writetable(newfilename, newdf, header = false)
    end
  elseif ARGS[1] == "train"
    df = Array(readtable(ARGS[2], header = false))
    dir = string("output/",size(readdir("output"), 1))
    mkdir(dir)
    
    max = 1
    
    weights = @DArray [train(df, i) for i = 0:max];
    
    for i in 0:max 
      filename = string(dir,"/", string(i),".csv")
      writetable(filename, DataFrame(weights[i+1]), header = false)
    end
    
  elseif ARGS[1] == "test"
    test_df = readtable(ARGS[2], header = false)
    
    println(DataFrame(test(test_df, ARGS[3]))) 
  end  
end  

@time main()
