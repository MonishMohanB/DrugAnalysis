#####################################################################################################################
#####################      BEFORE EXECUTING THIS FILE GO TO Main1.R and run it ######################################
#####################################################################################################################


######################################################################################################
######################### NEEDED PACKAGES FOR THE OVERALL PROCESS ####################################
######################################################################################################

install.packages("tm")
install.packages("wordcloud")
install.packages('base64enc')
install.packages('ROAuth')
install.packages('plyr')
install.packages('stringr')
install.packages('twitteR')
install.packages("SnowballC")
install.packages("RCurl")
install.packages("purrr")
install.packages("dplyr")
install.packages('RSentiment')
install.packages('scales')
install.packages('reshape2')
install.packages("RColorBrewer")


library(scales)
library(RSentiment)
library(RColorBrewer)
library(wordcloud)
library(tm)
library(twitteR)
library(ROAuth)
library(plyr)
library(stringr)
library(base64enc)
library(wordcloud)
library(SnowballC)
library(RCurl)
library(purrr)
library(dplyr)
library(reshape2)

library(recommenderlab)
library(recosystem)
library(SlopeOne)
library(SVDApproximation)
library(data.table)
library(RColorBrewer)
library(ggplot2)

######################################################################################################
#########################     TWITTER AUTHENTICATION PROCESS      ####################################
######################################################################################################

require("ROAuth")
require("RCurl")
download.file(url="http://curl.haxx.se/ca/cacert.pem",destfile="cacert.pem")


t_consumer_key<-	'JALgcUhEQKGP3N1JXcg5oxJ4O'
t_consumer_secret<- 'GGqQsh0mHNNLqVKu9DF0rQs6PmFfEwwOCzJLZKHnlH5lLNoZSh'
t_access_token<-	'958495952041627649-63gHmzaZRdBnQM6p2UhRlKVNZcFd1pP'
t_access_secret <-	'rUbpZgVGj8gF5Uz6uN6GnWWb88JcRzxi2nXJ7OWCbQ36i'


setup_twitter_oauth(t_consumer_key,t_consumer_secret,t_access_token,t_access_secret)




input <- read.csv(file ="inputTableFinal.csv",sep = ",",stringsAsFactors=FALSE)
pos.words <- scan('C:/Users/monis/Pictures/Capstone Project R/druganalysisLocal/positive-words.txt',
                  what='character', comment.char=';') #folder with positive dictionary
neg.words <- scan('C:/Users/monis/Pictures/Capstone Project R/druganalysisLocal/negative-words.txt', 
                  what='character', comment.char=';') #folder with negative dictionary

w<-RunApplication()
readline("Suggestion list of DRUGS based on your input")
print(w, max.levels = 0)














