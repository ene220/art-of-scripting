# Run deseq2
library ("DESeq2")

countData <- read.table ("countData.txt", header=TRUE, row.names=1, sep="\t")    
dds <-  DESeqDataSetFromMatrix(countData, colData, design= ~ condition)
