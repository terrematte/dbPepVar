#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#    https://bookdown.org/weicheng/shinyTutorial/ui.html

# ==== Loading library ===============================================================
#if(!require(uuid)){ install.packages("uuid") }
#if(!require(curl)){ install.packages("curl") }
#if(!require(remotes)){install.packages("remotes")}
#if(!require(GAlogger)){ remotes::install_github("bnosac/GAlogger") }

#ga_set_tracking_id("G-34TE3RG6BK")
#ga_set_approval(consent = TRUE)
#https://bioinfo.imd.ufrn.br/dbPepVar/#tab-9985-3
#ga_collect_pageview(page = "/dbPepVar")
#ga_collect_pageview(page = "#tab-9985-2", title = "Variants")
#ga_collect_pageview(page = "#tab-9985-3", title = "Evidence tables")
#ga_collect_pageview(page = "#tab-9985-4", title = "Proteogenomics Viewer")
#ga_collect_pageview(page = "#tab-9985-5", title = "Donwload dataset")
#ga_collect_pageview(page = "/dbPepVar", title = "Homepage", hostname = "bioinfo.imd.ufrn.br")

if(!require(shiny)){ install.packages('shiny') }
if(!require(ggplot2)){ install.packages('ggplot2') }
if(!require(DT)){ install.packages('DT') }
if(!require(dplyr)){ install.packages('dplyr') }
if(!require(tidyr)){ install.packages('tidyr') }
if(!require(vroom)){ install.packages('vroom') }
if(!require(plotly)){ install.packages('plotly') }
# if(!require(magrittr)){ install.packages('magrittr') }
# if(!require(generics)){ install.packages('generics') }
# if(!require(DT)){ install.packages('DT') }
# if(!require(httpuv)){ install.packages('httpuv')}
# if(!require(promises)){ install.packages('promises')}
# if(!require(vctrs)){ install.packages('vctrs') }
# if(!require(lifecycle)){ install.packages('lifecycle') }
# if(!require(ellipsis)){ install.packages('ellipsis') }
# if(!require(crayon)){ install.packages('crayon') }
# if(!require(glue)){ install.packages('glue') }
# if(!require(fansi)){ install.packages('fansi') }
# if(!require(utf8)){ install.packages('utf8') }
# if(!require(pillar)){ install.packages('pillar') }
# if(!require(gtable)){ install.packages('gtable') }
# if(!require(colorspace)){ install.packages('colorspace') }
# if(!require(munsell)){ install.packages('munsell') }
# if(!require(pkgconfig)){ install.packages('pkgconfig') }
# if(!require(tibble)){ install.packages('tibble') }
# if(!require(withr)){ install.packages('withr') }
# if(!require(scales)){ install.packages('scales') }
# if(!require(ggplot2)){ install.packages('ggplot2') }
# if(!require(purrr)){ install.packages('purrr') }
# if(!require(tidyselect)){ install.packages('tidyselect') }
# if(!require(dplyr)){ install.packages('dplyr') }
# if(!require(tidyr)){ install.packages('tidyr') }
# if(!require(tzdb)){ install.packages('tzdb') }
# if(!require(vroom)){ install.packages('vroom') }
# if(!require(data.table)){ install.packages('data.table') }
# if(!require(httr)){ install.packages('httr') }
# if(!require(jsonlite)){ install.packages('jsonlite') }
# if(!require(lazyeval)){ install.packages('lazyeval') }
# if(!require(viridisLite)){ install.packages('viridisLite') }
# if(!require(plotly)){ install.packages('plotly')}
# if(!require(later)){ install.packages('later')}
# if(!require(bitops)){ install.packages('bitops')}
# #if(!require(RCurl)){ install.packages('RCurl')}
# if(!require(farver)){ install.packages('farver')}
# if(!require(terra)){ install.packages('terra')}
# if(!require(raster)){ install.packages('raster')}
# if(!require(shiny)){ install.packages('shiny')}
# if(!require(leaflet)){ install.packages('leaflet')}
# if(!require(leafem)){ install.packages('leafem')}

