if(!require(DT)){ install.packages('DT') }

setwd("~/dbPepVar/")

load("data/dbPepVar_snps.Rda")
f <-  "data/dbPepVar_PTC_Peptides.tsv"
dbPepVar <- read.table(f, header = T, sep="\t", stringsAsFactors=F, quote='"')

dbPepVar$ptc <- ifelse(dbPepVar$ptc == 1, "TRUE", "FALSE")

#  Page of a table of each Peptide mutation per sample

db <- DT::datatable(dbPepVar,  
                    class = 'cell-border stripe',
                    rownames = FALSE,
                    filter = 'top',
                    #extensions = c('Responsive', 'Buttons'),
                    extensions = c('Buttons'), 
                    options = list(
                      searchHighlight = TRUE,
                      #pageLength = 15,
                      orientation ='landscape',
                      #lengthMenu = list(c(6, 12, 15, -1), c('6', '12', '15', 'All')),
                      dom = 'Bfrtip',
                      buttons = 
                        list('pageLength', 'colvis', 
                             list(extend = 'pdf',                
                                  text = '<i class="fa fa-file-pdf-o"></i>', 
                                  pageSize = 'A4',
                                  orientation = 'landscape',
                                  filename = 'dbPepVar'
                             ),
                             list(extend = 'csv',
                                  text = '<i class="fa fa-file-text-o"></i>',
                                  filename = 'dbPepVar'
                             )
                        )
                      #options = list(dom = 'Bfrtip', buttons = c('csv', 'pdf'))# slow
                      #caption = 'Table 1: This is a simple caption for the table.',
                      #options = list(searchHighlight = TRUE), # slow
                    ))


saveWidget(db, 
           title = "dbPepVar: Peptide Search",
           'portal/index.html')



#  Page of a table of each SNP mutation per sample

dbPepVar_snps <- as.data.frame(dbPepVar_snps)
cols <- c("Hugo_Symbol", "Tumor_Sample_Barcode", "Refseq_protein", "Variant_Classification", "HGVSp", "snp_id",  "Cancer_Type", "i_transcript_name")
dbPepVar <- dbPepVar_snps[,cols]


db <- DT::datatable(dbPepVar,  
                    class = 'cell-border stripe',
                    rownames = FALSE,
                    filter = 'top',
                    extensions = c('Responsive', 'Buttons'), 
                    options = list(
                      searchHighlight = TRUE,
                      pageLength = 15,
                      orientation ='landscape',
                      lengthMenu = list(c(6, 12, 15, -1), c('6', '12', '15', 'All')),
                      dom = 'Bfrtip',
                      buttons = 
                        list('pageLength', 'colvis', 
                             list(extend = 'pdf',                
                                  pageSize = 'A4',
                                  orientation = 'landscape',
                                  filename = 'dbPepVar'
                             ),
                             list(extend = 'csv',
                                  filename = 'dbPepVar'
                             )
                        )
                      #options = list(dom = 'Bfrtip', buttons = c('csv', 'pdf'))# slow
                      #caption = 'Table 1: This is a simple caption for the table.',
                      #options = list(searchHighlight = TRUE), # slow
                    ))

saveWidget(db, 
           title = "dbPepVar: SNPs Search",
           'portal/dbPepVar_snps.html')

