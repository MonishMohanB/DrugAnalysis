
######################################################################################################
######################### NEEDED PACKAGES FOR THE OVERALL PROCESS ####################################
######################################################################################################

install.packages("RColorBrewer")
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
library(tm)
library(RCurl)
library(purrr)
library(dplyr)


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



