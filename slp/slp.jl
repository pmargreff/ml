using DataFrames  

include("./Utils.jl")
using Utils

include("./Test.jl")
using Test

@everywhere include("./Train.jl")
@everywhere using Train
  
@everywhere using DistributedArrays

function main()
  if ARGS[1] == "normalize"    
    if length(ARGS) == 2
      
      df = readtable(ARGS[2], header = false)
      newdf = normalize_df(df)
      
      filename, fileformat = splitext(ARGS[2])
      newfilename = string(filename, "_normalized", fileformat)
      
      writetable(newfilename, newdf, header = false)
      
    elseif length(ARGS) == 3
      df = readtable(ARGS[3])
      newdf = normalize_df(df,ARGS[2])
      
      filename, fileformat = splitext(ARGS[3])
      newfilename = string(filename, "_normalized", fileformat)
      
      writetable(newfilename, newdf, header = false)
    end
  elseif ARGS[1] == "train"
    df = Array(readtable(ARGS[2], header = false))
    dir = string("output/",size(readdir("output"), 1))
    mkdir(dir)
    
    max = 9
    
    weights = @DArray [train(df, i, 0.005, 1000, 0.005) for i = 0:max];
    
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
