library(shiny)
library(ggplot2)

mythical <- read.csv("data/mythical.csv")
m <- as.character(mythical[,1])

getCommunity <- function(S=10,N=1000,equalprob=T){
  if(S > 51) S <- 51 # right now we only have 26 species - each unique letter in the alphabet
  prob <- rep(1/S,S)
  if(!equalprob){
    Nx <- rpois( S, sample(1:S,S) )
    prob <- Nx/sum(Nx)    
  }
  sub<-m[sample(S,N,replace=T,prob=prob)]
  sub
}

shinyServer(function(input, output){
  # output for Q1     
  output$ansQ1<- reactive({
    validate( need(input$Q1, "Select an answer") )
    if (input$Q1==3){answer<- "Correct! Richness is proportional to the number of species."}
    else{answer<-"Incorrect"}
    answer
  })
  #Output for Q2 multiple choice 
  output$ansQ2<- reactive({
    validate( need(input$Q2, "Select an answer") )
    if (input$Q2==1){answer<- "Correct! Why do you think this happens?"}
    else{answer<-"Incorrect"}
    answer
  })
  
  S<-reactive(input$num_species)
  N<-reactive(input$num_individuals)
  ran<- reactive({
    if (input$random == "yes") {TRUE}
    else {FALSE}
  })
  
  values <- reactiveValues( df=matrix(NA,nrow=0,ncol=5) )

  #create barplot based on values chosen by slider input
  species <- reactive( getCommunity(S(),N(),ran()) )
  output$dist= renderPlot({
    par(mar=c(12,4,2,0.4))
    barplot(table(species()), main="Species observations",xlab="", ylab="Number of Individuals",las=2)
  })
  
  #calculate data metrics based on numbers chosen by slider input
  metrics<- reactive({  
    richness <- length(unique(species()))
    Pi <- table(species())/length(species())
    shannon <-round((-sum(Pi*log(Pi))),2)
    #print(shannon)
    lambda <- round(sum(Pi^2),2)
    simpson <-lambda
    num_s <- input$num_species
    num_i <- input$num_individuals
    x <- c(num_i,richness, shannon, simpson)
    x
  })
  
  #Add generated data from app to the table
  adddata <- observeEvent(input$add,{       
    rand <- 0
    if( !ran() ) rand <- 1
    newLine <- c(metrics()[1],metrics()[2],metrics()[3],metrics()[4],rand)
    values$df <- rbind(values$df, newLine)
  })
  
  output$dataLine <- renderTable({
    tmp <- matrix(unlist(metrics()))
    rownames(tmp) <- c("N","Richness (S)","Shannon","Simpson")
    colnames(tmp) <- NULL
    tmp
  })

  #Output the data table comprised of data generated from the app
  output$dataTable <- renderTable({
    tmp<- values$df
    colnames(tmp)<- c("N", "S", "Shannon", "Simpson","Rand")
    rownames(tmp)<-  NULL
    tmp
  })
  
  output$dataPlot <- renderPlot({
    if(nrow(values$df)>0){
      datatouse <- data.frame(Richness=values$df[,2], Evenness=values$df[,3], Randomness=values$df[,5])
     ggplot(data=datatouse, aes(x=Richness,y=Evenness,color=factor(Randomness)))+ 
       geom_point(position="jitter") 
    }
  })
  
  
})