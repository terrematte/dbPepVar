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

# img_uri <- function(x) { sprintf('<img src="%s"/>', knitr::image_uri(x)) }
# camino_genecards = img_uri("icons/logo_genecards.png")
# camino_ncbi = img_uri("icons/logo_ncbi.gif")


link_genecards <- function(val) {
    sprintf('<a href="https://www.genecards.org/cgi-bin/carddisp.pl?gene=%s#publications" target="_blank"><img src="%s"/></a>', val,  knitr::image_uri("icons/logo_genecards.png"))
}

link_snps <- function(val) {
    sprintf('<a href="https://www.ncbi.nlm.nih.gov/snp/%s" target="_blank"><img src="%s"/> SNPs</a>', val,  knitr::image_uri("icons/logo_ncbi.gif"))
}

link_proteins <- function(val) {
    sprintf('<a href="https://www.ncbi.nlm.nih.gov/protein/%s" target="_blank"><img src="%s"/> Proteins</a>', val,  knitr::image_uri("icons/logo_ncbi.gif"))
}

dbPepVar_snps <- dbPepVar_snps %>%
    dplyr::select(c("Cancer_Type", "Hugo_Symbol", "Tumor_Sample_Barcode", "Refseq_protein", "Variant_Classification", "HGVSp", "snp_id",  "Chromosome", "Start_Position", "End_Position", "band", "i_transcript_name", "NMD")) %>%
    dplyr::mutate(
        #SNPs_Publications = paste0("<a href='https://www.ncbi.nlm.nih.gov/snp/",snp_id,"#publications' target='_blank'>", camino_ncbi," SNP</a>"),
        #GeneCards = paste0("<a href='https://www.genecards.org/cgi-bin/carddisp.pl?gene=",Hugo_Symbol,"' target='_blank'>", camino_genecards,"</a>"),
        #Protein_search = paste0("<a href='https://www.ncbi.nlm.nih.gov/protein/",Refseq_protein,"' target='_blank'>", camino_ncbi," Protein</a>"),
        GeneCards = link_genecards(Hugo_Symbol),
        SNPs_Publications = link_snps(snp_id),
        Protein_search = link_proteins(Refseq_protein),
        NMD = ifelse(NMD, "TRUE", "FALSE")
    )  %>%
    as.data.frame()

f <-  "data/dbPepVar_PTC_Peptides.tsv"
dbPepVar <- read.table(f, header = T, sep="\t", stringsAsFactors=F, quote='"')

dbPepVar <- dbPepVar %>%
    dplyr::select(-c("Variant_Classification"))  %>%
    dplyr::rename(
        Other_Hugo_Symbol = "Gene",
        Others_Samples_Barcode = "Tumor_Sample_Barcode") %>%
    dplyr::mutate(
        Pep = round(Pep, digits = 3),
        PTC = ifelse(PTC == 1, "TRUE", "FALSE")) %>%
    as.data.frame()

by <- c("Cancer_Type", "Refseq_protein", "snp_id")

dbPepVar <- dplyr::left_join(dbPepVar_snps, dbPepVar, by = by)
rm(dbPepVar_snps,by, link_genecards, link_proteins, link_snps, f)

dbPepVar$Other_Hugo_Symbol[is.na(dbPepVar$Other_Hugo_Symbol)] <- "-"

dbPepVar_mismatch <- unique(dbPepVar[dbPepVar$Hugo_Symbol != dbPepVar$Other_Hugo_Symbol & dbPepVar$Other_Hugo_Symbol != "-", c("Hugo_Symbol", "Other_Hugo_Symbol", "GeneCards", "Refseq_protein", "Protein_search", "HGVSp", "Pos_Mut")])


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
                'input.dataset === "dbPepVar"',
                checkboxGroupInput("show_vars_dbPepVar", "Select columns in dbPepVar to show:",
                                   names(dbPepVar), selected = names(dbPepVar)[c(1:7,14:16)]) 
            ),
            conditionalPanel(
                'input.dataset === "dbPepVar_mismatch"',
                checkboxGroupInput("show_vars_dbPepVar_mismatch", "Select columns in dbPepVar_mismatch to show:",
                                   names(dbPepVar_mismatch), selected = names(dbPepVar_mismatch))
            ),
            conditionalPanel(
                'input.dataset === "BrCa"',
                checkboxGroupInput("show_vars_BrCa", "Select columns in BrCa to show:",
                                   names(BrCa), selected = names(BrCa)[c(1:7,14:16)])
            ),
            conditionalPanel(
                'input.dataset === "CrCa"',
                checkboxGroupInput("show_vars_CrCa", "Select columns in CrCa to show:",
                                   names(CrCa), selected = names(CrCa)[c(1:7,14:16)])
            ),
            conditionalPanel(
                'input.dataset === "OvCa"',
                checkboxGroupInput("show_vars_OvCa", "Select columns in OvCa to show:",
                                   names(OvCa), selected = names(OvCa)[c(1:7,14:16)])
            ),
            conditionalPanel(
                'input.dataset === "PrCa"',
                checkboxGroupInput("show_vars_PrCa", "Select columns in PrCa to show:",
                                   names(PrCa), selected = names(PrCa)[c(1:7,14:16)])
            )
        ),
        mainPanel(
            tabsetPanel(
                id = 'dataset',
                tabPanel("dbPepVar", DT::dataTableOutput("tb_dbPepVar")),
                tabPanel("dbPepVar_mismatch", DT::dataTableOutput("tb_dbPepVar_mismatch")),
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
    
    output$tb_dbPepVar <- DT::renderDataTable({
        DT::datatable(
            dbPepVar[, input$show_vars_dbPepVar, drop = FALSE],
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons'),
            options = list.options)
        
    },  escape=FALSE)

    output$tb_dbPepVar <- DT::renderDataTable({
        DT::datatable(
            dbPepVar_mismatch[, input$show_vars_dbPepVar_mismatch, drop = FALSE],
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
    },  escape=FALSE)

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
    },  escape=FALSE)

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
    },  escape=FALSE)

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
    },  escape=FALSE)
}

# Run the application
shinyApp(ui = ui, server = server)


