# ==== ui.R ===============================================================
ui <- fluidPage(
  tags$head(includeHTML(("www/google-analytics.html"))),
  waiter::use_waiter(),
  waiter::waiterPreloader(html =  spin_wave(), color = "lightblue"),
  # Application title
  titlePanel(
    windowTitle = "dbPepVar",
    title = tags$head(tags$link(rel="icon",
                                href=img_uri_favicon("icons/favicon.png"),
                                type="image/x-icon"))
  ),
  navbarPage(
    windowTitle = "dbPepVar",
    
    div(img(src="favicon.png", align="left", width="50px"), style="border: 0px; padding: 0px; margin: -14px 0 0 0px;" ), 

    # ==== Tab dbPepVar ===============================================================
    tabPanel('dbPepVar',
             fluidRow(
               column(12, wellPanel(p("
        The dbPepVar is a new proteogenomics database which combines genetic variation information from dbSNP with 
        protein sequences from NCBI's RefSeq. We then perform a pan-cancer analysis (Ovarian, Colorectal, Breast and Prostate) 
        using public mass spectrometry datasets to identify genetic variations and genes present in the analyzed samples. 
        As results, were identified 3,726 variant peptides in ovarian (OvCa),  2,543 in prostate (PrCa), 2,661 in breast (BrCa) and 2,411 in colon-rectal cancer (CrCa)."),
                                    
                                    
                                    p("
        Compared to other approaches, our database contains a greater diversity of variants, including missense, 
        nonsense mutations, loss of termination codon, insertions, deletions (of any size), frameshifts and mutations that 
        alter the start translation. Besides, for each protein, only the variant tryptic peptides derived from enzymatic cleavage 
        (i.e., trypsin) are inserted, following the criteria of size, allelic frequency and affected regions of the protein. 
        In our approach, MS data is submitted to the dbPepVar variant and reference base separately. The outputs are compared 
        and filtered by the scores for each base. Using public MS data from four types of cancer, we mostly identified 
        cancer-specific SNPs, but shared mutations were also present in a lower amount.                               
        "), br(),
                                    icon("cog", lib = "glyphicon"), 
                                    em( "
        Click on legends of plots to activate or deactivate labels. Use ",  
                                        a("regex", href="cheatsheets_regex.pdf", target="_blank"), 
                                        " to search in datatables.", br(),
                                    )))
             ),
             fluidRow(
               column(3,
                      plotlyOutput("fig.barCancerSamples")
               ),
               column(3,
                      plotlyOutput("fig.barCancerSequence")
               ),
               column(3,
                      plotlyOutput("fig.pieCancerSNP")
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
               column(12, wellPanel(c("Amino acid changes of Samples by Cancer")))
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
               column(12, wellPanel(c("Amino acid changes of unique SNPs identified from Peptides")))
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
               column(12, wellPanel(c("Properties Changes of Samples by Cancer")))
             ),
             fluidRow(
               column(12, 
                      plotlyOutput("fig.barProperties")
               )
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
               column(12, wellPanel(
                 h4("Citation:"),
                 c("LM Cunha, PCA Terrematte, TS Fiúza, VL Silva, JE Kroll, SJ de Souza, GA de Souza. (2022)"),
                 em("\"dbPepVar: a novel cancer proteogenomics database\"."),
                 c("To be published."), br(),  br(),
                 h4("Authors:"),
                 c("- Lucas Marques da Cunha¹"),br(),
                 c("- Patrick Cesar A. Terrematte¹,²,"),br(),
                 c("- Tayná da Silva Fiúza¹, "),br(),
                 c("- Vandeclécio L. da Silva¹, "),br(),
                 c("- José Eduardo Kroll¹, "),br(),
                 c("- Sandro José de Souza¹,"), br(),
                 c("- Gustavo Antônio de Souza¹,³"),br(),
                 h4("Affiliations: "),
                 c("¹ Bioinformatics Multidisciplinary Environment - UFRN,"),br(),
                 c("² Federal Rural University of Semi-arid - UFERSA, "),br(),
                 c("³ Department of Biochemistry - UFRN")))
             )
    ),
    # ==== Tab Variants ===============================================================
    tabPanel(
      'Variants',
      
      # fluidRow(
      #     column(12, p("Complete dbPepVar with SNPs per Sampĺes. "))
      # ),
      # Sidebar with a slider input for number of bins
      sidebarLayout(
        sidebarPanel(
          radioButtons("show_unique_dbPepVar", 
                       "Show", 
                       choices = list("Unique rows" = "unique" , "All rows" = "all"),  
                       selected = c("unique"),
                       inline = TRUE),
          checkboxGroupInput("show_vars_dbPepVar", 
                             "Select columns in dbPepVar:",
                             names(dbPepVar), selected = names(dbPepVar)[c(1,2,4:12)]),
          width = 3
        ),
        
        mainPanel(
          DT::dataTableOutput("tb_dbPepVar"),
          # tabsetPanel(
          #     id = 'tab',
          #     tabPanel("dbPepVar",)
          # ),
          width = 9
        )
      )
    ),
    # ==== Tab Evidence Tables ===============================================================
    tabPanel(
      'Evidence Tables',
      
      # fluidRow(
      #     column(12, p("Complete Evidence tables of dbPepVar. "))
      # ),
      # Sidebar with a slider input for number of bins
      sidebarLayout(
        sidebarPanel(
          conditionalPanel(
            'input.tab_evidance === "BrCa"',
            radioButtons("show_unique_BrCa", 
                         "Show", 
                         choices = list("Unique rows" = "unique" , "All rows" = "all"),  
                         selected = c("all"),
                         inline = TRUE),
            checkboxGroupInput("show_vars_BrCa", "Select columns in BrCa evidence:",
                               names(BrCa), selected = names(BrCa)[c(1:6,54,57)])
          ),
          conditionalPanel(
            'input.tab_evidance === "CrCa"',
            radioButtons("show_unique_CrCa", 
                         "Show", 
                         choices = list("Unique rows" = "unique" , "All rows" = "all"),  
                         selected = c("all"),
                         inline = TRUE),
            checkboxGroupInput("show_vars_CrCa", "Select columns in CrCa evidence:",
                               names(CrCa), selected = names(CrCa)[c(1:6,50,53)])
          ),
          conditionalPanel(
            'input.tab_evidance === "OvCa"',
            radioButtons("show_unique_OvCa", 
                         "Show", 
                         choices = list("Unique rows" = "unique" , "All rows" = "all"),  
                         selected = c("all"),
                         inline = TRUE),
            checkboxGroupInput("show_vars_OvCa", "Select columns in OvCa evidence:",
                               names(OvCa), selected = names(OvCa)[c(1:6,50,53)])
          ),
          conditionalPanel(
            'input.tab_evidance === "PrCa"',
            radioButtons("show_unique_PrCa", 
                         "Show", 
                         choices = list("Unique rows" = "unique" , "All rows" = "all"),  
                         selected = c("all"),
                         inline = TRUE),
            checkboxGroupInput("show_vars_PrCa", "Select columns in PrCa evidence:",
                               names(PrCa), selected = names(PrCa)[c(1:6,54,57)])
          ),
          width = 3
        ),
        mainPanel(
          tabsetPanel(
            id = 'tab_evidance',
            tabPanel("BrCa", DT::dataTableOutput("tb_BrCa")),
            tabPanel("CrCa", DT::dataTableOutput("tb_CrCa")),
            tabPanel("OvCa", DT::dataTableOutput("tb_OvCa")),
            tabPanel("PrCa", DT::dataTableOutput("tb_PrCa"))
          ),
          width = 9
        )
      )
    ),
    # ==== Tab Proteogenomics Viewer ===============================================================
    tabPanel('Proteogenomics Viewer',
             fluidRow(
               column(12, 
                      htmlOutput("frame")
               )
             ),
             
             fluidRow(
               column(12, wellPanel(
                 h4("Citation:"),
                 c("JE Kroll, VL da Silva, SJ de Souza, GA de Souza. (2017)"),
                 em("\"A tool for integrating genetic and mass spectrometry‐based peptide data: Proteogenomics Viewer: PV: A genome browser‐like tool, which includes MS data visualization and peptide identification parameters\"."),
                 c("Bioessays 39 (7),"), a("https://doi.org/10.1002/bies.201700015", href="https://doi.org/10.1002/bies.201700015", target="_blank"),c("."), br(),  br()
               )
               ))),
    # ==== Tab Downloads ===============================================================
    tabPanel('Download Data',
             fluidRow(
               column(12, wellPanel(
                 h4("Fasta file:"),
                 tags$ul(
                   tags$li(a("Fasta dbPepVar", href="dbPepVar.2021.fasta.gz", target="_blank")), 
                 ),
                 h4("Log files:"),
                 tags$ul(
                   tags$li(a("Missense and Nonsense mutations - Minor allele frequency (MAF) < 5%", href="missense_nonsense_mutation_maf_less_than_5.txt.gz", target="_blank")), 
                 ),
                 tags$ul(
                   tags$li(a("Missense and Nonsense mutations - Minor allele frequency (MAF) >= 5%", href="missense_nonsense_mutation_maf_greater_than_5.txt.gz", target="_blank")), 
                 ),
                 tags$ul(
                   tags$li(a("Frameshift mutations", href="frameshift_mutation.txt.gz", target="_blank")), 
                 ),
                 tags$ul(
                   tags$li(a("Stop loss mutations", href="stop_loss_mutation.txt.gz", target="_blank")), 
                 ),
                 tags$ul(
                   tags$li(a("UTR'Var mutations", href="utr_variation_mutatation.txt.gz", target="_blank")),
                 ),
                 br(),
                 br(),
                 h4("Data format description:"),
                 p("The dbPepVar fasta file construction process:"), 
                 p("A) Initially, the reference protein is mutated according to dbSNP information. The mutated peptides are then located on the generated protein."),
                 p("B) A list containing the mutated peptides for each protein present in RefSeq is generated."), 
                 p("C) Final fasta file is generated by concatenating the mutated peptides of each protein, generating a new theoretical sequence."),
                 br(),
                 tags$img(src = "Supplementary_figure2.png", width = "40%", height = "40%"),
                 br(),
                 p("The dbPepVar provides a log file containing information about mutated peptides. The header fields are the protein identifier (RefSeq), the SNP identifier, and the position of the peptide in the reference protein. A tab delimits the fields. Each entry has the sequence of reference and the mutated peptide. Each type of mutation is in separate files, and the missense and nonsense mutations are available in the Minor Allele Frequency (MAF) files."),
                 br(),
                 tags$img(src = "Supplementary_figure3.png", width = "40%", height = "40%"),
                 br(),
                 br()
              )
            )
          )
        )
      )
    )
