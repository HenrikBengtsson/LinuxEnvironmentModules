#' @importFrom utils file_test
#' @export
modulepath <- function(drop = TRUE, normalize = TRUE, unique = TRUE) {
  modulepath <- envvar("MODULEPATH")
  paths <- unlist(strsplit(modulepath, split = ":", fixed = TRUE))
  if (unique) paths <- unique(paths)
  if (drop) paths <- paths[file_test("-d", paths)]
  if (normalize) paths <- unname(sapply(paths, FUN = normalizePath))
  paths
}

#' @export
modulepath_repos_path <- function(must_work = TRUE) {
  paths <- modulepath()
  ## RULE: Module repository modules are located in a folder named repos/
  paths2 <- paths[basename(paths) == "repos"]
  if (must_work) {
    if (length(paths2) == 0) {
      stop(sprintf("No 'repos/' folder in MODULEPATH (%s)", paste(sQuote(paths), collapse = ", ")))
    } else if (length(paths2) > 1) {
      stop(sprintf("More than one 'repos/' folder in MODULEPATH (%s): %s", paste(sQuote(paths), collapse = ", "), paste(sQuote(paths2), collapse = ", ")))
    }
  }
  paths2
}


#' @importFrom utils file_test
#' @export
modulepath_find_all_repos <- function(path = modulepath_repos_path(), drop = TRUE) {
  reposes <- dir(path = path, pattern = "[.]lua$", include.dirs = FALSE, no.. = TRUE, full.names = TRUE)
  reposes <- reposes[file_test("-f", reposes)]
  if (length(reposes) == 0) return(character(0L))

  parent <- dirname(path)
  paths <- c(setdiff(modulepath(), path), parent)
  
  names <- sub("[.]lua$", "", basename(reposes))

  res <- NULL
  for (name in names) {
    dir <- find_dir(name, paths = paths, must_work = FALSE)
    if (length(dir) == 0) {
      if (name == "Personal") {
        dir <- "~/modulefiles"
      }	else {
        ## FIXME: TIPCC hardcoded module repositories
        if (name == "Legacy-Scyld") {
          dir <- "/opt/scyld/modulefiles"
        } else if (name == "Legacy-etc") {
          dir <- "/etc/modulefiles"
        } else {
          dir <- find_dir(name, paths = paths)
        }
      }
    }
    names(dir) <- name
    res <- c(res, dir)
  }

  if (drop) res <- res[file_test("-d", res)]

  res
}


#' @export
modulepath_find_repos <- function(repos, must_work = TRUE) {
  paths <- modulepath_find_all_repos()
  path <- paths[repos]
  if (is.na(path)) {
    if (must_work) {
      stop(sprintf("No such module repository in MODULEPATH (%s): %s", paste(sQuote(modulepath), collapse = ", "), repos))
    }
    return(NULL)
  }
  path
}


#' @export
modulepath_list_repos <- function(repos, types = c("lmod"), rename = TRUE, format = c("tibble", "data.frame", "raw")) {
  format <- match.arg(format)
  path <- modulepath_find_repos(repos)

  res <- list()
  for (type in types) {
    modules <- lmod_spider_modules(path)

    if (rename) {
      ## Rename fields
      fields <- names(modules)
      fields[fields == "defaultVersionName"] <- "default_version"
      names(modules) <- fields
      modules <- reorder_by_name(modules, c("package", "description", "url", "default_version", "versions"))
      
      modules <- modules[fields]
    }

    res[[type]] <- modules
  }

  if (format == "raw") return(res)

  for (type in names(res)) {
    modules <- res[[type]]

    ns <- sapply(modules, FUN = length)
    stopifnot(all(ns == ns[1]))

    modules <- as.data.frame(modules, stringsAsFactors = FALSE)
    rownames(modules) <- NULL

    versions <- vector("list", length = nrow(modules))
    names(versions) <- modules$package
    help <- character(nrow(modules))
    
    version_data <- modules[["versions"]]
    defaults <- modules[["default_version"]]
    for (kk in seq_along(version_data)) {
      versions[[kk]] <- unique(trim(version_data[[kk]]$versionName))
      help_kk <- version_data[[kk]]$help
      if (length(help_kk) > 1L) {
        default <- which(versions[[kk]] == defaults[[kk]])
##	str(list(versions_kk = versions[[kk]], default = default, help_kk = help_kk))
	if (length(default) == 0) default <- 1L
	help_kk <- help_kk[default]
      }
      help[kk] <- help_kk
    }

    modules[["versions"]] <- versions
    modules[["help"]] <- help
    
    url <- modules[["url"]]
    url <- lapply(strsplit(url, split = "[,]"), FUN = trim)
    modules[["url"]] <- url

    modules <- reorder_by_name(modules, c("package", "help", "description", "url", "default_version", "versions"))

    if (format == "tibble") {
      modules <- tibble::as_tibble(modules)
    }
    
    res[[type]] <- modules
  }

  res
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
lmod_spider_modules <- function(path) {
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


