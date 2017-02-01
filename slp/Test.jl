
module Test
using DataFrames

export test

function activation(n)
  if n > 0.5
    return true
  end
  return false 
end

function calc_output(input, weight, size)
  output = 0
  input[1] = 1 #rewrite the bias in label place
  
  for i in 1:size
    output+= input[i] * weight[i]
  end
  
  return output
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
  
  return high_index
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
      if activation(calc_output(Array(row), weights[i,:], size(test_df,2)))
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

end 