# packages_cran = c("Rcpp", "leafem", "leafpop", "raster", "mapview", "rgdal", "rgeos", "terra", "raster", "satellite", "sf", "leaflet", "downlit","pryr", "shiny", "DT", "lobstr","dplyr", "tibble", "tidyr", "stringr", "plotly", "vroom")
# 
# #use this function to check if each package is on the local machine
# #if a package is installed, it will be loaded
# #if any are not, the missing package(s) will be installed from CRAN and loaded
# package.check <- lapply(packages_cran, FUN = function(x) {
#   if (!require(x, character.only = TRUE)) {
#     install.packages(x, dependencies = TRUE)
#     library(x, character.only = TRUE)
#   }
# })

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

f <-  "data/dbPepVar_PTC_Peptides.tsv"
dbPepVar <- vroom(f)  %>%
    dplyr::select(-c("Gene","Variant_Classification"))

# Merge data
by <- c("Cancer_Type", "Refseq_protein", "snp_id")

dbPepVar <- dplyr::left_join(dbPepVar_snps, dbPepVar, by = by) %>%
    dplyr::mutate(
        GeneCards = link_genecards(Hugo_Symbol),
        SNP_search = link_snps(snp_id),
        Protein_search = link_proteins(Refseq_protein),
        #Pep = round(Pep, digits = 3),
        PTC_gene = ifelse(PTC == 1, "TRUE", "FALSE"),
        Change =  gsub('[0-9]+', '>', gsub('p.', '', HGVSp, fixed = T))) %>%
    dplyr::rename(          
        Gene = "Hugo_Symbol",
        Sample = "Tumor_Sample_Barcode.x",
        Others_Samples = "Tumor_Sample_Barcode.y") %>%
    dplyr::mutate_if(is.factor, as.character)  %>%
    dplyr::mutate_at(vars("Start_Position", "End_Position"), as.numeric) %>%
    dplyr::mutate_at(vars("Variant_Classification", "Cancer_Type", "Chromosome"), as.factor)  %>%
    dplyr::mutate(Variant_Classification =  forcats::fct_recode(Variant_Classification,
                                                                Missense = "Missense_Mutation",
                                                                Frameshift = "Frame_Shift_Del",
                                                                Nonsense = "Nonsense_Mutation",
                                                                Nonstop = "Nonstop_Mutation",
                                                                Indel = "In_Frame_Del",
                                                                "5'|3'_utr" = "5'UTR" ) )  

props <- c("Gly" = "Non-Polar",
           "Ala" = "Non-Polar",
           "Pro" = "Non-Polar",
           "Val" = "Non-Polar",
           "Leu" = "Non-Polar",
           "Ile" = "Non-Polar",
           "Met" = "Non-Polar",
           "Trp" = "Aromatic",
           "Phe" = "Aromatic",
           "Tyr" = "Aromatic",
           "Ser" = "P.Neutral",
           "Thr" = "P.Uncharged",
           "Cys" = "P.Uncharged",
           "Asn" = "P.Uncharged",
           "Gln" = "P.Uncharged",
           "Lys" = "P.Basic",
           "Arg" = "P.Basic",
           "His" = "P.Basic",
           "Glu" = "P.Acid",
           "Asp" = "P.Acid")

genes_nmd <- read.delim("data/nmd_reactome_genes.txt")

