#' @importFrom utils file_test
#' @export
modulepath <- function() {
  modulepath <- envvar("MODULEPATH")
  paths <- unlist(strsplit(modulepath, split = ":", fixed = TRUE))
  paths
}


#' @importFrom utils file_test
#' @export
modulepath_list_repos <- function(paths = modulepath()) {
  res <- list()
  for (path in paths) {
    stopifnot(file_test("-d", path))
    path <- normalizePath(path)
    reposes <- dir(path = path, include.dirs = TRUE, no.. = TRUE, full.names = TRUE)
    reposes <- reposes[file_test("-d", reposes)]
    names(reposes) <- basename(reposes)
    
    res[[path]] <- reposes
  }
  
  res
}


#' @importFrom utils file_test
#' @export
modulepath_find_repos <- function(repos, must_work = TRUE, paths = modulepath()) {
  for (path in paths) {
    stopifnot(file_test("-d", path))
    path <- normalizePath(path)
    reposes <- dir(path = path, include.dirs = TRUE, no.. = TRUE, full.names = TRUE)
    reposes <- reposes[file_test("-d", reposes)]
    names(reposes) <- basename(reposes)
    idx <- which(repos == names(reposes))[1]
    if (!is.na(idx)) return(repos[idx])
  }

  if (must_work) {
    stop(sprintf("No such module in MODULEPATH (%s): %s", paste(sQuote(paths), collapse = ", "), repos))
  }
  
  NULL
}


#' @importFrom utils file_test
#' @importFrom jsonlite fromJSON
lmod_spider <- function(args, ...) {
  spider <- file.path(envvar("LMOD_DIR"), "spider")
  stopifnot(file_test("-x", spider))
  res <- system2(spider, args = args, stdout = TRUE, stderr = TRUE, ...)
  status <- attr(res, "status")
  if (!is.null(status) && status != 0) {
    stop(sprintf("System call %s failed (exit code %d):\n%s\n", paste(shQuote(c(spider, args)), collapse = " "), status, paste(res, collapse = "\n")))
  }
  res
}


#' @importFrom utils file_test
#' @importFrom jsonlite fromJSON
#' @export
lmod_module_avail <- function(repos) {
  path <- modulepath_find_repos(repos, must_work = TRUE)
  
  json <- lmod_spider(args = c("-o jsonSoftwarePage", path))
  x <- fromJSON(json)
  
  if (length(x) > 1L) {
    o <- order(x$package)
    x <- x[o,]
  }

  if (length(x) > 0L) {
    keep <- !grepl("^[.]", x$package)
    x <- x[keep,]
  }
  
  x
}


