# Wrapper for plotly_build which removes reference objects, which makes
# caching possible.
plotly_build2 <- function(...) {
  p <- plotly::plotly_build(...)
  p$x[c("attrs", "visdat", "cur_data")] <- NULL
  print(p)
}