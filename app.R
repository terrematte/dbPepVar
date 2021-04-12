#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# ==== Loading library ===============================================================
library(shiny)
library(ggplot2)  # for the diamonds dataset
if(!require(DT)){ install.packages('DT') }
if(!require(dplyr)){ install.packages('dplyr') }
if(!require(tidyr)){ install.packages('tidyr') }
if(!require(vroom)){ install.packages('vroom') }
if(!require(plotly)){ install.packages('plotly') }

# ==== Global Functions ===============================================================
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

# ==== Global variables ===============================================================
load("data/dbPepVar_snps.Rda")

dbPepVar_snps <- dbPepVar_snps %>%
    dplyr::select(c("Cancer_Type", "Hugo_Symbol", "Tumor_Sample_Barcode", "Refseq_protein", "Variant_Classification", 
                    "HGVSp", "snp_id",  "Chromosome", "Start_Position", "End_Position", "band", "i_transcript_name", "NMD"))

f <-  "data/dbPepVar_PTC_Peptides.tsv"
dbPepVar <- vroom(f)  %>%
    dplyr::select(-c("Gene","Variant_Classification"))

# ==== Load variables ===============================================================
BrCa <-  vroom("data/evidence_dbPepVar.BrCa.txt")
CrCa <-  vroom("data/evidence_dbPepVar.CrCa.txt")
OvCa <-  vroom("data/evidence_dbPepVar.OvCa.txt")
PrCa <-  vroom("data/evidence_dbPepVar.PrCa.txt")


# Merge data
by <- c("Cancer_Type", "Refseq_protein", "snp_id")
dbPepVar <- dplyr::left_join(dbPepVar_snps, dbPepVar, by = by) %>%
    dplyr::mutate(
        GeneCards = link_genecards(Hugo_Symbol),
        SNP_search = link_snps(snp_id),
        Protein_search = link_proteins(Refseq_protein),
        Pep = round(Pep, digits = 3),
        NMD_gene = ifelse(NMD, "TRUE", "FALSE"),
        PTC_gene = ifelse(PTC == 1, "TRUE", "FALSE"),
        Change =  gsub('[0-9]+', '>', gsub('p.', '', HGVSp))) %>%
    dplyr::rename(          
        Gene = "Hugo_Symbol",
        Sample = "Tumor_Sample_Barcode.x",
        Others_Samples = "Tumor_Sample_Barcode.y") %>%
    dplyr::select(c("Cancer_Type", "Sample", "Others_Samples", "Gene", "GeneCards",  "Refseq_protein", "Protein_search",
                    "snp_id", "SNP_search", "Variant_Classification", "HGVSp", "Change", "i_transcript_name", "Chromosome", "Start_Position", "End_Position", "band", 
                    "NMD_gene", "Peptide", "PTC_gene", "Score", "Pep", "Size_Ref", "Size_Mut", "Pos_Mut", "Rate_Size_Prot", "Rate_Pos_Mut")) %>%
    dplyr::mutate_if(is.factor, as.character)  %>%
    dplyr::mutate_at(vars("Variant_Classification", "Cancer_Type", "Chromosome"), as.factor) 

rm(dbPepVar_snps,by, link_genecards, link_proteins, link_snps, f)


