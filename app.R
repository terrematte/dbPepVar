#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
#if(!require(shinydashboard)){ install.packages('shinydashboard') }
library(ggplot2)  # for the diamonds dataset
if(!require(DT)){ install.packages('DT') }
#if(!require(plotly)){ devtools::install_github("ropensci/plotly")}

# Functions
img_uri <- function(x) { sprintf('<img src="%s"/>', knitr::image_uri(x)) }
img_uri_icon <- function(x) { sprintf('<img src="%s" width="18" height="18"/>', knitr::image_uri(x)) }
img_uri_favicon <- function(x) { sprintf('%s', knitr::image_uri(x)) }


link_genecards <- function(val) {
    sprintf('<a href="https://www.genecards.org/cgi-bin/carddisp.pl?gene=%s#publications" target="_blank"><img src="%s"  width="90" height="20"/></a>', val,  knitr::image_uri("icons/genecards.png"))
}

link_snps <- function(val) {
    sprintf('<a href="https://www.ncbi.nlm.nih.gov/snp/%s#publications" target="_blank"><img src="%s" height="18"/></a>', val,  knitr::image_uri("icons/logo_dbSNP.png"))
}

link_proteins <- function(val) {
    sprintf('<a href="https://www.ncbi.nlm.nih.gov/protein/%s" target="_blank"><img src="%s"  height="18"/></a>', val,  knitr::image_uri("icons/logo_ncbi.gif"))
}

# Load data
load("data/dbPepVar_snps.Rda")

dbPepVar_snps <- dbPepVar_snps %>%
    dplyr::select(c("Cancer_Type", "Hugo_Symbol", "Tumor_Sample_Barcode", "Refseq_protein", "Variant_Classification", 
                    "HGVSp", "snp_id",  "Chromosome", "Start_Position", "End_Position", "band", "i_transcript_name", "NMD"))

f <-  "data/dbPepVar_PTC_Peptides.tsv"
dbPepVar <- read.table(f, header = T, sep="\t", stringsAsFactors=F, quote='"')  %>%
    dplyr::select(-c("Gene","Variant_Classification"))

by <- c("Cancer_Type", "Refseq_protein", "snp_id")

dbPepVar <- dplyr::left_join(dbPepVar_snps, dbPepVar, by = by) %>%
    dplyr::mutate(
        GeneCards = link_genecards(Hugo_Symbol),
        SNP_search = link_snps(snp_id),
        Protein_search = link_proteins(Refseq_protein),
        Pep = round(Pep, digits = 3),
        NMD_gene = ifelse(NMD, "TRUE", "FALSE"),
        PTC_gene = ifelse(PTC == 1, "TRUE", "FALSE")) %>%
    dplyr::rename(          
        Gene = "Hugo_Symbol",
        Sample = "Tumor_Sample_Barcode.x",
        Others_Samples = "Tumor_Sample_Barcode.y") %>%
    dplyr::select(c("Cancer_Type", "Sample", "Others_Samples", "Gene", "GeneCards",  "Refseq_protein", "Protein_search",
                    "snp_id", "SNP_search", "Variant_Classification", "HGVSp", "i_transcript_name", "Chromosome", "Start_Position", "End_Position", "band", 
                    "NMD_gene", "Peptide", "PTC_gene", "Score", "Pep", "Size_Ref", "Size_Mut", "Pos_Mut", "Rate_Size_Prot", "Rate_Pos_Mut")) %>%
    dplyr::mutate_if(is.factor, as.character)  %>%
    dplyr::mutate_at(vars("Variant_Classification", "Cancer_Type", "Chromosome"), as.factor) 

rm(dbPepVar_snps,by, link_genecards, link_proteins, link_snps, f)

BrCa <- dbPepVar[dbPepVar$Cancer_Type =="BrCa", ]
CrCa <- dbPepVar[dbPepVar$Cancer_Type =="CrCa", ]
OvCa <- dbPepVar[dbPepVar$Cancer_Type =="OvCa", ]
PrCa <- dbPepVar[dbPepVar$Cancer_Type =="PrCa", ]



