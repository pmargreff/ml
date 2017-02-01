
module Utils
using DataFrames  
  export normalize_df

  # normalize the file for 0 and 1
  # dataset is the dataframe with the values
  # cut is 0 when is < then passed and 1 for others
  function normalize_df(dataset, cut = 1)
    
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

end  
