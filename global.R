#
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

if(!require(memoise, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('memoise', quiet=TRUE) }
if(!require(shiny, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('shiny', quiet=TRUE) }
#if(!require(shinyjs, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('shinyjs', quiet=TRUE) }
if(!require(ggplot2, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('ggplot2', quiet = FALSE) }
if(!require(DT, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('DT', quiet=TRUE) }
if(!require(dplyr, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('dplyr', quiet=TRUE) }
if(!require(tidyr, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('tidyr', quiet=TRUE) }
if(!require(vroom, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('vroom', quiet=TRUE) }
if(!require(plotly, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('plotly', quiet=TRUE) }
#if(!require(waiter, quietly=TRUE, warn.conflicts=FALSE)){ install.packages("waiter", quiet=TRUE) }
#if(!require(cicerone, quietly=TRUE, warn.conflicts=FALSE)){ install.packages("cicerone", quiet=TRUE) }

# if(!require(promises, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('promises', quiet=TRUE) }
# if(!require(future, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('future', quiet=TRUE) }
#if(!require(remotes, quietly=TRUE, warn.conflicts=FALSE)){ install.packages("remotes", quiet=TRUE) }
#if(!require(shinycssloaders, quietly=TRUE, warn.conflicts=FALSE)){ remotes::install_github("daattali/shinycssloaders") }
#library(shinycssloaders)
#if(!require(shinycssloaders, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('shinycssloaders', quiet=TRUE)}
# if(!require(purrr, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('purrr', quiet=TRUE) }

# library(purrr)
# plan(multisession)
# # 
# globalrv <- reactiveVal(NULL)


# load_data <- function() {
#   Sys.sleep(2)
#   hide("loading_page")
#   show("main_content")
# }

# future_promise({
#   Sys.sleep(5) # your long running function
#   }) %...>%
#   globalrv() %...!% # assign result to globalrv
#   (function(e) {
#     globalrv(NULL) # error handling needed?
#     warning(e)
#   })

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

# ==== Set up caching ===============================================================
source("R/memoize.R")
# Configure memoization using a shared disk cache. The lifetime of this cache
# directory is the life of the R process; when the R process exits, it will
# be removed.
#cache_dir <- file.path(tempdir(), "bind-cache")
cache_dir <- file.path("./bind-cache")
#cache <- cachem::cache_disk(cache_dir, max_size = 1024 * 1024 * 1024, logfile = "bind-cache/log")
# Expire items in cache after 15 minutes
cache <- cachem::cache_mem(max_size = 500e6, max_age = 15 * 60)

memoize2 <- function(fn) {
  memoize(fn, cache = cache)
}
# Tell Shiny to also use this cache for renderCachedPlot
shinyOptions(cache = cache, shiny.trace = T)

# ==== Global Functions ===============================================================
img_uri <-  memoize2(function(x) { sprintf('<img src="%s"/>', knitr::image_uri(x)) })
img_uri_icon <-  memoize2(function(x) { sprintf('<img src="%s" width="18" height="18"/>', knitr::image_uri(x)) })
img_uri_favicon <-  memoize2(function(x) { sprintf('%s', knitr::image_uri(x)) })

link_genecards <-  memoize2(function(val) {
  sprintf('<a href="https://www.genecards.org/cgi-bin/carddisp.pl?gene=%s#publications" target="_blank"><img src="%s"  width="90" height="20"/></a>', val,  knitr::image_uri("icons/genecards.png"))
})

link_snps <-  memoize2(function(val) {
  sprintf('<a href="https://www.ncbi.nlm.nih.gov/snp/%s#publications" target="_blank"><img src="%s" height="18"/></a>', val,  knitr::image_uri("icons/logo_dbSNP.png"))
})

link_proteins <-  memoize2(function(val) {
  sprintf('<a href="https://www.ncbi.nlm.nih.gov/protein/%s" target="_blank"><img src="%s"  height="18"/></a>', val,  knitr::image_uri("icons/logo_ncbi.gif"))
})

# ==== Support Functions ===============================================================
source("R/plotly.R")
source("R/plots.R")

# ==== Global variables ===============================================================
load("data/dbPepVar_snps.Rda")

f <-  "data/dbPepVar_PTC_Peptides.tsv"
dbPepVar <- vroom(f, show_col_types = FALSE)  %>%
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


BrCa <-  vroom("data/evidence.dbPepVar.BrCa.txt", show_col_types = FALSE) %>% dplyr::rename("snp_id" = "id SNP")
CrCa <-  vroom("data/evidence.dbPepVar.CrCa.txt", show_col_types = FALSE) %>% dplyr::rename("snp_id" = "id SNP")
OvCa <-  vroom("data/evidence.dbPepVar.OvCa.txt", show_col_types = FALSE) %>% dplyr::rename("snp_id" = "id SNP")
PrCa <-  vroom("data/evidence.dbPepVar.PrCa.txt", show_col_types = FALSE) %>% dplyr::rename("snp_id" = "id SNP")

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


#rm(list=setdiff(ls(), c("dbPepVar","BrCa", "CrCa", "OvCa", "PrCa", "img_uri", "img_uri_favicon", "img_uri_icon", 
#                        "link_genecards", "link_snps", "link_proteins", "memoize", "memoize2", "cache", 
#                        "plotly_build2", "plotbarCancerSamples", "globalrv", "load_data")))

rm(list = c("by", "cache_dir", "cols1", "cols2", "dbPepVar_snp_genes", "dbPepVar_snps", "f", "genes_nmd", "props"))
