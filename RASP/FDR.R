#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)
df = read.table(args[1],header=TRUE)
df$pAdjust = p.adjust(df$pValue,"BH")
df = df[,c('FeatureName','ReadCount','pValue','pAdjust','FeatureOccurence',"CummulativeLength",'FeatureMeanLength','MeanShufReadCount')]
write.table(df,file=args[2],row.names=FALSE,quote = FALSE,sep ="\t")