global absPath, file = splitdir(@__FILE__())

dir = string(absPath,"/classification.csv")
df = readtable(dir)
newdf = by(df,:label, nrow)

println(newdf)