# ==== ui.R ===============================================================
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
        As results, were identified 5,449 variant peptides in ovarian (OvCa), 2,722 in prostate (PrCa), 2,392 in breast (BrCa) and 3,061 in colon-rectal cancer (CrCa)."),
                             
                             p("
        Compared to other approaches, our database contains a greater diversity of variants, including missense, 
        nonsense mutations, loss of termination codon, insertions, deletions (of any size), frameshifts and mutations that 
        alter the start translation. Besides, for each protein, only the variant tryptic peptides derived from enzymatic cleavage 
        (i.e., trypsin) are inserted, following the criteria of size, allelic frequency and affected regions of the protein. 
        In our approach, MS data is submitted to the dbPepVar variant and reference base separately. The outputs are compared 
        and filtered by the scores for each base. Using public MS data from four types of cancer, we mostly identified 
        cancer-specific SNPs, but shared mutations were also present in a lower amount.                               
        "),
                             icon("cog", lib = "glyphicon"), 
                             em( "
        Click on legends of plots to activate or deactivate labels. Use ",  
                                 a("regex", href="cheatsheets_regex.pdf", target="_blank"), 
                                 " to search in datatables."
        )))
    ),
    fluidRow(
        column(3,
               plotlyOutput("fig.barCancerSamples")
        ),
        column(3,
               plotlyOutput("fig.barSequenceCancer")
        ),
        column(3,
               plotlyOutput("fig.pieSNPCancer")
        ),
        column(3,
               plotlyOutput("fig.pieVarClassif")
        )
    ),
    fluidRow(
        column(12, wellPanel(c("Mutated Genes of Samples by Cancer")))
    ),
    fluidRow(
        column(8, 
               plotlyOutput("fig.barGeneSamples")
        ),
        column(4, 
               DT::dataTableOutput("tb_data_GeneSamples")
        ),
    ),
    fluidRow(
        column(12, wellPanel(c("Mutated Genes of unique SNPs identified from Peptides")))
    ),
    fluidRow(
        column(8, 
               plotlyOutput("fig.barGene")
        ),
        column(4, 
               DT::dataTableOutput("tb_data_Gene")
        ),
    ),
    fluidRow(
        column(12, wellPanel(c("Protein Changes of Samples by Cancer")))
    ),
    fluidRow(
        column(8, 
               plotlyOutput("fig.barChangeSamples")
        ),
        column(4, 
               DT::dataTableOutput("tb_data_ChangeSamples")
        ),
    ),
    fluidRow(
        column(12, wellPanel(c("Protein Changes of unique SNPs identified from Peptides")))
    ),
    fluidRow(
        column(8, 
               plotlyOutput("fig.barChange")
        ),
        column(4, 
               DT::dataTableOutput("tb_data_Change")
        ),
    ),
    fluidRow(
        column(12, wellPanel(c("Mutations of Samples per Chromosome by Cancer")))
    ),
    fluidRow(
        column(12, 
               plotlyOutput("fig.barChromosome")
        )
    ),
    fluidRow(
        column(12, wellPanel(c("Complete dbPepVar with SNPs per Sampĺes. ")))
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
                'input.tab === "BrCa evidence"',
                checkboxGroupInput("show_vars_BrCa", "Select columns in BrCa evidence to show:",
                                   names(BrCa), selected = names(BrCa)[c(1:4)])
            ),
            conditionalPanel(
                'input.tab === "CrCa evidence"',
                checkboxGroupInput("show_vars_CrCa", "Select columns in CrCa evidence to show:",
                                   names(CrCa), selected = names(CrCa)[c(1:4)])
            ),
            conditionalPanel(
                'input.tab === "OvCa evidence"',
                checkboxGroupInput("show_vars_OvCa", "Select columns in OvCa evidence to show:",
                                   names(OvCa), selected = names(OvCa)[c(1:4)])
            ),
            conditionalPanel(
                'input.tab === "PrCa evidence"',
                checkboxGroupInput("show_vars_PrCa", "Select columns in PrCa evidence to show:",
                                   names(PrCa), selected = names(PrCa)[c(1:4)])
            ),
            width = 3
        ),
        mainPanel(
            tabsetPanel(
                id = 'tab',
                #tabPanel("Plots",  plotlyOutput('plot') ),
                tabPanel("dbPepVar", DT::dataTableOutput("tb_dbPepVar")),
                tabPanel("BrCa evidence", DT::dataTableOutput("tb_BrCa")),
                tabPanel("CrCa evidence", DT::dataTableOutput("tb_CrCa")),
                tabPanel("OvCa evidence", DT::dataTableOutput("tb_OvCa")),
                tabPanel("PrCa evidence", DT::dataTableOutput("tb_PrCa"))
            ),
            width = 9
        )
    )
)

