memoize <- function(fn, cache = memoryCache()) {
  # Strip source refs so they don't cause spurious differences in hashing.
  fn <- removeSource(fn)
  
  # Hash the function itself. This will be used later when hashing the
  # arguments. This allows multiple functions that take the same args to use the
  # same cache store without collisions. The reason that a list with body,
  # formals, and env is used is because if we just hash the function directly,
  # it can end up with a different hash before and after bytecode-compilation
  # (and compilation happens as a side effect of invoking the function a few
  # times).
  fn_hash <- digest::digest(
    list(body(fn), formals(fn), environment(fn)),
    "xxhash64"
  )
  
  function(...) {
    args <- list(...)
    key <- digest::digest(list(fn_hash, args), "xxhash64")
    result <- cache$get(key)
    
    if (is.key_missing(result)) {
      result <- withVisible(fn(...))
      cache$set(key, result)
    }
    
    if (result$visible) {
      result$value
    } else{
      invisible(result$value)
    }
  }
}