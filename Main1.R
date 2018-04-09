input <- read.csv(file ="inputTableFinal.csv",sep = ",",stringsAsFactors=FALSE)
pos.words <- scan('C:/Users/monis/Pictures/Capstone Project R/druganalysisLocal/positive-words.txt',
                  what='character', comment.char=';') #folder with positive dictionary
neg.words <- scan('C:/Users/monis/Pictures/Capstone Project R/druganalysisLocal/negative-words.txt', 
                  what='character', comment.char=';') #folder with negative dictionary


######################################################################################################
################################   Twitter Score Function  ######################################
######################################################################################################

TwitterScoreFunction <-function(){
  output1 <- TwitterDataCleaningFunc()
  outputWithScores <- score.sentiment(output1$text, pos.words, neg.words, .progress='text')
  finalOutput <- cbind(output1,outputWithScores)
  return(finalOutput)
}


######################################################################################################
################################   Twitter Collection Function  ######################################
######################################################################################################

TwitterCollectionFunc<- function(searchterm){
  
  list <- searchTwitter(searchterm,  n=100, lang = "en")
  if(length(list) == 0) {
    return()
  }
  df <- twListToDF(list)
  return(df)
}
######################################################################################################
############################### Twitter Data Cleaning Function  ######################################
######################################################################################################

TwitterDataCleaningFunc<- function(){
  datalist = list()
  for (i in 1:nrow(input)) {
    a<- TwitterCollectionFunc(input$drugName[i])
    a$drugName <- input$drugName[i]
    datalist[[i]] <-a
  }
  #To combine all
  big_data = do.call(rbind, datalist)
  #To remove duplicates
  big_data <- subset(big_data, !duplicated(big_data$text))
  
  final_data<- big_data[ , which(names(big_data) %in% c("favoriteCount","created","id",
                                                        "retweetCount","text","drugName"))]
  
  df <- final_data[, order(names(final_data))]
  df$created <- strftime(df$created, '%Y-%m-%d')
  return(df)
  
}



######################################################################################################
#########################   SENTIMENT FUNCTION FOR REVIEW ANALYSIS  ##################################
######################################################################################################


score.sentiment = function(sentences , pos.words, neg.words , .progress='none')
{
  require(plyr)
  require(stringr)
  scores = laply(sentences,function(sentence,pos.words,neg.words)
  {
    sentence =gsub('[[:punct:]]','',sentence)
    sentence =gsub('[[:cntrl:]]','',sentence)
    sentence =gsub('\\d+','',sentence)
    sentence =gsub(" ?(f|ht)tp(s?)://(.*)[.][a-z]+", "", sentence)
    sentence=str_replace_all(sentence,"[^[:graph:]]", " ") 
    sentence=tolower(sentence)
    word.list=str_split(sentence,'\\s+')
    words=unlist(word.list)
    pos.matches=match(words,pos.words)
    neg.matches=match(words,neg.words)
    pos.matches = !is.na(pos.matches)   
    neg.matches = !is.na(neg.matches) 
    score=sum(pos.matches)-sum(neg.matches)
    return(score)
  },pos.words,neg.words,.progress=.progress)
  scores.df=data.frame(scores=scores)
  return(scores.df)
}

######################################################################################################
########################## Twitter Sentiment Analysis Function  ######################################
######################################################################################################

TwitterSentimentAnalysisFunction <-function(){
  w <- TwitterScoreFunction()
  senti <- calculate_sentiment(w$text)
  s1<-data.frame()
  sentimentOfText<- senti$sentiment
  output <- cbind(w,sentimentOfText)
  
  output$sentimentOfText <- as.character(output$sentimentOfText)
  output$sentimentOfText[output$sentimentOfText == "Positive"] <- "1"
  output$sentimentOfText[output$sentimentOfText == "Very Positive"] <- "2"
  output$sentimentOfText[output$sentimentOfText == "Negative"] <- "-1"
  output$sentimentOfText[output$sentimentOfText == "Very Negative"] <- "-2"
  output$sentimentOfText[output$sentimentOfText == "Neutral"] <- "0"
  output$sentimentOfText <- as.numeric(output$sentimentOfText)
  
  a<- max(output$favoriteCount)
  b<- min(output$favoriteCount)
  output$normFavcount <- with(output, (output$favoriteCount-b)/a )
  
  c<- max(output$retweetCount)
  d<- min(output$retweetCount)
  output$normRetcount <- with(output, (output$retweetCount-d)/c )
  
  output$sum<- (2*output$normRetcount)+(output$normFavcount)+1
  
  output$normalizedRating <-  (output$sum*output$sentimentOfText)
  
  output$Rating<-output$normalizedRating
  
  output$Rating<- rescale(output$normalizedRating, to = c(0, 5), from = range(output$normalizedRating, na.rm = TRUE, finite = TRUE))
  
  
  return(output)
}

