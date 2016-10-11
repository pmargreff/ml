using DataFrames

df = readtable("data/mnist_test.csv", header = false)
nrows, ncolumns = size(df)

for i in 1:nrows
  for j in 2:ncolumns
    if df[i,j] > 0
      df[i,j] = 1 
    end
  end 
end 

writetable("data/mnist_test_normalized.csv", df, header = false)
