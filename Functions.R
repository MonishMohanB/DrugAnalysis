######################################################################################################
######   THIS FILE IS HAVING ALL THE NECESSARY FUNCTIONS NEEDED FOR YOUR DRUG ANALYSIS     ###########
#########   RUN THIS WHOLE FILE TO MOVE FUNCTIONS TO THE RSTUDIO ENVIRONMENT  ########################
###     Note: Edit the positive and negative folder path as per your working location    #############
######################################################################################################


#moving the input from table to data frame
input <- read.csv(file ="inputTableFinal.csv",sep = ",",stringsAsFactors=FALSE)

#Loading the positive and negative words into the working environmen
## Need to update based on your location
pos.words <- scan('C:/Users/monis/Pictures/Capstone Project R/druganalysisLocal/positive-words.txt',
                  what='character', comment.char=';') #folder with positive dictionary
neg.words <- scan('C:/Users/monis/Pictures/Capstone Project R/druganalysisLocal/negative-words.txt', 
                  what='character', comment.char=';') #folder with negative dictionary

######################################################################################################
################################   Twitter Score Function  ######################################
######################################################################################################

TwitterScoreFunction <-function(){#not having any parameter input
  #calling the data cleaning function for input data frame
  output1 <- TwitterDataCleaningFunc()
  #Calling the score function to obtain the scores for the twitter text
  outputWithScores <- score.sentiment(output1$text, pos.words, neg.words, .progress='text')
  #combining the scores with the data frame
  finalOutput <- cbind(output1,outputWithScores)
  return(finalOutput)
}


######################################################################################################
################################   Twitter Collection Function  ######################################
######################################################################################################

#search term parameter represent the drug name in our input table
TwitterCollectionFunc<- function(searchterm){
  #calling the twitter api through searchTwitter function with launguage "en"
  list <- searchTwitter(searchterm,  n=100, lang = "en")
  #if there is no tweet regarding the particular drug return
  if(length(list) == 0) {
    return()
  }
  #converting the obtained twitter list to data frame
  df <- twListToDF(list)
  return(df)
}
######################################################################################################
############################### Twitter Data Cleaning Function  ######################################
######################################################################################################

TwitterDataCleaningFunc<- function(){
  datalist = list()#creating empty list
  for (i in 1:nrow(input)) {
    #calling the twitter collection function for all the drug names available in your database
    a<- TwitterCollectionFunc(input$drugName[i])
    #adding drug name column to your output
    a$drugName <- input$drugName[i]
    datalist[[i]] <-a
  }
  #To combine all collected data for different drugs
  big_data = do.call(rbind, datalist)
  #To remove duplicates
  big_data <- subset(big_data, !duplicated(big_data$text))
  #selecting only columns what we need #omiting unused columns
  final_data<- big_data[ , which(names(big_data) %in% c("favoriteCount","created","id",
                                                        "retweetCount","text","drugName"))]
  #ordering the data frame output
  df <- final_data[, order(names(final_data))]
  #updating the data format into %Y-%m-%d
  df$created <- strftime(df$created, '%Y-%m-%d')
  df$text <- lemmatize_strings(df$text, dictionary = lexicon::hash_lemmas,..)
  return(df)
  
}



######################################################################################################
#########################   SENTIMENT FUNCTION FOR REVIEW ANALYSIS  ##################################
######################################################################################################


score.sentiment = function(sentences , pos.words, neg.words , .progress='none')
{
  require(plyr)#necessary packages for string operations
  require(stringr)
  #function for determining sentiments
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
  #calling function to calculate sentiment by our seperate function
  w <- TwitterScoreFunction()
  #calculate the sentiment through the RSENTIMENT package using calculate_sentiment function
  senti <- calculate_sentiment(w$text)
  #create empty data frame
  s1<-data.frame()
  #adding sentiment values to the output data frame
  sentimentOfText<- senti$sentiment
  output <- cbind(w,sentimentOfText)
  #converting all to character
  output$sentimentOfText <- as.character(output$sentimentOfText)
  #subtituting the rating value positive-1,very positive-2,neutral-3,negative--1,very Negative- -2;
  output$sentimentOfText[output$sentimentOfText == "Positive"] <- "1"
  output$sentimentOfText[output$sentimentOfText == "Very Positive"] <- "2"
  output$sentimentOfText[output$sentimentOfText == "Negative"] <- "-1"
  output$sentimentOfText[output$sentimentOfText == "Very Negative"] <- "-2"
  output$sentimentOfText[output$sentimentOfText == "Neutral"] <- "0"
  output$sentimentOfText <- as.numeric(output$sentimentOfText)
  #Normalizing the favourite count and retweer count using min and max functions
  a<- max(output$favoriteCount)
  b<- min(output$favoriteCount)
  ifelse(a==0,output$normFavcount<-as.numeric("0"),output$normFavcount <- with(output, (output$favoriteCount-b)/a ))

  
  c<- max(output$retweetCount)
  d<- min(output$retweetCount)
  ifelse(a==0,output$normRetcount<-as.numeric("0"),output$normRetcount <- with(output, (output$retweetCount-d)/c ))
  
  #sum of the normalized outputs for 2w(0)+w(1)+1
  output$sum<- (2*output$normRetcount)+(output$normFavcount)+1
  #multiplying with sentiment score (  2w(0)+w(1)+1  * rating    )
  output$normalizedRating <-  (output$sum*output$sentimentOfText)
  
  output$Rating<-output$normalizedRating
  #rescaling the output to the scale of 0 to 5.
  output$Rating<- rescale(output$normalizedRating, to = c(0, 5), from = range(output$normalizedRating, na.rm = TRUE, finite = TRUE))
  
  
  return(output)
}

############################################################################################################
##########################################     Main function     ###########################################
############################################################################################################


