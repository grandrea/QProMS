#' Run the QProMS Shiny application
#' 
#' Launches QProMS with automatic dependency installation.
#' 
#' @param launch.browser If true, the system's default web browser will be launched automatically after the app is started.
#' @param port The TCP port that the server should listen on. Defaults to choosing a random port.
#' @param host The IPv4 address that the host will bind to. Defaults to the `host` option set in the options list passed to `shiny::runApp()`.
#' 
#' @export
#' @importFrom shiny runApp
#' @importFrom utils installed.packages
run_qproms <- function(launch.browser = TRUE, port = NULL, host = "127.0.0.1") {
  
  cat("🚀 QProMS - Quantitative Proteomics Made Simple\n\n")
  
  # AUTO-INSTALL Bioconductor deps
  bioc_deps <- c(
    "vsn", "clusterProfiler", "OmnipathR",
    "org.Hs.eg.db", "org.Mm.eg.db", "org.EcK12.eg.db",
    "org.Dm.eg.db", "org.Sc.sgd.db"
  )
  
  cran_deps <- c(
    "shiny", "rhino", "gargoyle", "box", "shinyalert",
    "trelliscopejs", "heatmaply", "openxlsx", "echarts4r",
    "esquisse", "reactable", "rhandsontable", "rlist", 
    "rbioapi", "viridis", "quarto"
  )
  
  # Check + install Bioc deps
  missing_bioc <- bioc_deps[!bioc_deps %in% rownames(installed.packages())]
  if(length(missing_bioc) > 0) {
    cat("🚀 Installing", length(missing_bioc), "Bioconductor dependencies...\n")
    if(!"BiocManager" %in% rownames(installed.packages())) {
      cat("  → Installing BiocManager...\n")
      install.packages("BiocManager", ask = FALSE)
    }
    BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
    cat("✅ Bioconductor dependencies OK\n\n")
  }
  
  # Check + install CRAN deps
  missing_cran <- cran_deps[!cran_deps %in% rownames(installed.packages())]
  if(length(missing_cran) > 0) {
    cat("🚀 Installing", length(missing_cran), "CRAN dependencies...\n")
    install.packages(missing_cran, ask = FALSE)
    cat("✅ CRAN dependencies OK\n\n")
  }
  
  # Launch app
  app_dir <- system.file("shiny/qproms", package = "qproms")
  if(app_dir == "") {
    stop("❌ QProMS app not found. Reinstall with:\n   remotes::install_github('ieoresearch/QProMS@branch')", call. = FALSE)
  }
  
  cat("🚀 Launching QProMS on", host, ifelse(is.null(port), "random port", port), "\n")
  shiny::runApp(app_dir, launch.browser = launch.browser, port = port, host = host)
}




