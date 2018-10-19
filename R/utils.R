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
