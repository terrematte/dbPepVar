load("portal/data/dbPepVar_snps.Rda")

if(!require(DT)){ install.packages('DT') }

cols <- c("Hugo_Symbol", "Tumor_Sample_Barcode", "Refseq_protein", "Variant_Classification", "HGVSp", "snp_id",  "Cancer_Type", "i_transcript_name")
dbPepVar_snps <- as.data.frame(dbPepVar_snps)
dbPepVar <- dbPepVar_snps[,cols]

db <- DT::datatable(dbPepVar,  
          class = 'cell-border stripe',
          #extensions = 'Buttons', 
          #options = list(dom = 'Bfrtip', buttons = c('csv', 'pdf'))# slow
          #caption = 'Table 1: This is a simple caption for the table.',
          #options = list(searchHighlight = TRUE), # slow
          #filter = 'top' # slow
          )

saveWidget(db, 
           title = "dbPepVar: SNPs Search",
           'portal/index.html')


if (!dir.exists("~/public_html/dbPepVar/")) {dir.create("~/public_html/dbPepVar/")}

saveWidget(db, 
           title = "dbPepVar: SNPs Search",
           '~/public_html/dbPepVar/index.html')
