using DataFrames

df = readtable("capes_disc.csv")

test = deepcopy(DataFrame(df))
training = deepcopy(DataFrame(df))

rows, cols = size(df)

# create training and tests csv
for i = 1:rows
  if i % 4 == 0
    deleterows!(training,rows - i + 1)
  else
    deleterows!(test,rows - i + 1)
  end
end

writetable("capes_disc_training.csv",training)
writetable("capes_disc_test.csv",test)
