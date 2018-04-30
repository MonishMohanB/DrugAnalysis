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
install.packages("recommenderlab")
install.packages("recosystem")
install.packages("data.table")
install.packages("ggplot2")
install.packages("textstem")


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
library(data.table)
library(ggplot2)
library(textstem)

######################################################################################################
#########################     TWITTER AUTHENTICATION PROCESS      ####################################
######################################################################################################

require("ROAuth")#ROAUTH for twitter permissions
require("RCurl")
download.file(url="http://curl.haxx.se/ca/cacert.pem",destfile="cacert.pem")

###### MY KEYS for twitter access#######################################
t_consumer_key<-	'JALgcUhEQKGP3N1JXcg5oxJ4O'
t_consumer_secret<- 'GGqQsh0mHNNLqVKu9DF0rQs6PmFfEwwOCzJLZKHnlH5lLNoZSh'
t_access_token<-	'958495952041627649-63gHmzaZRdBnQM6p2UhRlKVNZcFd1pP'
t_access_secret <-	'rUbpZgVGj8gF5Uz6uN6GnWWb88JcRzxi2nXJ7OWCbQ36i'
#To establish the twitter connection
setup_twitter_oauth(t_consumer_key,t_consumer_secret,t_access_token,t_access_secret)
#Run application to get the final result
w<-RunApplication()
readline("Suggestion list of DRUGS based on your input")
#display the final suggestion drugs
print(w, max.levels = 0)














