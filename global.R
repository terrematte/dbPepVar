# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.

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
if(!require(htmltools, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('htmltools', quiet=TRUE) }
#if(!require(shinythemes, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('shinythemes', quiet=TRUE) }
#if(!require(shinyjs, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('shinyjs', quiet=TRUE) }
if(!require(ggplot2, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('ggplot2', quiet = FALSE) }
if(!require(DT, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('DT', quiet=TRUE) }
if(!require(dplyr, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('dplyr', quiet=TRUE) }
if(!require(tidyr, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('tidyr', quiet=TRUE) }
if(!require(vroom, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('vroom', quiet=TRUE) }
if(!require(plotly, quietly=TRUE, warn.conflicts=FALSE)){ install.packages('plotly', quiet=TRUE) }

# https://daattali.com/shiny/shinycssloaders-demo/
# https://github.com/daattali/shinycssloaders#usage
# https://projects.lukehaas.me/css-loaders/
if(!require(cicerone, quietly=TRUE, warn.conflicts=FALSE)){ install.packages("cicerone", quiet=TRUE) }

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

guide <- Cicerone$
  new(id = "homeGuide"
  )$
  step(
    "[data-value='dbPepVar']",
    "Summary of dbPepVar",
    "<p>The first menu (dbPepVar) contains a summary of the data accessible through the portal.</p>
    <p>The graphical displays were separated by section according to the type of data and analysis that can be performed.</p>",
    is_id = FALSE,
    position = "bottom"
  )$
  step(
    "[data-value='Variants']",
    "Variants of actual dataset",
    "<p>The second menu shows the actual dataset in an interactive format, where users can perform data mining and generate insights for 
    their research. </p>
    
    <p>This action can be done by selecting all or single rows with up to 27 columns that describe each mutation.</p>
    
    <p>The table includes links to GeneCards, NCBI protein, and dbSNP. Users can filter on any of the provided columns using plain text and 
    regular expressions. Recovered results can be downloaded as CSV or PDF formatted files (all pages or current page only).</p>",
    is_id = FALSE,
    position = "bottom"
  )$
  step(
    "[data-value='Evidence Tables']",
    "Evidence Tables",
    "<p>The third menu is constructed by parsing the evidence files, which combine all information about the peptides identified by Mass spectrometry  and 
    is normally the only information needed for processing the results. </p>
    
    <p>It is from the evidence file that the other results presented on the portal are generated. </p>
    
    <p>Each type of cancer has an evidence file that can be accessed in its respective tab - breast cancer (BrCa), colon-rectal cancer (CrCa), ovarian cancer (OvCa), and prostate cancer (PrCa). </p>
    
    <p>Every file contains peptide information such as its amino acid sequence, post-translational modifications, the number of enzyme missed 
    cleavages, its mass/charge ratio, identification scores, intensity, gene and  protein names where it belongs, and more. </p>
    <p>The displayed columns can be changed by selecting specific columns. By default, unique rows are displayed, but all rows may be selected. 
    It is also possible to download filtered information in PDF or CSV format (all pages or current page only)</p>",
    is_id = FALSE,
    position = "bottom"
  )$
  step(
    "[data-value='Proteogenomics Viewer']",
    "Proteogenomics Viewer",
    "<p>This menu integrates genomic and proteomic data, providing a genetic view of peptides in a sliding panel with their respective Peptide 
    Spectrum and Peptide Expression.</p> 
    
    <p>The search is performed by the name of the gene of interest and, after selecting it, the identified variant 
    peptide sequences and its exonic location are shown.</p> ",
    is_id = FALSE,
    position = "bottom"
  )$
  step(
    "[data-value='Download Data']",
    "Download Data",
    "<p>Finally, this menu contains the files referring to the multi-fasta containing the mutated protein sequences
    and the log files containing information about SNPs identifiers, proteins, the position of the peptide in the
    protein, and mutated peptides and reference.</p>
    
    <p>It is also possible to obtain a detailed description of the information in each file and its respective construction process.</p>",
    is_id = FALSE,
    position = "bottom"
  )$
 step(
  "plots_sec1",
  "First section",
  "<p>The initial section reports the distribution of samples, peptide sequences, and unique polymorphisms filtered by cancer type or by variant type. <p>
   <p>The latter sections summarize different aspects of the database in graphical and table format. </p>
   <p>More specifically, dbPepVar users can view graphs of the distribution of peptides and SNPs by cancer type and mutation classification (SNPs graph only)</p>",
  is_id = TRUE,
  position = "top-center"
  )$
  step(
    "plots_sec2",
    "Second section",
    "<p>In the second section, users can explore and visualize the count of the most mutated genes, segregated by cancer type and with a responsive table explicitly showing the displayed data. </p>
     <p>As with all graphs in the portal, Plotly tools (i.e. lasso or box select) are available and allow comparing data, filtering by cancer type and gene groups from a threshold that can be defined 
     by counting SNPs identified per sample. The responsive table also allows to filter and visualize the number of samples that have a mutation in a specific gene according to the type of cancer.</p>
     
    <p> Similar analysis can be done with the graph and table provided in the following sections.</p>",
    is_id = TRUE,
    position = "top-center"
  )$
  step(
    "plots_sec3",
    "Third section",
    "<p>The third section of the first menu exhibits the number of SNPs per gene, which may be used to build a mutational panel for each cancer type and gene of interest.</p>",
    is_id = TRUE,
    position = "top-center"
  )$
  step(
    "plots_sec4",
    "Fourth and fifth sections",
    "<p>The fourth and fifth sections are dedicated to amino acid change counts by sample and by SNP, respectively. In this way, it is possible to observe, at the proteomic level, the most frequent amino acid exchanges for different cancers and SNPs, which may help understand which mutations propagate from the genome to the proteome.</p>",
    is_id = TRUE,
    position = "top-center"
  )$
  step(
    "plots_sec5",
    "Final sections",
    "<p>
    Two additional sections summarizing other layers of integrated information are then displayed, without tables: 
    one with chemical property changes of amino acids sorted by cancer type, where `Multiple' refers to samples with frame-shift mutations, 
    and another showing the distribution of mutated genes by chromosomal location.</p>
    
    <p>Thus, users can interactively perform two tasks: <br/>
    (i) filter and visualize the most frequent changes in amino acids according to cancer type, and <br/>
    (ii) filter and visualize the common exchanges between chemical groups of amino acids. 
    </p>",
    is_id = TRUE,
    position = "top-center"
  )