dbPepVar <- dbPepVar %>%
    dplyr::mutate(Prop_change = ifelse(nchar(dbPepVar$Change) > 7,  "Multiple", stringr::str_replace_all(Change, props)),
                  NMD_gene =  (dbPepVar$Gene %in% genes_nmd$gene_name)) %>%
    dplyr::select(c("Cancer_Type", "Sample", "Others_Samples", "Gene", "GeneCards", "description", "Refseq_protein", "Protein_search",
                    "snp_id", "SNP_search", "Variant_Classification", "HGVSp", "Change", "Prop_change", "Chromosome", "Start_Position", "End_Position",  
                    "NMD_gene", "Peptide", "PTC_gene", "Score", "Pep", "Size_Ref", "Size_Mut", "Pos_Mut", "Rate_Size_Prot", "Rate_Pos_Mut")) %>%
    as.data.frame()

# ==== Load evidence files ===============================================================


BrCa <-  vroom("data/evidence.dbPepVar.BrCa.txt") %>% dplyr::rename("snp_id" = "id SNP")
CrCa <-  vroom("data/evidence.dbPepVar.CrCa.txt") %>% dplyr::rename("snp_id" = "id SNP")
OvCa <-  vroom("data/evidence.dbPepVar.OvCa.txt") %>% dplyr::rename("snp_id" = "id SNP")
PrCa <-  vroom("data/evidence.dbPepVar.PrCa.txt") %>% dplyr::rename("snp_id" = "id SNP")

dbPepVar_snp_genes <- dbPepVar %>%
    dplyr::select(c("Gene", "GeneCards", "snp_id", "SNP_search")) %>%
    distinct()

cols1 <- c("Mutation Type", "Gene", "GeneCards", "snp_id", "SNP_search", "Sequence", "Length", "K Count", "R Count", "Modifications", "Modified sequence", "Oxidation (M) Probabilities", "Oxidation (M) Score Diffs", "Acetyl (Protein N-term)", "Oxidation (M)", "Missed cleavages", "Proteins", "Leading Proteins", "Leading Razor Protein", "Type", "Labeling State", "Raw file", "Fraction", "Experiment", "MS/MS m/z", "Charge", "m/z", "Mass", "Resolution", "Uncalibrated - Calibrated m/z [ppm]", "Uncalibrated - Calibrated m/z [Da]", "Mass Error [ppm]", "Mass Error [Da]", "Uncalibrated Mass Error [ppm]", "Uncalibrated Mass Error [Da]", "Max intensity m/z 0", "Max intensity m/z 1", "Retention time", "Retention length", "Calibrated retention time", "Calibrated retention time start", "Calibrated retention time finish", "Retention time calibration", "Match time difference", "Match m/z difference", "Match q-value", "Match score", "Number of data points", "Number of scans", "Number of isotopic peaks", "PIF", "Fraction of total spectrum", "Base peak fraction", "PEP", "MS/MS Count", "MS/MS Scan Number", "Score", "Delta score", "Combinatorics", "Ratio H/L", "Ratio H/L normalized", "Ratio H/L shift", "Intensity", "Intensity L", "Intensity H", "Reverse", "Potential contaminant", "id", "Protein group IDs", "Peptide ID", "Mod. peptide ID", "MS/MS IDs", "Best MS/MS", "AIF MS/MS IDs", "Oxidation (M) site IDs")
cols2 <- c("Mutation Type", "Gene", "GeneCards", "snp_id", "SNP_search", "Sequence", "Length", "Modifications", "Modified sequence", "Oxidation (M) Probabilities", "Oxidation (M) Score Diffs", "Acetyl (Protein N-term)", "Oxidation (M)", "Missed cleavages", "Proteins", "Leading Proteins", "Leading Razor Protein", "Type", "Raw file", "Fraction", "Experiment", "MS/MS m/z", "Charge", "m/z", "Mass", "Resolution", "Uncalibrated - Calibrated m/z [ppm]", "Uncalibrated - Calibrated m/z [Da]", "Mass Error [ppm]", "Mass Error [Da]", "Uncalibrated Mass Error [ppm]", "Uncalibrated Mass Error [Da]", "Max intensity m/z 0", "Retention time", "Retention length", "Calibrated retention time", "Calibrated retention time start", "Calibrated retention time finish", "Retention time calibration", "Match time difference", "Match m/z difference", "Match q-value", "Match score", "Number of data points", "Number of scans", "Number of isotopic peaks", "PIF", "Fraction of total spectrum", "Base peak fraction", "PEP", "MS/MS Count", "MS/MS Scan Number", "Score", "Delta score", "Combinatorics", "Intensity", "Reverse", "Potential contaminant", "id", "Protein group IDs", "Peptide ID", "Mod. peptide ID", "MS/MS IDs", "Best MS/MS", "AIF MS/MS IDs", "Oxidation (M) site IDs")

