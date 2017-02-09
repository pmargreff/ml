module Train
export train, update_weights, sum_output, rand_range, sigmoid_activation, activation


function train(df, value, learning_rate = 0.01, eras = 1000, max_err = 0.05)
  nrows, ncols = size(df)
  
  weights = rand_range(1.0, ncols)
  
  era = 1
  global_err = 1
  
  # run while do not get total eras or have < max_err% error
  while (era < eras) && (global_err >= max_err)
    # for era in 1:eras
    
    println(" era: " , era)
    println("   global_err = " , global_err)
    err = 0
    for row in 1:nrows
      
      output = sum_output(df[row,:], weights, ncols)
      guess = activation(output)
      
      target = -1 
      if value == df[row, 1]
        target = 1
      end
      
      # test if the guess is wrong
      local_error = 0
      local_error = guess - target
      
      # adjust the weights
      if local_error != 0
        err += 1
        weights = update_weights(weights, df[row, :], -learning_rate, local_error, ncols)
      end
      println("     local_error   = " , local_error)
      println("     guess         = " , guess)
      println("     target        = " , target)
      println("     weights       = " , weights)
      
    end
    
    err != 0 ? global_err = err/nrows : global_err = 0
    era+=1
  end
  
  return weights
end

function update_weights(weight, input, lr, err, size)
  
  input[1] = 1 #rewrite the bias in label place
  for i in 1:size
    weight[i] += input[i] * err * lr
  end
  
  return weight
end

# get the weights, the inputs and generate the output
function sum_output(input, weight, size)
  output = 0
  input[1] = 1 #rewrite the bias in label place
  
  for i in 1:size
    output+= input[i] * weight[i]
  end
  
  return output/size
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

function sigmoid_activation(n)
  sig = 1.0 / (1 + exp(-n))
  return sig
end

end 