DrugAnalysisFunction <-function(){
  #calling the sentiment function to obtain final social media rating
  w<- TwitterSentimentAnalysisFunction()
  
  ## if needed include round command for w$Rating
  #creating unique id for unique users and 
  w2 <- transform(w, user=match(id, unique(id)))
  w3 <- transform(w2,item=match(drugName, unique(drugName)))
  ##selecting appropriate rows needed for the recommendation part.
  final_data<- w3[ , which(names(w3) %in% c("user","item","Rating"))]
  return(final_data)
}


############################################################################################################
#################     POPULARITY BASED RECOMMENDATION SYSTEM     ###########################################
############################################################################################################


PopularityDrugRec <-function(){
  #below function gets the data frame with three columns user,item and rating
  ratings<-DrugAnalysisFunction()
  #changing th column name of the above function output to make it best for recommenderlab functions
  names(ratings)[names(ratings) == 'Rating'] <- 'rating'
  #convering rating file into matrix with rows as users and columns as items with the value of ratings
  ratingmat <- dcast(ratings, user~item, value.var = "rating", na.rm=FALSE)
  ratingmat <- as.matrix(ratingmat[,-1]) #remove userrow at first column in above frame
  #Convert rating matrix into a recommenderlab sparse matrix
  ratingmat <- as(ratingmat, "realRatingMatrix")
  #Create Recommender Model. "POPULAR" stands for POPULARITY BASED Filtering
  recommender_model <- Recommender(ratingmat[1:nrow(ratingmat)], method = "POPULAR")
  ############Create predictions#############################
  recom <- predict(recommender_model, ratingmat[1:nrow(ratingmat)],n=ncol(ratingmat))
  #########Converting output into matrix
  recom_list <- as(recom, "matrix")
  recom_list <-as.data.frame(recom_list)
  #Taking the column mean for all the items
  a<- colMeans(x=recom_list, na.rm = TRUE)
  #copnvering above list into the matrix
  b<- as.matrix(a)
  #selection of drugs whose rating greatr than the mean
  rows <- which(b > mean(b))
  #obtining drug name from the input data frame
  f<- input[rows,2]
  
  return(as.data.frame(f))
}

############################################################################################################
####################     CONTENT BASED RECOMMENDATION SYSTEM     ###########################################
############################################################################################################


ContentDrugRec <-function(){
  #user interactive box to uget the user input
  i1<-menu(c("1. OTC- Over the Counter", "2. Rx/OTC- Prescription or Over the Counter"),
           graphics = TRUE, title="Type of Drug do you need")
  #User interactive box to get the pregnency level from the user
  i2<-menu(c("1.A ", "2.B","3.C ", "4.D","5.X","6.N"),
           graphics = TRUE, title="select the pregnency level")
  #forming the user profile based on the user inputs to fill with zeros and ones
  i<- input[,-c(1,2)] 
  ui <-data.frame(matrix(NA, nrow = 1, ncol = ncol(i)))
  colnames(ui) <- colnames(i)
  switch(i1,
         m = {
           ui$OTC<-1
         },
         m = {
           ui$OTC<-1
           ui$bothRxOTC<-1
         }
  )
  #below switch statemnet for pregenency level update
  switch(i2,
         m = {
           ui$PregA<-"1"
         },
         m = {
           ui$PregA<-"1"
           ui$PregB<-"1"
         },
         m = {
           ui$PregA<-"1"
           ui$PregB<-"1"
           ui$PregC<-"1"
         },
         m = {
           ui$PregA<-"1"
           ui$PregB<-"1"
           ui$PregC<-"1"
           ui$PregD<-"1"
         },
         m = {
           ui$PregA<-"1"
           ui$PregB<-"1"
           ui$PregC<-"1"
           ui$PregD<-"1"
           ui$PregX<-"1"
         },
         m = {
           ui$PregA<-"1"
           ui$PregB<-"1"
           ui$PregC<-"1"
           ui$PregD<-"1"
           ui$PregX<-"1"
           ui$PregN<-"1"
         }
  )
  #filling the remaining values with zeros in user profile
  ui[is.na(ui)] <- 0
  sim_mat <- rbind.data.frame(ui, i)
  #converting all the matrix into integers to calculate the similarity
  sim_mat <- data.frame(lapply(sim_mat,function(x){as.integer(x)})) #convert data to type integer
  sim_results <- dist(sim_mat, method = "cosine")
  sim_results <- as.data.frame(as.matrix(sim_results[1:nrow(i)]))
  #selection of top level of drugs which matches with user selection
  rows <- which(sim_results > mean(sim_results$V1))
  return(input[rows,2])
  
}

############################################################################################################
####################     CONTENT BASED RECOMMENDATION SYSTEM     ###########################################
############################################################################################################

RunApplication<-function(){
  
  #forobtaining the drugs which matches with the user preferences
  output1 <- ContentDrugRec()
  #converting the output to data frame
  output1 <- as.data.frame(output1)
  #calling the popularity based recommendation function to select the top level rated drugs
  output2 <- PopularityDrugRec()
  colnames(output1)<- colnames(output2)
  #combining both the recommendation system drug output
  finaloutput <- rbind(output1,output2) # rbind-combining the results 
  finaloutput1 <-as.data.frame(table(finaloutput)) #table function returning the output frequency values
  finaloutput2 <- finaloutput1[finaloutput1$Freq==2,] #returning the high freuent values: bg is two times
  finaloutput3 <- finaloutput2$finaloutput #obtaining DRUG names on the data frame
  finaloutput4 <- as.data.frame(finaloutput3)
  finaloutput5<-finaloutput4$finaloutput3
  #final output is a drug name having more users rating and matches user preference the most
  return(finaloutput5)
  
}




