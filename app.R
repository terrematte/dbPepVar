#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)  # for the diamonds dataset
if(!require(DT)){ install.packages('DT') }

load("data/dbPepVar_snps.Rda")
dbPepVar_snps <- as.data.frame(dbPepVar_snps)
cols <- c("Cancer_Type", "Hugo_Symbol", "Tumor_Sample_Barcode", "Refseq_protein", "Variant_Classification", "HGVSp", "snp_id",  "Chromosome", "Start_Position", "End_Position", "band", "i_transcript_name")
dbPepVar_snps <- dbPepVar_snps[,cols]


f <-  "data/dbPepVar_PTC_Peptides.tsv"
dbPepVar <- read.table(f, header = T, sep="\t", stringsAsFactors=F, quote='"')

dbPepVar$Pep <- gsub(",",".",dbPepVar$Pep, fixed = T)
dbPepVar$Pep <- as.numeric(dbPepVar$Pep)
dbPepVar$PTC <- ifelse(dbPepVar$ptc == 1, "TRUE", "FALSE")
dbPepVar$ptc <- NULL

BrCa <- dbPepVar[dbPepVar$Cancer_Type =="BrCa", ]
CrCa <- dbPepVar[dbPepVar$Cancer_Type =="CrCa", ]
OvCa <- dbPepVar[dbPepVar$Cancer_Type =="OvCa", ]
PrCa <- dbPepVar[dbPepVar$Cancer_Type =="PrCa", ]


# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # tags$head(tags$link(rel="icon", 
    #                     href="icons/icon.png",
    #                     type = "image/gif/png")),
    
    # Application title
    titlePanel(
        windowTitle = "dbPepVar",
        title = "dbPepVar"
        ),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            conditionalPanel(
                'input.dataset === "dbPepVar_snps"',
                checkboxGroupInput("show_vars_snps", "Select columns in dbPepVar.snps to show:",
                                   names(dbPepVar_snps), selected = names(dbPepVar_snps)[c(1:7,12)]) 
            ),
            conditionalPanel(
                'input.dataset === "dbPepVar"',
                checkboxGroupInput("show_vars_dbPepVar", "Select columns in dbPepVar to show:",
                                   names(dbPepVar), selected = names(dbPepVar)[c(1:13,15)])
            ),
            conditionalPanel(
                'input.dataset === "BrCa"',
                checkboxGroupInput("show_vars_BrCa", "Select columns in BrCa to show:",
                                   names(BrCa), selected = names(BrCa)[c(1:13,15)])
            ),
            conditionalPanel(
                'input.dataset === "CrCa"',
                checkboxGroupInput("show_vars_CrCa", "Select columns in CrCa to show:",
                                   names(CrCa), selected = names(CrCa)[c(1:13,15)])
            ),
            conditionalPanel(
                'input.dataset === "OvCa"',
                checkboxGroupInput("show_vars_OvCa", "Select columns in OvCa to show:",
                                   names(OvCa), selected = names(OvCa)[c(1:13,15)])
            ),
            conditionalPanel(
                'input.dataset === "PrCa"',
                checkboxGroupInput("show_vars_PrCa", "Select columns in PrCa to show:",
                                   names(PrCa), selected = names(PrCa)[c(1:13,15)])
            )
        ),
        mainPanel(
            tabsetPanel(
                id = 'dataset',
                tabPanel("dbPepVar_snps", DT::dataTableOutput("tb_dbPepVar_snps")),
                tabPanel("dbPepVar", DT::dataTableOutput("tb_dbPepVar")),
                tabPanel("BrCa", DT::dataTableOutput("tb_BrCa")),
                tabPanel("CrCa", DT::dataTableOutput("tb_CrCa")),
                tabPanel("OvCa", DT::dataTableOutput("tb_OvCa")),
                tabPanel("PrCa", DT::dataTableOutput("tb_PrCa"))
            )
        )
    )
)

# Define server logic
server <- function(input, output) {


    list.options <- list(
        searchHighlight = TRUE,
        #pageLength = 15,
        orientation ='landscape',
        lengthMenu = c(10, 30, 50),
        dom = 'Bfrtip',
        buttons =
            list(
                 list(extend = 'pdf',
                      text = '<span class="glyphicon glyphicon-th"></span>',
                      pageSize = 'A4',
                      orientation = 'landscape',
                      filename = 'dbPepVar'
                 ),
                 list(extend = 'csv',
                      text = '<span class="glyphicon glyphicon-download-alt"></span>',
                      filename = 'dbPepVar'
                 )
            )
    )
    
    output$tb_dbPepVar_snps <- DT::renderDataTable({
        DT::datatable(
            dbPepVar_snps[, input$show_vars_snps, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons'),
            options = list.options)
        
    })

    output$tb_dbPepVar <- DT::renderDataTable({
        DT::datatable(
            dbPepVar[, input$show_vars_dbPepVar, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons'),
            options = list.options)

    })

    # sorted columns are colored now because CSS are attached to them
    output$tb_BrCa <- DT::renderDataTable({
        DT::datatable(
            BrCa[, input$show_vars_BrCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons'),
            options = list.options
            )
    })

    # customize the length drop-down menu; display 5 rows per page by default
    output$tb_CrCa <- DT::renderDataTable({
        DT::datatable(
            CrCa[, input$show_vars_CrCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons'),
            options = list.options
            )
    })

    # customize the length drop-down menu; display 5 rows per page by default
    output$tb_OvCa <- DT::renderDataTable({
        DT::datatable(
            OvCa[, input$show_vars_OvCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons'),
            options = list.options
        )
    })

    # customize the length drop-down menu; display 5 rows per page by default
    output$tb_PrCa <- DT::renderDataTable({
        DT::datatable(
            PrCa[, input$show_vars_PrCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons'),
            options = list.options
        )
    })
}

# Run the application
shinyApp(ui = ui, server = server)


