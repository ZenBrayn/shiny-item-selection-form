#
# Shiny Item Selection Form
# 
# An example application for collecting
# item selections online.
#

library(shiny)
library(stringr)

items <- c("Item 1",
           "Item 2",
           "Item 3",
           "Item 4",
           "Item 5")

max_items_sel <- 5

# Define UI for application that draws a histogram
ui <- fluidPage(
  shinyjs::useShinyjs(),
  
  # Application title
  titlePanel("Shiny Item Selection Form"),
  
  hr(),
  
  h3("Directions"),
  tags$div(style = "width: 75%",
           tags$ul(
             tags$li("Please enter your name."),
             tags$li(paste0("Please select ", max_items_sel, " items total.")),
             
             tags$li("If an item of interest is not listed, please add them
    in the 'Other Items' text field (one per line).")
           )),
  
  br(),
  
  sidebarLayout(
    
    sidebarPanel(width = 4,
                 textInput("name", "Your Name"),
                 
                 strong(paste0("Please select ", max_items_sel, " items total:")),
                 checkboxGroupInput("sel_items", "", items),
                 
                 strong("Other items if not listed above"),
                 br(),
                 strong("(separate with newlines)"),
                 textAreaInput("other_items", "", height = "200px"),
                 actionButton("submit", "Submit Responses", class = "btn-primary")
                 
    ),
    
    mainPanel(
      strong("You Have Selected the Following Items"),
      verbatimTextOutput("sel_items_review"),
      hr(),
      htmlOutput("name_msg"),
      htmlOutput("items_msg"),
      htmlOutput("ok_msg"),
      
      shinyjs::hidden(
        div(style = "color:green",
            id = "thankyou_msg",
            h3("Thank you! Your response was submitted successfully.")
        )
      ),
      
      shinyjs::hidden(
        div(style = "color:red",
            id = "err_msg",
            h3("Oh no! Something went wrong.")
        )
      )
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  all_sel_items <- reactive({
    # parse other items if provided
    other_items <- c()
    if (input$other_items != "") {
      other_items <- unlist(str_split(input$other_items, "\n"))
      # remove any empty lines if present
      other_items <- other_items[other_items != ""]
    }
    
    # combine to get the total list of selected items
    all_items <- c(input$sel_items, other_items)
    
    all_items
  })
  
  n_items <- reactive({
    length(all_sel_items())
  })
  
  output$sel_items_review <- renderText({
    paste(all_sel_items(), collapse = "\n")
  })
  
  output$items_msg <- renderText({
    msg <- ""
    n_more <- max_items_sel - n_items()
    
    if (max_items_sel - n_items() >= 2) {
      msg <- paste("<div style='color:red'><strong>Please select ", n_more, " more items.</strong></div>", sep = "")
    } else if (max_items_sel - n_items() == 1) {
      msg <- paste("<div style='color:red'><strong>Please select ", n_more, " more item.</strong></div>", sep = "")
    } else if (n_items() == max_items_sel) {
      msg <- ""
    }
    else if (n_items() > max_items_sel) {
      msg <- paste("<div style='color:red'><strong>Too many items selected! Please choose ", 
                   max_items_sel, "total.</strong></div>")
    }
    
    msg
  })
  
  output$name_msg <- renderText({
    msg <- ""
    if (input$name == "") {
      msg <- "<div style='color:red'><strong>Please enter your name.</strong></div>"
    }
    msg
  })
  
  output$ok_msg <- renderText({
    msg <- ""
    
    if (input$name != "" && n_items() == max_items_sel) {
      msg <- "<div style='color:green'><strong>Please review your selections and click the submit button.</div></strong>"
    }
    
    msg
  })
  
  
  observe({
    # enable/disable the submit button
    # must enter name and select 4 items
    submit_ok <- n_items() == max_items_sel && input$name != ""
    shinyjs::toggleState(id = "submit", condition = submit_ok)
  })
  
  observeEvent(input$submit, {
    # prepare the data
    resp_df <- data.frame(name = input$name,
                          topic = all_sel_items())
    
    fn <- paste0("response_data/",
                 digest::digest(resp_df), "-",
                 format(lubridate::now(), "%Y-%m-%d-%H-%M-%S"),
                 ".csv")
    write.table(resp_df, fn, row.names = FALSE, sep = ",")
    
    if (file.exists(fn)) {
      shinyjs::show("thankyou_msg")
    } else {
      shinyjs::show("err_msg")
    }
    
    shinyjs::disable("submit")
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

