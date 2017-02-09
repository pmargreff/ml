
module Test
using DataFrames

export test

function calc_output(input, weight, size)
  output = 0
  input[1] = 1 #rewrite the bias in label place
  
  for i in 1:size
    output+= input[i] * weight[i]
  end
  
  return output/size
end

function get_index(activation_arr)
  high = activation_arr[1]
  index = 1
  for i in 2:length(activation_arr)
    if activation_arr[i] > high 
      index = i
      high = activation_arr[i]
    end
  end
  
  return index
end

function count_result(row, col, confusion_matrix)
  confusion_matrix[row,col] += 1
  
  return confusion_matrix
end

function test(test_df, weights_dir)
  files = readdir(weights_dir)
  
  # get the total of trained labels
  labels_size = length(files)
  inputs_size = size(test_df,2)
  # create a confusion matrix
  confusion_matrix = zeros(labels_size, labels_size)
  
  # create a matrix for the weights
  # i = labels
  # j = inputs
  weights = Array{Float64}(labels_size,inputs_size)
  
  
  row = 1
  # get the weights for each trained label(each label is saved in a diferent file)
  for file in files 
    filepath = string(ARGS[3],file)
    weights[row,:] = Array(readtable(filepath, header = false))
    row+=1
  end
  
  # for each test example
  for row in eachrow(test_df)
    activation_arr = Array{Float64}(labels_size)
    test_example = Array(row)
    # for each label test in all trained perceptrons
    for i in 1:size(weights,1)
      activation_arr[i] = calc_output(test_example, weights[i,:], inputs_size)
    end
    
    # get the most excited guess 
    guess = get_index(activation_arr)
    confusion_matrix = count_result(row[1]+1, guess, confusion_matrix)
    
  end
  
  return confusion_matrix
end

end 
