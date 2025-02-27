##-----------------------------------------------------------------
## hm_bingo.R (heatmap bingo) is an Rscript used to 
## read in BiNGO GO enrichment results and generate a heatmap used in
## "De novo assembly of the green ash transcriptome and 
## identification of genes responding to abiotic and biotic stress"
## Lane et. al. 2015
##
## hm_bingo.R assumes a directory in home called "hm_bingo" exists
## hm_bingo.R also assumes a sub-directory in home called bgo
## exists and contains headless output from BiNGO. 
##
## Headless output from BiNGO can be generated by saving output from BiNGO
## and parsing out all lines that begin with "GO-ID". For example using grep:
## $ grep "^GO-ID" ColdOUTPUT.bgo > headless_ColdOUTPUT.bgo
##
## hm_bingo.R will create a three output Tiff files "Figure5_all.tiff,"
## "Figure5A_up.tiff," and "Figure5B_down.tiff"
##

##--------------------------
## Load required packages
##--------------------------
require(gplots)
require(RColorBrewer)
library(plyr)

##--------------------------
## Readtable function
##--------------------------
read_tsv_filename <- function(filename){
  ret <- read.table(filename, colClasses = c(
    "NULL", "numeric", "NULL", "NULL", "NULL", "NULL", "NULL", "character", "NULL"), header=FALSE, sep="\t")
  ret$Source <- filename #EDIT
  ret
}

##--------------------------
## Heatmap function
##--------------------------
heat <- function(matrix, name) {
  colfunc1 <- colorRampPalette(c("darkgreen", "green" ,"white"))
  hmcols <- c(colfunc1(200))
  tiff(name, width = 10, height = 10, units = 'in', res = 100)
  heatmap.2(as.matrix(matrix),
            scale="none",
            col=hmcols,
            trace="none",
            rowsep=(1:62), 
            colsep=(1:62), 
            sepcolor="grey",
            sepwidth=c(0.05,0.05),
            cexCol=0.8, 
            cexRow=0.8,
            srtRow=0,
            dendrogram="none",
            Rowv=FALSE,
            Colv=FALSE,
            keysize=1,
            margins=c(15,25)
  )
  dev.off()
}

# load data
setwd("~/hm_bingo/bgo/")
sampleFilesAll <- list.files()
sampleFilesUp <- grep("Up|Response",list.files(),value=TRUE)
sampleFilesDw <- grep("Down|Response",list.files(),value=TRUE)

# read data into a dataframe
datasetAll <- ldply(sampleFilesAll, read_tsv_filename)
datasetUp <- ldply(sampleFilesUp, read_tsv_filename)
datasetDw <- ldply(sampleFilesDw, read_tsv_filename)

# transform into a matrix all
matAll <- daply(datasetAll, .(V8, Source), function(x) x$V2)
matUp <- daply(datasetUp, .(V8, Source), function(x) x$V2)
matDw <- daply(datasetDw, .(V8, Source), function(x) x$V2)
matAll[is.na(matAll)] <- 0.05
matUp[is.na(matUp)] <- 0.05
matDw[is.na(matDw)] <- 0.05

# reorder columns
matReOrder <- matAll[,c(9,10,7,8,5,6,15,16,13,14,11,12,3,4,1,2,17)]
matUpO <- matUp[,c(5,4,3,8,7,6,2,1,9)]
matDwO <- matDw[,c(5,4,3,8,7,6,2,1,9)]

# remove biological process
matNoBP <- matReOrder[-2,]
matUpO1 <- matUpO[-2,]
matDwO1 <- matDwO[-2,]

# remove molecular function
matNoMF <- matNoBP[-18,]
matUpO2 <- matUpO1[-16,]
matDwO2 <- matDwO1[-14,]

# generate heatmap
setwd("~/hm_bingo/")
heat(matNoMF, "Figure5_all.tiff")
heat(matUpO2, "Figure5A_up.tiff")
heat(matDwO2, "Figure5B_down.tiff")
