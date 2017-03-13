###########################################################################
# @jrcajide, 2017-03
# search console
##########################################################################

# Cargamos la librerías necesarias
list.of.packages <- c("tidyverse","googleAuthR", "searchConsoleR", "tm" , "wordcloud")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only = TRUE)

scr_auth(new_user = TRUE)

list_websites()

start <- Sys.Date() - 60

end <- Sys.Date() - 3 

download_dimensions <- c("query","page","country")

type <- c('web')


queries <- search_analytics("http://www.pasonoroeste.com/", 
                            startDate = start, 
                            endDate = end, 
                            dimensions = download_dimensions,
                            dimensionFilterExp = c("device==DESKTOP","country==esp"),
                            searchType="web", rowLimit = 5000)

queries <- as_data_frame(queries)

queries <- queries %>%  arrange(desc(clicks))

queries %>% View()

# write.csv(queries, paste0("06-Google-Search-Console-API/data/gsc_data_",start, ".csv"), row.names = F)
# queries <- read_csv("06-Google-Search-Console-API/data/gsc_data_2017-02-08.csv")


# Text mining -------------------------------------------------------------

corpus <- Corpus(VectorSource(queries$query))
dtm <- TermDocumentMatrix(corpus)

freq <- colSums(as.matrix(dtm))   
length(freq)   
findFreqTerms(dtm, 10)
findAssocs(dtm, "viajar", corlimit=0.15)

set.seed(4363)
m = as.matrix(dtm)
v = sort(rowSums(m), decreasing = TRUE)
wordcloud(names(v), v, min.freq = 50)
wordcloud(names(v), colors=c(3,4), random.color=FALSE, freq, min.freq=2)
