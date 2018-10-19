trim <- function(x) {
  if (!is.character(x)) return(x)
  x <- sub("^[\t\n\f\r ]*", "", x)
  sub("[\t\n\f\r ]*$", "", x)
}

#' @importFrom commonmark markdown_html
as_html <- function(x) {
  if (!is.character(x)) return(x)
  x <- markdown_html(x, extensions = TRUE)
  x <- gsub("(^<p>|</p>\n$)", "", x)
  x <- gsub("\\n", "<br>\n", x)
  x
}


envvar <- function(name, default = NA_character_) {
  value <- Sys.getenv(name, unset = default, names = FALSE)
  if (is.na(value))
      stop(sprintf("Environment variable %s is not set", sQuote(name)))
  value
}



#' @importFrom utils file_test
#' @export
find_dir <- function(name, paths, must_work = TRUE) {
  pattern <- sprintf("^%s$", name)
  for (path in paths) {
    dirs <- dir(path = path, pattern = pattern, include.dirs = FALSE, no.. = TRUE, full.names = TRUE)
    dirs <- dirs[file_test("-d", dirs)]
    if (length(dirs) > 0) return(dirs)
  }
  if (must_work) {
    stop(sprintf("No such folder in paths (%s): %s", paste(sQuote(paths), collapse = ", "), name))
  }
  NULL
}


#' @export
reorder_by_name <- function(x, preferred) {
  names <- intersect(preferred, names(x))
  names <- c(names, setdiff(names(x), names))
  x[names]
}


#' @export
as_html_table_tds <- function(x, collapse = "\n") {
  html <- NULL
  for (kk in seq_len(nrow(x))) {
    module <- x[kk, ]

    module <- as.list(module)
    versions <- unlist(module$versions)
    idx <- which(versions == module$default_version)
    versions[idx] <- sprintf("<em>%s</em>", versions[idx])
    versions <- paste(versions, collapse = ", ")

    tds <- NULL
    
    body <- c("<strong>", module$package, "</strong>", "<br>", versions)
    tds <- c(tds, "<td>", body, "</td>")

    body <- c("<strong>", as_html(module$help), "</strong>", "<br>")
    body <- c(body, as_html(module$description), "<br>")
    body <- c(body, as_html(paste(unlist(module$url), collapse = ", ")))
    tds <- c(tds, "<td>", body, "</td>")

    html_kk <- c("<tr>", tds, "</tr>")
    html <- c(html, html_kk)
  } # for (kk in ...)

  html <- paste(html, collapse = collapse)
  
  html
}

#' @export
as_html_table <- function(x, label = "module &amp; versions", collapse = "\n") {
  ths <- c("<td>", label, "</td>", "<td>", "description", "</td>")
  hdr <- c("<tr>", ths, "</tr>")
  rows <- as_html_table_tds(x, collapse = NULL)
  html <- c("<table>", hdr, rows, "</table>")
  html <- paste(html, collapse = collapse)
  html
}