# ==== server.R ===============================================================
server <- function(input, output) {
    

    # x <- reactive({
    #     mtcars[,input$xcol]
    # })
    # 
    # y <- reactive({
    #     mtcars[,input$ycol]
    # })
    # 
    # 
    # output$plot <- renderPlotly(
    #     # plot1 <- plot_ly(
    #     #     x = x(),
    #     #     y = y(),
    #     #     type = 'scatter',
    #     #     mode = 'markers')
    # )

    data <- dbPepVar %>% 
        dplyr::select(c("Cancer_Type", "Gene", "Variant_Classification", "Refseq_protein",  "snp_id", "HGVSp", "Change", "Chromosome"))  %>% 
        unique() 
    
    dataSequenceCancer <- cbind(Cancer_Type = c("BrCa", "CrCa", "OvCa", "PrCa"),
                                combine(count(BrCa, Sequence) %>% count(), 
                                        count(CrCa, Sequence) %>% count(), 
                                        count(OvCa, Sequence) %>% count(),
                                        count(PrCa, Sequence) %>% count()))
    
    dataSNPCancer_Type <- count(data, Cancer_Type) %>%
        mutate(Cancer_Type = as.factor(Cancer_Type)) 
    
    dataChromosome <- dbPepVar %>% 
        count(Cancer_Type, Chromosome) %>% 
        tidyr::pivot_wider( names_from = "Cancer_Type", values_from = n)
    
    ChangeTopSamples <- dbPepVar %>% 
        group_by(Change) %>% 
        count() %>% 
        arrange(desc(n)) %>% 
        head(.,20) %>% 
        dplyr::select(Change) %>%
        pull(.)
    
    data_ChangeSamples <- dbPepVar %>% 
        group_by(Change, Cancer_Type) %>% 
        count()  %>% 
        dplyr::filter(Change %in% ChangeTopSamples) %>% 
        tidyr::pivot_wider( names_from = "Cancer_Type", values_from = n)
    
    ChangeTop <- data %>% 
        group_by(Change) %>% 
        count() %>% 
        arrange(desc(n)) %>% 
        head(.,20) %>% 
        dplyr::select(Change) %>%
        pull(.)
    
    data_Change <- data %>% 
        group_by(Change, Cancer_Type) %>% 
        count()  %>% 
        dplyr::filter(Change %in% ChangeTop) %>% 
        pivot_wider( names_from = "Cancer_Type", values_from = n)
    
    GeneTopSamples <- dbPepVar %>% 
        group_by(Gene) %>% 
        count() %>% 
        arrange(desc(n)) %>% 
        head(.,20) %>% 
        dplyr::select(Gene) %>%
        pull(.)
    
    data_GeneSamples <- dbPepVar %>% 
        group_by(Gene, Cancer_Type) %>% 
        count()  %>% 
        dplyr::filter(Gene %in% GeneTopSamples) %>% 
        pivot_wider(names_from = "Cancer_Type", values_from = n)
    
    GeneTop <- data %>% 
        group_by(Gene) %>% 
        count() %>% 
        arrange(desc(n)) %>% 
        head(.,20) %>% 
        dplyr::select(Gene) %>%
        pull(.)
    
    data_Gene <- data %>% 
        group_by(Gene, Cancer_Type) %>% 
        count()  %>% 
        dplyr::filter(Gene %in% GeneTop) %>% 
        pivot_wider( names_from = "Cancer_Type", values_from = n)
    
    # Bar plot of Samples by Cancer Type  ----
    output$fig.barCancerSamples <- renderPlotly({
        p <- plot_ly(data = count(dbPepVar, Cancer_Type, Sample) %>% count(Cancer_Type) , x = ~Cancer_Type, y = ~n, type = 'bar',
                     text = ~n, textposition = 'auto',
                     marker = list(color = c('rgba(31, 119, 180, 1)', 'rgba(255, 127, 14, 1)',
                                             'rgba(44, 160, 44, 1)', 'rgba(214, 39, 40, 1)'))) %>%
        layout(yaxis = list(title = '#Samples by Cancer Type'), 
               xaxis = list(title = "Cancer_Type", tickangle = -45))
        
        t <- list(size = 10)
        p %>% layout(font=t)
    })

    # Pie chart of Cancer_Type of Unique Sequence  ----
    output$fig.barSequenceCancer <- renderPlotly({
        p <- plot_ly(data = dataSequenceCancer, x = ~Cancer_Type, y = ~n, type = 'bar',
                     text = ~n, textposition = 'auto',
                     marker = list(color = c('rgba(31, 119, 180, 1)', 'rgba(255, 127, 14, 1)',
                                             'rgba(44, 160, 44, 1)', 'rgba(214, 39, 40, 1)'))) %>% 
            layout(yaxis = list(title = '#Sequence by Cancer Type'), 
                   xaxis = list(title = "Cancer_Type", tickangle = -45))
        t <- list(size = 10)
        p %>% layout(font=t)
    })
    
    # # Pie chart of Cancer_Type of Unique Sequence  ----
    # output$fig.pieSequenceCancer <- renderPlotly({
    #     p <- plot_ly() %>% 
    #         add_pie(data = dataSequenceCancer, labels = ~Cancer_Type, values = ~n, 
    #                 hole = 0, name = "Cancer_Type", textinfo='label+percent', insidetextorientation='radial', sort = FALSE) %>% 
    #         layout(title = "#Unique Sequence by Cancer Type", showlegend = T,
    #                xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
    #                yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
    #     t <- list(size = 10)
    #     p %>% layout(font=t)
    # })
    
    # Pie chart of Cancer_Type of Unique SNPs  ----
    output$fig.pieSNPCancer <- renderPlotly({
        p <- plot_ly() %>% 
            add_pie(data = dataSNPCancer_Type, labels = ~Cancer_Type, values = ~n, 
                    hole = 0, name = "Cancer_Type", textinfo='label+percent', insidetextorientation='radial', sort = FALSE) %>% 
            layout(title = "#Unique SNPs by Cancer Type", showlegend = T,
                   xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        t <- list(size = 10)
        p %>% layout(font=t)
    })
    
    # Pie chart of Variant_Classification of Unique SNPs  ----
    output$fig.pieVarClassif <- renderPlotly({
        p <- plot_ly() %>% 
            add_pie(data = count(data, Variant_Classification), labels = ~Variant_Classification, values = ~n,
                    hole = 0, name = "Variant_Classification", rotation = 180,
                    textinfo='label+percent', insidetextorientation='radial') %>% 
            #add_trace(y = .Variant_Classification, name = "Missense_Mutation", visible = "legendonly") %>% 
            layout(title = "#Unique SNPs by Variant Classification", showlegend = T,
                   xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        
        t <- list(size = 10)
        p %>% layout(font=t, margin = list(t = 50, b = 120, l = 70, r = 100))
    })
    
    # Bar plots Genes by Samples ----
    output$fig.barGeneSamples <- renderPlotly({
        plot_ly(data_GeneSamples, x = ~Gene, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count by Samples'), 
                   xaxis = list(title = "Gene", tickangle = -45, categoryorder = "array", categoryarray = GeneTopSamples), 
                   barmode = 'group')
    })
    
    # Bar plots Genes by Cancer ----
    output$fig.barGene <- renderPlotly({
        plot_ly(data_Gene, x = ~Gene, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count per unique SNP'), 
                   xaxis = list(title = "Gene", tickangle = -45, categoryorder = "array", categoryarray = GeneTop), 
                   barmode = 'group')
    })
    
    # Bar plot of Protein Change  by Samples  ----
    output$fig.barChangeSamples <- renderPlotly({
        plot_ly(data_ChangeSamples, x = ~Change, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count by Samples'), 
                   xaxis = list(title = "Gene", tickangle = -45, categoryorder = "array", categoryarray = ChangeTopSamples),
                   barmode = 'group')
    })
    
    # Bar plot of Protein Change per SNP by Cancer ----
    output$fig.barChange <- renderPlotly({
        plot_ly(data_Change, x = ~Change, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count per unique SNP'), 
                   xaxis = list(title = "Gene", tickangle = -45, categoryorder = "array", categoryarray = ChangeTop),
                   barmode = 'group')
    })
    
    # Bar plot of mutation on Chromosome by Cancer Samples ----
    output$fig.barChromosome <- renderPlotly({
        plot_ly(dataChromosome, x = ~Chromosome, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count by Samples'), 
                   xaxis = list(title = "Gene", tickangle = -45, ategoryorder = "array", categoryarray = paste0(c(0:22, "X","Y"))),
                   barmode = 'group')
    })
    
    # B - Buttons
    # l - Length changing input control
    # f - Filtering input
    # r - pRocessing display element
    # t - Table
    # i - Table information summary
    # p - Pagination control
    # General options for all tables ----
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
    
    
    # table of Protein Change by SNPs ----
    output$tb_data_ChangeSamples <- DT::renderDataTable({
        DT::datatable(
            dbPepVar %>% 
                group_by(Cancer_Type, Change) %>% 
                count() %>% arrange(desc(n)),
            class = 'cell-border stripe',
            filter = 'top',
            rownames = FALSE,
            options = list(
                pageLength = 5,
                dom = 'tip',
                search = list(regex = TRUE),
                searchHighlight = TRUE),
            escape=FALSE)
    })
    
    # table of Protein Change by SNPs ----
    output$tb_data_Change <- DT::renderDataTable({
        DT::datatable(
            data %>% 
                group_by(Cancer_Type, Change) %>% 
                count() %>% arrange(desc(n)),
            class = 'cell-border stripe',
            filter = 'top',
            rownames = FALSE,
            options = list(
                pageLength = 5,
                dom = 'tip',
                search = list(regex = TRUE),
                searchHighlight = TRUE),
            escape=FALSE)
    })
    
    # table of Gene by SNPs ----
    output$tb_data_Gene <- DT::renderDataTable({
        DT::datatable(
            data %>% 
                group_by(Cancer_Type, Gene) %>% 
                count() %>% arrange(desc(n)),
            class = 'cell-border stripe',
            filter = 'top',
            rownames = FALSE,
            options = list(
                pageLength = 5,
                dom = 'tip',
                search = list(regex = TRUE),
                searchHighlight = TRUE),
            escape=FALSE)
    })
    
    # table of Gene by Samples ----
    output$tb_data_GeneSamples <- DT::renderDataTable({
        DT::datatable(
            dbPepVar %>% 
                group_by(Cancer_Type, Gene) %>% 
                count() %>% arrange(desc(n)),
            class = 'cell-border stripe',
            filter = 'top',
            rownames = FALSE,
            options = list(
                pageLength = 5,
                dom = 'tip',
                search = list(regex = TRUE),
                searchHighlight = TRUE),
            escape=FALSE)
    })
    
    # dbPepVar ----
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
    
    # BrCa ----
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
    
    # CrCa ----
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
    
    # OvCa ----
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
    
    # PrCa ----
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


