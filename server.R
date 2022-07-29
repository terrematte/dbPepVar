# ==== server.R ===============================================================
server <- function(input, output, session) {
  # suppress warnings  
  storeWarn<- getOption("warn")
  options(warn = -1) 
  w <- Waiter$new(id = c("tb_dbPepVar", "tb_BrCa"))
  
  data <- dbPepVar %>% 
    dplyr::select(c("Cancer_Type", "Gene", "Variant_Classification", "Refseq_protein",  "snp_id", "HGVSp", "Change", "Chromosome"))  %>% 
    unique()

  dataCancerSamples <- count(dbPepVar, Cancer_Type, Sample) %>% count(Cancer_Type)
  
  dataCancerSequence <- cbind(Cancer_Type = c("BrCa", "CrCa", "OvCa", "PrCa"),
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
  
  # output$spinner <- renderUI({
  #   if(is.null(globalrv())){
  #     shinycssloaders::withSpinner(uiOutput("dummy"))
  #   } else {
  #     NULL
  #   }
  # })

 
  # Bar plot of Samples by Cancer Type  ----
  output$fig.barCancerSamples <- renderPlotly({
    plot_ly(data = dataCancerSamples , x = ~Cancer_Type, y = ~n, type = 'bar',
                  text = ~n, textposition = 'auto',
                  marker = list(color = c('rgba(31, 119, 180, 1)', 'rgba(255, 127, 14, 1)',
                                          'rgba(44, 160, 44, 1)', 'rgba(214, 39, 40, 1)'))) %>%
       layout(yaxis = list(title = '#Samples by Cancer Type'),
             xaxis = list(title = "Cancer_Type", tickangle = -45),
             font  = list(size = 10))
  })
 
  # Bar plot of Cancer_Type of Unique Sequence  ----
  output$fig.barCancerSequence <- renderPlotly({
     plot_ly(data = dataCancerSequence, x = ~Cancer_Type, y = ~n, type = 'bar',
                 text = ~n, textposition = 'auto',
                 marker = list(color = c('rgba(31, 119, 180, 1)', 'rgba(255, 127, 14, 1)',
                                         'rgba(44, 160, 44, 1)', 'rgba(214, 39, 40, 1)'))) %>% 
      layout(yaxis = list(title = '#Sequence by Cancer Type'), 
             xaxis = list(title = "Cancer_Type", tickangle = -45),
             font  = list(size = 10))
  })
  
  # Pie chart of Cancer_Type of Unique SNPs  ----
  output$fig.pieCancerSNP <- renderPlotly({
    plot_ly() %>% 
      add_pie(data = dataSNPCancer_Type, labels = ~Cancer_Type, values = ~n, 
              hole = 0, name = "Cancer_Type", textinfo='label+percent', insidetextorientation='radial', sort = FALSE) %>% 
      layout(title = "#Unique SNPs by Cancer Type", showlegend = T,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             font  = list(size = 10))
  })
  
  # Pie chart of Variant_Classification of Unique SNPs  ----
  output$fig.pieVarClassif <-renderPlotly({
    plot_ly() %>% 
      add_pie(data = count(data, Variant_Classification), labels = ~Variant_Classification, values = ~n,
              hole = 0, name = "Variant_Classification", rotation = 180,
              textinfo='label+percent', insidetextorientation='radial') %>% 
      #add_trace(y = .Variant_Classification, name = "Missense_Mutation", visible = "legendonly") %>% 
      layout(title = "#Unique SNPs by Variant Classification", showlegend = T,
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             font  = list(size = 10),
             margin = list(t = 50, b = 120, l = 70, r = 100))
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
      style="border:0;")
  })

}
