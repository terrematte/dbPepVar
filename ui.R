# ==== ui.R ===============================================================
ui <- fluidPage(
  use_cicerone(),
  tags$head(
    tags$style(
      HTML(
        "div#driver-popover-item {
          max-width: 700px;
          width: 700px;
          background-color: #E0FFFF;
          color: #191970;
        }
        div#driver-highlighted-element-stage, div#driver-page-overlay {
          background: transparent !important;
          outline: 5000px solid rgba(0, 0, 0, .75)
        }
        "
      )
    ),
    includeHTML("www/google-analytics.html")
  ),
    # Application title
  titlePanel(
    windowTitle = "dbPepVar",
    title = tags$head(tags$link(rel="icon",
                                href=img_uri_favicon("icons/favicon.png"),
                                type="image/x-icon"))
  ),
  navbarPage(
    windowTitle = "dbPepVar",
    div(img(src="favicon.png", align="left", width="50px"), style="border: 0px; padding: 0px; margin: -14px 0 0 10px;" ), 
    id = "nav",
    position = "fixed-top",
    br(br()),
    # ==== Tab dbPepVar ===============================================================
    tabPanel('dbPepVar',
             fluidRow(
               column(12, wellPanel(p("
        The dbPepVar is a new proteogenomics database which combines genetic variation information from dbSNP with 
        protein sequences from NCBI's RefSeq. We then perform a pan-cancer analysis (Ovarian, Colorectal, Breast and Prostate) 
        using public mass spectrometry datasets to identify genetic variations and genes present in the analyzed samples. 
        As results, were identified 2,661 variant peptides in breast cancer (BrCa), 2,411 in colon-rectal cancer (CrCa), 3,726 in ovarian cancer (OvCa), and  2,543 in prostate cancer (PrCa)."),
                                    
                                    
                                    p("
        Compared to other approaches, our database contains a greater diversity of variants, including missense, 
        nonsense mutations, loss of termination codon, insertions, deletions (of any size), frameshifts and mutations that 
        alter the start translation. Besides, for each protein, only the variant tryptic peptides derived from enzymatic cleavage 
        (i.e., trypsin) are inserted, following the criteria of size, allelic frequency and affected regions of the protein. 
        In our approach, Mass spectrometry (MS) data is submitted to the dbPepVar variant and reference base separately. The outputs are compared 
        and filtered by the scores for each base. Using public MS data from four types of cancer, we mostly identified 
        cancer-specific SNPs, but shared mutations were also present in a lower amount.                               
        "), br(),
                                    icon("cog", lib = "glyphicon"), 
                                    em( "Click on legends of plots to activate or deactivate labels."), br(),
                                    icon("cog", lib = "glyphicon"),                                           
                                    em( "Use ",
                                    a("regex", href="misc/cheatsheets_regex.pdf", target="_blank"), 
                                        " to search in datatables."
                                    ), br(), br(),
                                    actionButton("guide", " Run guided tour", icon = icon("info-sign", lib = "glyphicon"))
                                    ))
             ),
             div(
               id = "plots",
               div(
                 id = "plots_sec1",
               fluidRow(
                 column(3,
                        shinycssloaders::withSpinner(plotlyOutput("fig.barCancerSamples"), size = 0.5, type=1, color.background = "white")
                 ),
                 column(3,
                        shinycssloaders::withSpinner(plotlyOutput("fig.barCancerSequence"), size = 0.5, type=1, color.background = "white")
                 ),
                 column(3,
                        shinycssloaders::withSpinner(plotlyOutput("fig.pieCancerSNP"), size = 0.5, type=1, color.background = "white")
                 ),
                 column(3,
                        shinycssloaders::withSpinner(plotlyOutput("fig.pieVarClassif"), size = 0.5, type=1, color.background = "white")
                 )
               ),
               ),
               div(
                 id = "plots_sec2",
               fluidRow(
                 column(12, wellPanel(c("Mutated Genes of Samples by Cancer")))
               ),
               fluidRow(
                 column(8, 
                        shinycssloaders::withSpinner(plotlyOutput("fig.barGeneSamples"), size = 0.5, type=1, color.background = "white")
                 ),
                 column(4, 
                        shinycssloaders::withSpinner(DT::dataTableOutput("tb_data_GeneSamples"), size = 0.5, type=1, color.background = "white")
                 ),
               ),
               ),
               div(
                 id = "plots_sec3",
               fluidRow(
                 column(12, wellPanel(c("Mutated Genes of unique SNPs identified from Peptides")))
               ),
               fluidRow(
                 column(8, 
                        shinycssloaders::withSpinner(plotlyOutput("fig.barGene"), size = 0.5, type=1, color.background = "white")
                 ),
                 column(4, 
                        shinycssloaders::withSpinner(DT::dataTableOutput("tb_data_Gene"), size = 0.5, type=1, color.background = "white")
                 ),
               ),
               ),
               div(
                 id = "plots_sec4",
               fluidRow(
                 column(12, wellPanel(c("Amino acid changes of Samples by Cancer")))
               ),
               fluidRow(
                 column(8, 
                        shinycssloaders::withSpinner(plotlyOutput("fig.barChangeSamples"), size = 0.5, type=1, color.background = "white")
                 ),
                 column(4, 
                        shinycssloaders::withSpinner(DT::dataTableOutput("tb_data_ChangeSamples"), size = 0.5, type=1, color.background = "white")
                 ),
               ),
               fluidRow(
                 column(12, wellPanel(c("Amino acid changes of unique SNPs identified from Peptides")))
               ),
               fluidRow(
                 column(8, 
                        shinycssloaders::withSpinner(plotlyOutput("fig.barChange"), size = 0.5, type=1, color.background = "white")
                 ),
                 column(4, 
                        shinycssloaders::withSpinner(DT::dataTableOutput("tb_data_Change"), size = 0.5, type=1, color.background = "white")
                 ),
               ),
               ),
               div(
                 id = "plots_sec5",
               fluidRow(
                 column(12, wellPanel(c("Properties Changes of Samples by Cancer")))
               ),
               fluidRow(
                 column(12, 
                        shinycssloaders::withSpinner(plotlyOutput("fig.barProperties"), size = 0.5, type=1, color.background = "white")
                 )
               ),
               fluidRow(
                 column(12, wellPanel(c("Mutations of Samples per Chromosome by Cancer")))
               ),
               fluidRow(
                 column(12, 
                        shinycssloaders::withSpinner(plotlyOutput("fig.barChromosome"), size = 0.5, type=1, color.background = "white")
                 )
               ),
               ),
               div(
                 id = "citation",
               fluidRow(
                 column(12, wellPanel(
                   h4("Citation:"),
                   
                   h5(HTML("<b>If you have used dbPepVar data, please cite:</b>")),
                   
                   HTML(paste0("Lucas Marques da Cunha", tags$sup("1,2"))),
                   HTML(paste0(", Patrick Terrematte", tags$sup("3"))),
                   HTML(paste0(", Tayná da Silva Fiúza", tags$sup("1"))),
                   HTML(paste0(", Vandeclécio L. da Silva", tags$sup("1"))),
                   HTML(paste0(", José Eduardo Kroll", tags$sup("1"))),
                   HTML(paste0(", Sandro José de Souza", tags$sup("1,2"))), 
                   HTML(paste0(", Gustavo Antônio de Souza", tags$sup("1,5"))),
                   c("(2022)"),
                   em("\"dbPepVar: a novel cancer proteogenomics database\"."),
                   c("To be published."), br(),  br(),
                   
                   h5(HTML("<b>If you have used Proteogenomics Viewer, please cite:</b>")),
                   
                   HTML(paste0("José Eduardo Kroll", tags$sup("1"))),
                   HTML(paste0(", Vandeclécio L. da Silva", tags$sup("1"))),
                   HTML(paste0(", Sandro José de Souza", tags$sup("1,2"))), 
                   HTML(paste0(", Gustavo Antônio de Souza", tags$sup("1,5"))),
                   c("(2017)"),
                   em("\"A tool for integrating genetic and mass spectrometry‐based peptide data: Proteogenomics Viewer - A genome browser‐like tool, which includes MS data visualization and peptide identification parameters\"."),
                   c("Bioessays 39 (7),"), a("https://doi.org/10.1002/bies.201700015", href="https://doi.org/10.1002/bies.201700015", target="_blank"), br(),                  
                   a("[BibTex]", href="misc/citation_ProteogenomicViewer.bib", target="_blank"), c(" "),
                   a("[RIS]", href="misc/citation_ProteogenomicViewer.ris", target="_blank"), 
                   br(),br(),
                   h5("Affiliations: "),
                   HTML(paste0(tags$sup("1"), "Bioinformatics Multidisciplinary Environment - BioME, Federal University of Rio Grande do Norte - UFRN, Brazil")),br(),
                   HTML(paste0(tags$sup("2"), "Federal University of Rondonia - UNIR, Brazil")),br(),
                   HTML(paste0(tags$sup("3"), "Metropolis Digital Institute, UFRN, Brazil")),br(),
                   HTML(paste0(tags$sup("4"), "Brain Institute, UFRN, Brazil")),br(),
                   HTML(paste0(tags$sup("5"), "Department of Biochemistry, UFRN, Brazil")),br(),br(),
                   ))
               )
               ),
             ),
             
    ),
    # ==== Tab Variants ===============================================================
    tabPanel(
      'Variants',
      
      # fluidRow(
      #     column(12, p("Complete dbPepVar with SNPs per Sampĺes. "))
      # ),
      # Sidebar with a slider input for number of bins
      sidebarLayout(
        div(
        id = "options_dbPepVar",
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
          )),
        
        mainPanel(
          shinycssloaders::withSpinner(DT::dataTableOutput("tb_dbPepVar"), size = 0.5, type=1, color.background = "white"),
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
            tabPanel("BrCa", shinycssloaders::withSpinner(DT::dataTableOutput("tb_BrCa"), size = 0.5, type=1, color.background = "white")),
            tabPanel("CrCa", shinycssloaders::withSpinner(DT::dataTableOutput("tb_CrCa"), size = 0.5, type=1, color.background = "white")),
            tabPanel("OvCa", shinycssloaders::withSpinner(DT::dataTableOutput("tb_OvCa"), size = 0.5, type=1, color.background = "white")),
            tabPanel("PrCa", shinycssloaders::withSpinner(DT::dataTableOutput("tb_PrCa"), size = 0.5, type=1, color.background = "white"))
          ),
          width = 9
        )
      )
    ),
    # ==== Tab Proteogenomics Viewer ===============================================================
    tabPanel('Proteogenomics Viewer',
             fluidRow(
               column(12, 
                      htmlOutput("ProteogenViewer")
               )
             ),
             
             fluidRow(
               column(12, wellPanel(
                 h4("Presentation of Proteogenomic Viewer:"),
                 tags$iframe(width="560", height="315", src="https://www.youtube.com/embed/5NzyRvuk4Ac", frameborder="0", allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture", allowfullscreen=NA),
                 
                 h4("Citation:"),
                 c("Kroll, J.E., da Silva, V.L., de Souza, S.J. and de Souza, G.A. (2017)"),
                 em("\"A tool for integrating genetic and mass spectrometry‐based peptide data: Proteogenomics Viewer - A genome browser‐like tool, which includes MS data visualization and peptide identification parameters\"."),
                 c("Bioessays 39 (7),"), a("https://doi.org/10.1002/bies.201700015", href="https://doi.org/10.1002/bies.201700015", target="_blank"), c("."), br(),                  
                 a("[BibTex]", href="misc/citation_ProteogenomicViewer.bib", target="_blank"), c(" "),
                 a("[RIS]", href="misc/citation_ProteogenomicViewer.ris", target="_blank"), 
                 br(),  br()
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
