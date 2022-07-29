plotbarCancerSamples <- memoize2(function(df) {
  cat("\nPrint! Before", file = "bind-cache/log", append = T)
  p <- plot_ly(data = df , x = ~df[[1]], y = ~n, type = 'bar',
               text = ~n, textposition = 'auto',
               marker = list(color = c('rgba(31, 119, 180, 1)', 'rgba(255, 127, 14, 1)',
                                       'rgba(44, 160, 44, 1)', 'rgba(214, 39, 40, 1)'))) %>%
    layout(yaxis = list(title = '#Samples by Cancer Type'), 
           xaxis = list(title = "Cancer_Type", tickangle = -45),
           font  = list(size = 10))
  plotly_build2(p)
  cat("\nPrint! After", file = "bind-cache/log", append = T)
})