# Define UI for application that draws a histogram
ui <- fluidPage(
     
    # Application title
    titlePanel(
        windowTitle = "dbPepVar",
        title = tags$head(tags$link(rel="icon", 
                                    href=img_uri_favicon("icons/favicon.png"),
                                    type="image/x-icon"))
        ),
    headerPanel("dbPepVar"),
    
    fluidRow(
        column(12, wellPanel(p("
        The dbPepVar is a new proteogenomics database which combines genetic variation information from dbSNP with 
        protein sequences from NCBI's RefSeq. We then perform a pan-cancer analysis (Ovarian, Colorectal, Breast and Prostate) 
        using public mass spectrometry datasets to identify genetic variations and genes present in the analyzed samples. 
        As results, were identified 5,449 variant peptides in ovarian, 2,722 in prostate, 2,392 in breast and 3,061 in colon cancer."),
                               
                             p("
        Compared to other approaches, our database contains a greater diversity of variants, including missense, 
        nonsense mutations, loss of termination codon, insertions, deletions (of any size), frameshifts and mutations that 
        alter the start translation. Besides, for each protein, only the variant tryptic peptides derived from enzymatic cleavage 
        (i.e., trypsin) are inserted, following the criteria of size, allelic frequency and affected regions of the protein. 
        In our approach, MS data is submitted to the dbPepVar variant and reference base separately. The outputs are compared 
        and filtered by the scores for each base. Using public MS data from four types of cancer, we mostly identified 
        cancer-specific SNPs, but shared mutations were also present in a lower amount.                               
        ")))
    ),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            # conditionalPanel(
            #     'input.tab === "Plots"',
            #     selectInput('xcol','X Variable', names(mtcars)),
            #     selectInput('ycol','Y Variable', names(mtcars)),
            #     selected = names(mtcars)[[2]]
            # ),
            conditionalPanel(
                'input.tab === "dbPepVar"',
                checkboxGroupInput("show_vars_dbPepVar", "Select columns in dbPepVar to show:",
                                   names(dbPepVar), selected = names(dbPepVar)[c(1,2,4:11)]) 
            ),
            conditionalPanel(
                'input.tab === "BrCa"',
                checkboxGroupInput("show_vars_BrCa", "Select columns in BrCa to show:",
                                   names(BrCa), selected = names(BrCa)[c(1,2,4:11)])
            ),
            conditionalPanel(
                'input.tab === "CrCa"',
                checkboxGroupInput("show_vars_CrCa", "Select columns in CrCa to show:",
                                   names(CrCa), selected = names(CrCa)[c(1,2,4:11)])
            ),
            conditionalPanel(
                'input.tab === "OvCa"',
                checkboxGroupInput("show_vars_OvCa", "Select columns in OvCa to show:",
                                   names(OvCa), selected = names(OvCa)[c(1,2,4:11)])
            ),
            conditionalPanel(
                'input.tab === "PrCa"',
                checkboxGroupInput("show_vars_PrCa", "Select columns in PrCa to show:",
                                   names(PrCa), selected = names(PrCa)[c(1,2,4:11)])
            ),
            width = 3
        ),
        mainPanel(
            tabsetPanel(
                id = 'tab',
                #tabPanel("Plots",  plotlyOutput('plot') ),
                tabPanel("dbPepVar", DT::dataTableOutput("tb_dbPepVar")),
                tabPanel("BrCa", DT::dataTableOutput("tb_BrCa")),
                tabPanel("CrCa", DT::dataTableOutput("tb_CrCa")),
                tabPanel("OvCa", DT::dataTableOutput("tb_OvCa")),
                tabPanel("PrCa", DT::dataTableOutput("tb_PrCa"))
            ),
            width = 9
        )
    )
)

# Define server logic ----
server <- function(input, output) {
    
    # 
    # x <- reactive({
    #     mtcars[,input$xcol]
    # })
    # 
    # y <- reactive({
    #     mtcars[,input$ycol]
    # })
    
    
    # output$plot <- renderPlotly(
    #     # plot1 <- plot_ly(
    #     #     x = x(),
    #     #     y = y(), 
    #     #     type = 'scatter',
    #     #     mode = 'markers')
    # )
    

    # B - Buttons
    # l - Length changing input control
    # f - Filtering input
    # r - pRocessing display element
    # t - Table
    # i - Table information summary
    # p - Pagination control
    
    list.options <- list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        search = list(regex = TRUE),
        searchHighlight = TRUE,
        colReorder = TRUE,
        orientation ='landscape',
        dom = "<'row'<'col-md-6'l><'col-md-3'B><'col-md-3'f>><'row'<'col-md-12't>><'row'<'col-md-3'i><'col-md-6'><'col-md-3'p>>",
        #dom = 'lBfrtip',
        buttons =
            list(
                 list(extend = 'pdf',
                      text = img_uri_icon('icons/pdf_icon.png'),
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
    
    # dbPepVar
    output$tb_dbPepVar <- DT::renderDataTable({
        DT::datatable(
            dbPepVar[, input$show_vars_dbPepVar, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons', "ColReorder"),
            options = list.options,  
            escape=FALSE)
        
    })

    # BrCa
    output$tb_BrCa <- DT::renderDataTable({
        DT::datatable(
            BrCa[, input$show_vars_BrCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons', "ColReorder"),
            options = list.options,  
            escape=FALSE
            )
    })

    # CrCa
    output$tb_CrCa <- DT::renderDataTable({
        DT::datatable(
            CrCa[, input$show_vars_CrCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons', "ColReorder"),
            options = list.options,  
            escape=FALSE
            )
    })

    # OvCa
    output$tb_OvCa <- DT::renderDataTable({
        DT::datatable(
            OvCa[, input$show_vars_OvCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons', "ColReorder"),
            options = list.options,  
            escape=FALSE
        )
    })

    output$tb_PrCa <- DT::renderDataTable({
        DT::datatable(
            PrCa[, input$show_vars_PrCa, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons', "ColReorder"),
            options = list.options,  
            escape=FALSE
            )
    })
}

# Run the application
shinyApp(ui = ui, server = server)


