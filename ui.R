library(shiny)

shinyUI(
  fluidPage(
    fluidRow(
      h4("Click 'Add To Table' to store values in the table."),
      br(),
      
      #slider input
      column(3, 
        sliderInput('num_species', 'Number of Species to Examine: ', min=2, max=51, value=12),
        #numeric input for number of individuals
        numericInput('num_individuals', 'Number of individuals in the Population: ', 
                     min=1000, max=10000, value=1000, step=50),
        #buttons controlling "skewed" or "uniform" and "Get Community" and "Save to Table"
        radioButtons("random", label= "Type of community distribution",
                     choices=c("uniform"="yes", "skewed"="no"), selected="yes"),
        actionButton("add", label= "Save to Table")
      ),
      
      #creates space for multiple choice questions
      column(5,
        radioButtons("Q1", 'What happens to the richness if you have a very high number of species oberservations?', choices = c("It Decreases"=1, "It stays the same"=2,"It Increases"=3), selected=F),
        h5(textOutput("ansQ1"), style="color:blue"),
        #creates space for the distribution plot          
        plotOutput("dataPlot"),
        tableOutput("dataLine")
      ),
      
      #question 2 multiple choice 
      column(4, 
        radioButtons("Q2", 'What happens to the Simpson Index if you keep the number of species at 20 and increase the population size from very small to very large?', choices = c("It Decreases"=1, "It stays the same"=2,"It Increases"=3), selected=F),
        h5(textOutput("ansQ2"), style="color:blue"),
        #creates space for table output
        tableOutput("dataTable")
      )
    )  
  )
)