names(BrCa) <- cols1[-c(2,3,5)]
names(CrCa) <- cols2[-c(2,3,5)]
names(OvCa) <- cols2[-c(2,3,5)]
names(PrCa) <- cols1[-c(2,3,5)]

BrCa <- BrCa %>%
    left_join(dbPepVar_snp_genes[dbPepVar_snp_genes$snp_id %in% unique(BrCa$snp_id), ],
              BrCa, by = "snp_id") %>%
    dplyr::mutate(Gene = ifelse(is.na(Gene), "--", as.character(Gene)),
                  SNP_search = link_snps(snp_id)) %>%
    dplyr::select(all_of(cols1))

PrCa <- PrCa %>%
    left_join(dbPepVar_snp_genes[dbPepVar_snp_genes$snp_id %in% unique(PrCa$snp_id), ],
                  PrCa, by = "snp_id") %>%
    dplyr::mutate(Gene = ifelse(is.na(Gene), "--", as.character(Gene)),
                  SNP_search = link_snps(snp_id)) %>%
    dplyr::select(all_of(cols1))

CrCa <- CrCa %>%
    left_join(dbPepVar_snp_genes[dbPepVar_snp_genes$snp_id %in% unique(CrCa$snp_id), ],
                  CrCa, by = "snp_id") %>%
    dplyr::mutate(Gene = ifelse(is.na(Gene), "--", as.character(Gene)),
                  SNP_search = link_snps(snp_id)) %>%
    dplyr::select(all_of(cols2))

OvCa <- OvCa %>%
    left_join(dbPepVar_snp_genes[dbPepVar_snp_genes$snp_id %in% unique(OvCa$snp_id), ],
                  OvCa, by = "snp_id") %>%
    dplyr::mutate(Gene = ifelse(is.na(Gene), "--", as.character(Gene)),
                  SNP_search = link_snps(snp_id)) %>%
    dplyr::select(all_of(cols2))


rm(list=setdiff(ls(), c("dbPepVar","BrCa", "CrCa", "OvCa", "PrCa", "img_uri", "img_uri_favicon", "img_uri_icon")))


# ==== ui.R ===============================================================
ui <- fluidPage(
    tags$head(includeHTML(("google-analytics.html"))),
    # Application title
    titlePanel(
        windowTitle = "dbPepVar",
        title = tags$head(tags$link(rel="icon",
                                    href=img_uri_favicon("icons/favicon.png"),
                                    type="image/x-icon"))
    ),
    navbarPage(
        img(src="favicon.png", align="right", width="35px"),
        
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
                         em("\"Assessing Nonsense-Mediated Decay machinery mutations in cancer peptide landscapes through a novel proteogenomics database\"."),
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
                #      ,
                # fluidRow(
                #     column(12, align="center", wellPanel(
                     # tags$img(src = "Supplementary_figure2.png", width = "40%", height = "40%"),
                     # br(),
                     # tags$img(src = "Supplementary_figure3.png", width = "40%", height = "40%")
                        # )
                #     ))
                ))
        )
)

