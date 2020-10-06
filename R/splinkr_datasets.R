#' Read speciesLink datasets
#'
#' Returns a `tibble` with all or filtered datasets available in the speciesLink for searching.
#'
#' @param filter Character vector containing one or more terms to filter datasets
#'
#' @return `data.frame()` with the datasets
#'
#' @export
#'
#' @examples
#' # return all datasets
#' splinkr_datasets()
#'
#' # Filtering datasets. Terms order defines filtering
#' # The second term will be searched in subset of datasets created
#' # by the first term. The third term will be searched in the (sub)subset of
#' # the second term and so on.
#' splinkr_datasets(filter = c("universidade", "xiloteca", "Brasil"))
#'
splinkr_datasets <- function(filter = NULL) {
  # Creata a dataset from especiesLink datasets ------------------
  # especiesLink datasets
  read_splink <- xml2::read_xml("https://api.splink.org.br/datasets/format/xml/")

  # parse XML
  url_parsed <- XML::xmlParse(read_splink)

  # Transforme XML structure to data.frame
  splink_datasets <- XML::xmlToDataFrame(nodes = XML::getNodeSet(url_parsed, "//record"))

  # Filter datasets
  if (length(filter) >= 1) {

    bd <- vector("list")
    bd[[1]] <- splink_datasets
    #filtro <- stringi::stri_trans_general(filter, id = "Latin-ASCII")

    for (i in seq_along(filter)) {
      bd[[i + 1]] <- dplyr::filter_all(bd[[i]],
                                       dplyr::any_vars(grepl(filter[i], .,
                                                             ignore.case = TRUE)))
    }
    return(tibble::as_tibble(bd[[length(bd)]]))
  }
  # If filter arguments aren't provided return all datasets available on the speciesLink network
  else
    return(tibble::as_tibble(splink_datasets))
}

