# Annotates CNV for pTS and pHI score (among other intolerance scores), returns subject-level data frame.
# Subsequent results are used in generating Figure 2.

# Set data path
path <- '/Users/aa2227/Documents/pncCNV/clean'

# Load pakcages
library(tidyverse)

# Read Data -----
load(paste(path,'illumina.11feb.RData',sep = '/')) # This data comes from Exclusion_2.R
load(paste(path,'ploi.RData',sep = '/')) # 
phi <- read.csv(paste(path,'phi.csv',sep = '/'))

# Calculate oeuf Scores for Individual CNV's -----
ploi <- ploi %>% 
  filter(chromosome!="X" & chromosome!="Y") %>% # don't use sex chromosomes for this
  mutate(chromosome=as.numeric(chromosome))

with.phi <- merge(ploi,phi,by='gene')

no.phi <- ploi %>% 
  filter(gene %in% setdiff(ploi$gene,phi$gene)) %>% 
  mutate(pHI=as.numeric(0),pTS=as.numeric(0))

ploi <- rbind(with.phi,no.phi)

lof.data <- data.frame()

l.df <- length(cnv.data)+1 # the length of the cnv data frame, for adding annotations

# Initialize empty cols for annotations
cnv.data[,l.df] <- 0 
cnv.data[,l.df+1] <- 0
cnv.data[,l.df+2] <- 0 
cnv.data[,l.df+3] <- 0 
cnv.data[,l.df+4] <- 0

cnv.data <- ungroup(cnv.data)

ploi$ngenes <- 1 # each row of ploi = 1 gene

# The loop below subsets the CNV and ploi data into chromosomes, then tests whether each ploi gene falls completely within each CNV.
# If it does, the gene and its intolerance scores are saved and used to annotate the CNV.
for(chrome in 1:22){ # for each chromosome
  print(chrome)
  
  cnv.data.pli <- cnv.data %>% 
    filter(X.chr==chrome)
  
  ploi.loop <- ploi %>% # filter values so that only genes which potentially fall completely within a cnv are kept
    filter(chromosome==chrome) %>%
    filter(end_position <= max(cnv.data.pli$end.hg19.)) %>%
    filter(start_position >= min(cnv.data.pli$start.hg19.)) %>%
    select(start_position,end_position,oe_lof_upper,ngenes,pLI,pTS,pHI)
  
  for(each in 1:nrow(cnv.data.pli)){ # for each row in the cnv data
    cnv.location <- c(cnv.data.pli[each,'start.hg19.'],cnv.data.pli[each,"end.hg19."]) # set the start and stop base location of the current cnv
    condition <- ploi.loop[,1] >= cnv.location[1] & ploi.loop[,2] <= cnv.location[2] # test if a gene falls completely within the current cnv row (the deletion space)
    pli.temp <- as.data.frame(matrix(nrow = nrow(ploi.loop),ncol = 1)) # create a temporary genome sized data frame for each cnv loop around
    for(ij in 1:length(condition)){ # go through each row in the gene data
      if(condition[ij]){ # if condition is true (gene is within cnv)
        pli.temp[ij,1] <- 1/ploi.loop[ij,3]
        pli.temp[ij,2] <- ploi.loop[ij,4]
        pli.temp[ij,3] <- ploi.loop[ij,5]
        pli.temp[ij,4] <- ploi.loop[ij,6]
        pli.temp[ij,5] <- ploi.loop[ij,7]}} # then save the pLI value by inserting into the temp df
    cnv.data.pli[each,l.df] <- sum(pli.temp$V1,na.rm = T)
    cnv.data.pli[each,l.df+1] <- sum(pli.temp$V2,na.rm = T)
    cnv.data.pli[each,l.df+2] <- sum(pli.temp$V3,na.rm = T)
    cnv.data.pli[each,l.df+3] <- sum(pli.temp$V4,na.rm = T)
    cnv.data.pli[each,l.df+4] <- sum(pli.temp$V5,na.rm = T)} # after all 'true' genes saved get a final summed pLI score for the cnv
  lof.data <- rbind(lof.data,cnv.data.pli)}

cnv.data <- ungroup(cnv.data)

names(lof.data)[l.df] <- 'cnv.lof'
names(lof.data)[l.df+1] <- 'cnv.ngenes'
names(lof.data)[l.df+2] <- 'cnv.pLI'
names(lof.data)[l.df+3] <- 'cnv.pTS'
names(lof.data)[l.df+4] <- 'cnv.pHI'

non.cnv <- cnv.data %>% 
  filter(ChipID %in% setdiff(ChipID,lof.data$ChipID)) %>%
  rename(cnv.lof=V21,
         cnv.ngenes=V22,
         cnv.pLI=V23,
         cnv.pTS=V24,
         cnv.pHI=V25)

lof.data.v2 <- rbind(non.cnv,lof.data)

duplist <- c('3','4','3, 4','3, 5')

# set pTS for deletions = zero 
# and pHI for duplications = zero
pHIs <- lof.data.v2 %>% 
  filter(Type%in%duplist) %>% # pHI duplications = 0
  mutate(cnv.pHI=0) 

pTSs <- lof.data.v2 %>% 
  filter(!Type%in%duplist) %>% # pTS deletions = 0
  mutate(cnv.pTS=0) 

lof.data.v5 <- rbind(pHIs,pTSs)

subject.annotated <- lof.data.v5 %>% 
  group_by(cag_id) %>% 
  mutate(LOF=sum(cnv.lof,na.rm = T),
         Burden=sum(sizedel,na.rm = T)/1000000,
         ngenes=sum(cnv.ngenes),
         pLI=sum(cnv.pLI,na.rm = T),
         pTS=sum(cnv.pTS,na.rm = T),
         pHI=sum(cnv.pHI,na.rm = T),
         logLOF=log(LOF+1),
         logpLI=log(pLI+1)) %>% 
  distinct(cag_id,.keep_all = T) %>% 
  select(cag_id,LOF,Burden,ngenes,pLI,logLOF,logpLI,pTS,pHI)

save(subject.annotated,file = paste(path,'pTSpHI.cag.annotated.26feb.Rdata',sep = '/'))
