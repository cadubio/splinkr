#' Read speciesLink datasets
#'
#' This function returns the search results from speciesLink network records.
#'
#'
#' @param scientificName Character vector containing one or more single or compound names, without authors
#' @param barcode Character vector containing one or more institution barcode
#' @param catalogNumber Character vector containing one or more institution catolog number
#' @param basisOfRecord PreservedSpecimen, LivingSpecimen, FossilSpecimen, HumanObservation, MachineObservation, MaterialSample
#' @param collectionCode Character vector containing collections or subcollections acronym
#' @param collector Character vector containing one or more colletor name
#' @param collectorNumber Character vector containing collector number
#' @param yearCollected Numeric four-digits collect year
#' @param identifiedBy Character vector identificator name
#' @param yearIdentified Numeric four-digits year of identifications
#' @param kingdom Character vector containing kingdon name
#' @param phylum Character vector containing phyllum name
#' @param class Character vector containing class name
#' @param order Character vector containing order name
#' @param family Character vector containing family name
#' @param typus If "yes" search only in type material variable
#' @param country Character vector containing collect country
#' @param stateProvince Character vector containing state
#' @param county Character vector containing collect county or city
#' @param locality Character vector containingcollect locality
#' @param redlist If "yes" return only taxa in Portaria MMA 443/2014
#' @param maxrecords Character vector to restrict number of records to return
#'
#' @return `data.frame()` with the records
#' @export
#'
#' @examples
#' \dontrun{
#' # Searching taxon
#' splinkr_records(scientificName = "Dyckia encholirioides var. rubra")
#'
#' # Searching taxa collected by collector
#' splinkr_records(scientificName = c("Anathallis kleinii",
#'                                    "Anathallis microphyta"),
#'                 collector = "Siqueira")
#'
#' # Searching all types from
#' # one collection
#' splinkr_records(collectionCode = "FLOR", typus = "yes")
#'
#' # two collections
#' splinkr_records(collectionCode = c("FLOR", "FURB"), typus = "yes")
#' }
splinkr_records <- function(scientificName = NULL,
                       barcode = NULL,
                       catalogNumber = NULL,
                       basisOfRecord = NULL,
                       collectionCode = NULL,
                       collector = NULL,
                       collectorNumber = NULL,
                       yearCollected = NULL,
                       identifiedBy = NULL,
                       yearIdentified = NULL,
                       kingdom = NULL,
                       phylum = NULL,
                       class = NULL,
                       order = NULL,
                       family = NULL,
                       typus = NULL,
                       country = NULL,
                       stateProvince = NULL,
                       county = NULL,
                       locality = NULL,
                       redlist = NULL,
                       maxrecords = NULL
                       ) {
    # if (is.null(scientificName) && is.null(barcode) && is.null(catalogNumber)) {
    #   stop("Error in records operation: Value to argument 'scientificName', 'barcode' and 'catalogNumber' cannot be NULL.\n \tAt least a single (Genus) or binomial (Genus epiteth) name \nor barcode or catalogNumber must be informed.")
    # } else
    # *scientificName*, *barcode* and *catalogNumber* are mutual excludent arguments
    # *catalogNumber*
    if ((!is.null(scientificName) && !is.null(barcode)) || (!is.null(scientificName) && !is.null(catalogNumber)) || (!is.null(barcode) && !is.null(catalogNumber))) {
      stop("Error in records operation: *scientificName*, *barcode* and *catalogNumber* are mutual excludent arguments. Choose just one of them!")
    }
    else
      if (!is.null(barcode)) {
        # "https://api.splink.org.br/records/format/xml/barcode/"
        vector_barcodes <- paste0(barcode, collapse = "/")
        url_base <- paste0("https://api.splink.org.br/records/format/xml/barcode/",
                           vector_barcodes)
        read_splink <- xml2::read_xml(url_base)
        url_parsed <- XML::xmlParse(read_splink)
        splink_records <- XML::xmlToDataFrame(nodes = XML::getNodeSet(url_parsed, "//record"))
        tibble::as_tibble(splink_records)

      } else
        if (!is.null(catalogNumber)) {
          #  "https://api.splink.org.br/records/format/xml/catalogNumber/"
          vector_catalogNumber <- paste0(catalogNumber, collapse = "/")
          url_base <- paste0("https://api.splink.org.br/records/format/xml/catalogNumber/",
                             vector_catalogNumber)
          read_splink <- xml2::read_xml(url_base)
          url_parsed <- XML::xmlParse(read_splink)
          splink_records <- XML::xmlToDataFrame(nodes = XML::getNodeSet(url_parsed, "//record"))
          tibble::as_tibble(splink_records)
        }
    # is not *scientificName* null
    else {
      # url <- "https://api.splink.org.br/records/format/xml/"

      parametros <- as.list(match.call())[-1]
      nomes <- vector("character", length = 0L)
      vetor_nomes <- vector("character", length = 0L)
      vetor_url <- vector("character", length = 0L)
      for (i in seq_along(parametros)) {

        nomes[i] <- paste(eval(parametros[[i]]), sep = "/", collapse = "/")

        vetor_nomes[i] <- gsub(pattern = "\\s", replacement = "%20", nomes[i])

        vetor_url[i] <- paste0(names(parametros[i]), "/", vetor_nomes[i])
      }
      vetor2_url <- paste0(vetor_url, collapse = "/")
      url_full <- paste0("https://api.splink.org.br/records/format/xml/", vetor2_url)

      read_splink <- xml2::read_xml(url_full)
      url_parsed <- XML::xmlParse(read_splink)
      splink_records <- XML::xmlToDataFrame(nodes = XML::getNodeSet(url_parsed, "//record"))
      tibble::as_tibble(splink_records)

    }
}
