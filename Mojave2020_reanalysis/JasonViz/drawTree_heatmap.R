# load libs
library(pacman)
library(dplyr)
library(tidyverse)
library(ggtree)
library(treeio)
library(RColorBrewer)
library(viridis)
library(cowplot)
library(phytools)


# use current directory instead
#setwd("/bigdata/stajichlab/shared/projects/BioCrusts/MossCrust/Mojave2020_reanalysis/Mort_tree_visualization")
########## MAKE TREE ##########
# read in tree

#tree_ASV <- read.newick("Mojave2020.Mort.muscle.fasaln.clipkit.treefile")
#tree_ASV <- root(tree_ASV, c("ASV7634.105","ASV17349.6","Modicella_albostipitata_PDD_96330","ASV6702.56"),resolve.root=TRUE)

tree_ASV <- read.newick("Mojave2020.Mort.muscle.fasaln.clipkit.2.tre")

#tree_ASV %>% as_tibble()
tipnames <- tree_ASV$tip.label
tipnames
t<-ggtree(tree_ASV, layout="rectangular") + geom_tiplab(size=4, color="black")
print(t)
# extract order of samps in tree, top to bot, this will be used to reorder rows
# of the heatmap
# created ASVs which aren't ASV123 but ASV123.100 where .100 is the sum abundance for the ASV

## DANGER the labels on the tree don't match the labels in ord, so we need
## to make them match!!! After they match we can reorder the data
### process tree tip names to match ASV identifiers

ord<-tibble(name=get_taxa_name(t) ) %>% mutate(lab = str_replace(name,"(ASV\\d+).\\d+$","\\1"))

########## MAKE HEATMAP ##########
# Read in heatmap data
matrix <- read_tsv("Mojave2020_KKelly202307.ASVs.otu_table.taxonomy.txt") %>% select(-c(Taxonomy))
matrix
# making heatmap table
## wide to long and then back to wide (why are you doing this?)
mat <- matrix %>%
  pivot_longer(cols = !(label), names_to = "category", values_to = "value")
mat <- matrix %>% column_to_rownames('label')
## log trans mat, then go back to long
trans_mat2 <- log(mat + 1) %>% as_tibble(rownames = 'label') %>%
  pivot_longer(cols = !(label), names_to = "category", values_to = "value")

## to reorder the rows in heatmap, set as factor and reorder factor by ord!
## check that the labels match...
table(trans_mat2$label %in% ord$lab)

ord<-as.data.frame(ord)

### process heatmap row labels
#trans_mat2$lab<-sapply(strsplit(trans_mat2$label,"."), `[`, 1)
## match the rows between the tree and heatmap
## fix the heatmap
### filter the three samples not found present in the tree
trans_mat2<-trans_mat2[trans_mat2$label %in% ord$lab,]
## add blank values for samples in the tree but we don't have data for
nodat<-ord[!ord$lab %in% trans_mat2$label,]
### there are many duplicates with the previous label parsing since we cut by "_",
### so fix this and pull those samps again
#ord$label<-ifelse(grepl("'", ord$label), ord$ord, ord$label)
#nodat<-ord[!ord$label %in% trans_mat2$label,]
### cool works now, so let's construct the rows to add to the heatmap
nodat<-as.data.frame(expand.grid(nodat$lab, unique(trans_mat2$category)))
names(nodat)<-c("label", "category")
nodat$value<-NA
nodat$lab<-nodat$label
trans_mat2<-as.data.frame(rbind(trans_mat2, nodat))
### check that all are present (YES!)
table(trans_mat2$label %in% ord$lab)
length(unique(trans_mat2$label))
length(unique(ord$lab))
## now to figure out the ordering of the vars in trans_mat2 which correspond to
## the rows and cols of the heatmap!
### for the rows, use the order of tips from the tree
trans_mat2$label<-factor(trans_mat2$label, levels=rev(ord$lab))
### for the cols, need to pull order from metadata table!
meta<-read_tsv("Mojave2020.2023.metadata") # note this is TSV separated

### key col is Sample.ID (will rename), Sample.description is label
names(meta)[1:2]<-c("category", "lab2")
meta<-meta[meta$category %in% trans_mat2$category,]
trans_mat2<-merge(trans_mat2, meta, by="category", all.x=T)
trans_mat2$lab2<-factor(trans_mat2$lab2, levels=meta$lab2)

## plot the heatmap
hmap<-trans_mat2 %>% ggplot(aes(x = lab2, y = label)) +
  geom_tile(aes(fill=value)) + scale_fill_viridis_c(na.value="white") +
  theme_minimal() + xlab(NULL) + ylab(NULL) +
  scale_y_discrete(position = 'right') +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
hmap
########## PUT IT ALL TOGETHER ##########
fig<-plot_grid(t, hmap, ncol = 2)
ggsave(filename = "gheatmap_mod.pdf", fig, height=18, width=48)
