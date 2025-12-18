#' Run the QProMS Shiny application
#'
#' This function launches the QProMS Shiny app in the default web browser.
#'
#' @export
run_qproms <- function() {
  app_dir <- system.file("shiny/qproms", package = "qproms")
  if (app_dir == "") {
    stop("QProMS app directory not found. Reinstall the 'qproms' package.", call. = FALSE)
  }

  shiny::runApp(app_dir, launch.browser = TRUE)
}