# ==== server.R ===============================================================
server <- function(input, output) {
    
    
    data <- dbPepVar %>% 
        dplyr::select(c("Cancer_Type", "Gene", "Variant_Classification", "Refseq_protein",  "snp_id", "HGVSp", "Change", "Chromosome"))  %>% 
        unique() 
    
    dataSequenceCancer <- cbind(Cancer_Type = c("BrCa", "CrCa", "OvCa", "PrCa"),
                                vctrs::vec_c(count(BrCa, Sequence) %>% count(), 
                                        count(CrCa, Sequence) %>% count(), 
                                        count(OvCa, Sequence) %>% count(),
                                        count(PrCa, Sequence) %>% count()))
    
    dataSNPCancer_Type <- count(data, Cancer_Type) %>%
        mutate(Cancer_Type = as.factor(Cancer_Type)) 
    
    dataChromosome <- dbPepVar %>% 
        dplyr::mutate(Chromosome = ifelse(Chromosome %in% paste0(c(0:22, "X","Y")), as.character(Chromosome), "others_CTG")  ) %>% 
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
        dplyr::select(c("Cancer_Type", "snp_id", "Change"))  %>%
        unique() %>% 
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
        dplyr::select(c("Cancer_Type", "snp_id", "Gene"))  %>%
        unique() %>% 
        group_by(Gene, Cancer_Type) %>% 
        count()  %>% 
        dplyr::filter(Gene %in% GeneTop) %>% 
        pivot_wider( names_from = "Cancer_Type", values_from = n)
    
    PropTop <- dbPepVar %>% 
        group_by(Prop_change) %>% 
        count() %>% 
        arrange(desc(n)) %>% 
        head(.,25) %>% 
        dplyr::select(Prop_change) %>%
        pull(.)
    
    data_Properties <- dbPepVar %>% 
        group_by(Prop_change, Cancer_Type) %>% 
        count()  %>% 
        dplyr::filter(Prop_change %in% PropTop) %>% 
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
    
    # Bar plot of Amino acid change  by Samples  ----
    output$fig.barChangeSamples <- renderPlotly({
        plot_ly(data_ChangeSamples, x = ~Change, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count by Samples'), 
                   xaxis = list(title = "Amino acid change", tickangle = -45, categoryorder = "array", categoryarray = ChangeTopSamples),
                   barmode = 'group')
    })
    
    # Bar plot of Amino acid change per SNP by Cancer ----
    output$fig.barChange <- renderPlotly({
        plot_ly(data_Change, x = ~Change, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count per unique SNP'), 
                   xaxis = list(title = "Amino acid change", tickangle = -45, categoryorder = "array", categoryarray = ChangeTop),
                   barmode = 'group')
    })
    #
    # Bar plot of mutation on Top Prop_change by Cancer Samples ----
    output$fig.barProperties <- renderPlotly({
        plot_ly(data_Properties, x = ~Prop_change, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count by Samples'), 
                   xaxis = list(title = "Property group change", tickangle = -45, ategoryorder = "array", categoryarray = PropTop),
                   barmode = 'group')
    })
    
    # Bar plot of mutation on Chromosome by Cancer Samples ----
    output$fig.barChromosome <- renderPlotly({
        plot_ly(dataChromosome, x = ~Chromosome, y = ~BrCa, type = 'bar', name = 'BrCa') %>% 
            add_trace(y = ~CrCa, name = 'CrCa') %>% 
            add_trace(y = ~OvCa, name = 'OvCa') %>% 
            add_trace(y = ~PrCa, name = 'PrCa')  %>% 
            layout(yaxis = list(title = 'Count by Samples'), 
                   xaxis = list(title = "Chromosome", tickangle = -45, ategoryorder = "array", categoryarray = paste0(c(0:22, "X","Y", "others_CTG"))),
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
        lengthMenu =  list(c(10, 25, 50, 100, -1), 
                           c('10', '25', '50','100', 'All')),
        paging = T,
        search = list(regex = TRUE),
        searchHighlight = TRUE,
        colReorder = TRUE,
        orientation ='landscape',
        dom = "<'row'<'col-md-3'l><'col-md-6'B><'col-md-3'f>><'row'<'col-md-12't>><'row'<'col-md-3'i><'col-md-1'><'col-md-8'p>>",
        #dom = 'lBfrtip',
        buttons =
            list(
                list(extend = 'pdf',
                     text = img_uri_icon('icons/pdf_icon.png'),
                     pageSize = 'A4',
                     orientation = 'landscape',
                     filename = 'dbPepVar'
                ),
                list(extend = "csv", 
                     text = '<span class="glyphicon glyphicon-download-alt"></span> Current Page (csv)', 
                     filename = "dbPepVar_page",
                     exportOptions = list(
                         modifier = list(page = "current")
                     )
                ),
                list(extend = "csv", 
                     text = '<span class="glyphicon glyphicon-download-alt"></span> All Pages (csv)', 
                     filename = "dbPepVar_page",
                     exportOptions = list(
                         modifier = list(page = "all")
                     )
                )
            )
    )
    
    
    # table of Amino acid change by Sample ----
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
    
    # table of Amino acid change by SNPs ----
    output$tb_data_Change <- DT::renderDataTable({
        DT::datatable(
            data %>% 
                #dplyr::select(c("Cancer_Type", "Gene", "Variant_Classification", "Refseq_protein",  "snp_id", "HGVSp", "Change", "Chromosome"))  %>%
                dplyr::select(c("Cancer_Type", "snp_id", "Change"))  %>% 
                unique() %>% 
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
                #dplyr::select(c("Cancer_Type", "Gene", "Variant_Classification", "Refseq_protein",  "snp_id", "HGVSp", "Change", "Chromosome"))  %>%
                dplyr::select(c("Cancer_Type", "snp_id", "Gene"))  %>% 
                unique() %>% 
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
            if(input$show_unique_dbPepVar == "unique"){ 
                dbPepVar[ !duplicated(dbPepVar[, input$show_vars_dbPepVar]) , input$show_vars_dbPepVar, drop = FALSE]
            } else{
                dbPepVar[ , input$show_vars_dbPepVar, drop = FALSE]
            } ,
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
            if(input$show_unique_BrCa == "unique"){ 
                BrCa[ !duplicated(BrCa[, input$show_vars_BrCa]) , input$show_vars_BrCa, drop = FALSE]
            } else{
                BrCa[ , input$show_vars_BrCa, drop = FALSE]
            } ,
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
            if(input$show_unique_CrCa == "unique"){ 
                CrCa[ !duplicated(CrCa[, input$show_vars_CrCa]) , input$show_vars_CrCa, drop = FALSE]
            } else{
                CrCa[ , input$show_vars_CrCa, drop = FALSE]
            } ,
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
            if(input$show_unique_OvCa == "unique"){ 
                OvCa[ !duplicated(OvCa[, input$show_vars_OvCa]) , input$show_vars_OvCa, drop = FALSE]
            } else{
                OvCa[ , input$show_vars_OvCa, drop = FALSE]
            } ,
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
            if(input$show_unique_PrCa == "unique"){ 
                PrCa[ !duplicated(PrCa[, input$show_vars_PrCa]) , input$show_vars_PrCa, drop = FALSE]
            } else{
                PrCa[ , input$show_vars_PrCa, drop = FALSE]
            } ,
            class = 'cell-border stripe',
            rownames = FALSE,
            filter = 'top',
            extensions = c('Buttons', "ColReorder"),
            options = list.options,  
            escape=FALSE
        )
    })
    
    output$frame <- renderUI({
        tags$iframe(
            seamless="seamless",
            src="dbPepVar.pv/index.html", height='1000', width='100%',
            #src="http://hungria.imd.ufrn.br/~terrematte/dbPepVar.pv/index.html", height='1000', width='100%',
            style="border:0;")
    })
}

# Run the application
shinyApp(ui = ui, server = server)


