using DataFrames  


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
function train(df, target, learning_rate = 0.01)
  nrows, ncols = size(df)
  
  for row in 1:nrows
    weights = rand_range(1.0,ncols)
    output = 0
    output += 1 * weights[1] # bias
    
    for col in 2:ncols 
      output += df[row, col] * weights[col]
    end
    
    guess = activation(output)
    
    local_error = 0
    #test if the guess is wrong
    if guess == 1 && df[row,1] != target
      local_error = 2
    elseif guess == -1 && df[row,1] == target
      local_error = -2
    end
    
    #adjust the weights
    weights[1] += 1 * local_error * learning_rate
    
    if local_error != 0
      for col in 2:ncols 
        weights[col] += df[row, col] * local_error * learning_rate
      end
    end
    
  end

  return weights
end

# generate a array with values between -limit and limit
function rand_range(limit, ncols)
  signal = bitrand(ncols)
  rand_arr = rand(ncols,1)
  for i in 1:ncols 
    if signal[i] == false
      rand_arr[i] -= limit 
    end
  end
  
  return rand_arr
end

function activation(n)
  if n > 0
    return 1
  else
    return -1
  end
end

function main()
  if ARGS[1] == "normalize"    
    if length(ARGS) == 2
      
      df = readtable(ARGS[2])
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
    df = readtable(ARGS[2])
    @time train(df, 1, 0.05)
  end
end  

main()
