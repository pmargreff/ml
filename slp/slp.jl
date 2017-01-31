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
@everywhere function train(df, value, learning_rate = 0.01, eras = 100)
  nrows, ncols = size(df)
  
  weights = rand_range(1.0, ncols)
  
  for era in 1:eras
    println(" - era: " , era)
    err_count = 0
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
        weights = update_weights(weights, df[row, :], learning_rate, local_error, ncols)
      end
      
    end
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
  output = (sum(input .*weight)) / size
  
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
    weights = @DArray [train(df, i, 0.05, 100) for i = 0:1];
    # println(weights)
    # @spawn for i in 0:1
    # weights = DataFrame(train(df, i, 0.05, 100))
    # fetch(weights)
    # end 
    for i in 0:1 
      filename = string(dir,"/", string(i),".csv")
      writetable(filename, DataFrame(weights[i+1]), header = false)
    end
    
  elseif ARGS[1] == "test"
    test_df = readtable(ARGS[2])
    weight_df = readtable(ARGS[3])
    
    
  end
end  

@time main()
