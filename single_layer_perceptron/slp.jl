using DataFrames  


# normalize the file for 0 and 1
# 0 value for value < than cut passed and 1 for others
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
  end

end  

main()
