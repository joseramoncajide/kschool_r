###########################################################################
# @jrcajide
# search console
##########################################################################

# Cargamos la librerías necesarias
library(tidyverse)

install.packages("googleAuthR")
library(googleAuthR)

install.packages("searchConsoleR")
library(searchConsoleR)

install.packages("tm")
library(tm)

install.packages("wordcloud")
library(wordcloud)

# Autenticación
# scr_auth(token = 'sc.oauth')
scr_auth()

list_websites()

queries <- search_analytics("http://www.escuelainfantiltrazos.es/", 
                            startDate = Sys.Date() - 60, 
                            endDate = Sys.Date() - 3, 
                            dimensions = c("query","page","country"),
                            dimensionFilterExp = c("country==esp"),
                            searchType=c('web'), 
                            rowLimit = 5000) 

queries_df <- queries %>% 
  as_tibble() %>%  
  arrange(desc(clicks))

# write_csv(queries_df, paste0("data/gsc_data_",Sys.Date() - 3, ".csv"))
# queries_df <- read_csv('./data/gsc_data_2020-03-12.csv')


# Text mining -------------------------------------------------------------

corpus <- Corpus(VectorSource(queries_df$query))
dtm <- TermDocumentMatrix(corpus)

freq <- colSums(as.matrix(dtm))   

findFreqTerms(dtm, 10)

findAssocs(dtm, "infantil", corlimit=0.15)

set.seed(4363)
m = as.matrix(dtm)
v = sort(rowSums(m), decreasing = TRUE)
wordcloud(names(v), v, min.freq = 50)
wordcloud(names(v), colors=c(3,4), random.color=FALSE, freq, min.freq=2)
