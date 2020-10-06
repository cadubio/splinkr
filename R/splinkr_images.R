#' Display or download image records
#'
#' This function allows viewing the records of the speciesLink network with images.
#' Future plains to download the images.
#'
#' @param imagecode Carachter vector containing image codes
#' @param scientificName Character vector containing one or more single or compound names, without authors
#' @param path Path to save image (not implemented yet)
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Display image by image codes
#' splinkr_images(imagecode = "FLOR0037759")
#'
#' splinkr_images(imagecode = c("FLOR0037759", "UEC190851"))
#'
#' # Display image by scientific names
#' splinkr_images(scientificName = c("Spigelia insignis", "Anathallis kleinii"))
#' }
splinkr_images <- function(imagecode = NULL,
                           scientificName = NULL,
                           path) {

  if (!is.null(scientificName) && !is.null(imagecode)) {
    stop("Error: *scientificName*, *imagecode* are mutual excludent arguments. Choose just one of them!")
  }
  else {
    if (!is.null(scientificName)) {

  df <- splinkr::splinkr_records(scientificName = scientificName)

  # imagecodes
  image_codes <- df %>%
    dplyr::select(scientificName, imagecode) %>%
    dplyr::mutate(compr = nchar(imagecode)) %>%
    dplyr::filter(compr < 12, !is.na(imagecode)) %>%
    dplyr::select(imagecode)

  # text names saved in images
  image_names <- df %>%
    dplyr::select(scientificName, imagecode) %>%
    dplyr::mutate(compr = nchar(imagecode)) %>%
    dplyr::filter(compr < 12, !is.na(imagecode)) %>%
    dplyr::select(scientificName) %>%
    split(., seq(nrow(.)))
    }

    if (!is.null(imagecode)) {
      image_codes <- imagecode %>%
        dplyr::mutate(compr = nchar(imagecode)) %>%
        dplyr::filter(compr < 12, !is.na(imagecode)) %>%
        dplyr::select(imagecode)

      vector_barcodes <- sapply(image_codes, FUN = paste0, collapse = "/", simplify = TRUE)
      url_base <- paste0("https://api.splink.org.br/records/format/xml/barcode/",
                         vector_barcodes)
      read_splink <- xml2::read_xml(url_base)
      url_parsed <- XML::xmlParse(read_splink)
      splink_records <- XML::xmlToDataFrame(nodes = XML::getNodeSet(url_parsed, "//record"))

      image_names <- splink_records %>%
        dplyr::select(scientificName, imagecode) %>%
        dplyr::mutate(compr = nchar(imagecode)) %>%
        dplyr::filter(compr < 12, !is.na(imagecode)) %>%
        dplyr::select(scientificName) %>%
        split(., seq(nrow(.)))
    }
  }

  # Download images
  image_imlist <- image_codes %>%
    purrr::pmap(~ paste0("http://reflora.cria.org.br/inct/exsiccatae/image/imagecode/", ., "/size/large/")) %>%
    purrr::map(~ imager::load.image(.))

  # Add names to images
  image_list <- purrr::pmap(list(image_imlist, image_names),
                           function (x, y)
                            imager::implot(x, graphics::text(150, 80, labels = y, cex = 1, col = "red")))

  # Show images
  imager::display(image_list)
}
