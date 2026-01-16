#' Run the QProMS Shiny application
#' 
#' Launches QProMS with automatic dependency installation.
#' 
#' @param launch.browser If true, launch browser automatically
#' @param port TCP port for the server  
#' @param host IPv4 address to bind to
#' 
#' @export
run_qproms <- function(launch.browser = TRUE, port = NULL, host = "127.0.0.1") {
  
  cat("🧬 QProMS - Quantitative Proteomics Made Simple\n\n")
  
  # AUTO-INSTALL deps (stesso codice di prima)
  bioc_deps <- c(
    "vsn", "clusterProfiler", "OmnipathR",
    "org.Hs.eg.db", "org.Mm.eg.db", "org.EcK12.eg.db",
    "org.Dm.eg.db", "org.Sc.sgd.db"
  )
  
  cran_deps <- c(
    "shiny", "rhino", "gargoyle", "box", "shinyalert",
    "trelliscopejs", "heatmaply", "openxlsx", "echarts4r",
    "esquisse", "reactable", "rhandsontable", "rlist", 
    "rbioapi", "viridis", "quarto", "here"
  )
  
  missing_bioc <- bioc_deps[!bioc_deps %in% rownames(installed.packages())]
  if(length(missing_bioc) > 0) {
    cat("📦 Installing", length(missing_bioc), "Bioconductor dependencies...\n")
    if(!"BiocManager" %in% rownames(installed.packages())) {
      install.packages("BiocManager", ask = FALSE)
    }
    BiocManager::install(missing_bioc, ask = FALSE, update = FALSE)
    cat("✅ Bioconductor dependencies OK\n\n")
  }
  
  missing_cran <- cran_deps[!cran_deps %in% rownames(installed.packages())]
  if(length(missing_cran) > 0) {
    cat("🚀 Installing", length(missing_cran), "CRAN dependencies...\n")
    install.packages(missing_cran, ask = FALSE)
    cat("✅ CRAN dependencies OK\n\n")
  }
  
  if(!"trelliscope" %in% rownames(installed.packages())) {
    cat("🚀 Installing trelliscope from GitHub...\n")
    if(!"remotes" %in% rownames(installed.packages())) {
      install.packages("remotes", ask = FALSE)
    }
    remotes::install_github("trelliscope/trelliscope")
    cat("✅ trelliscope installed\n\n")
  }
  
  cat("🚀 Launching QProMS...\n\n")
  
  # Run app from package directory
  pkg_dir <- system.file(package = "qproms")
  
  # Run using app.R which calls rhino::app()
  app_file <- file.path(pkg_dir, "app.R")
  
  if (!file.exists(app_file)) {
    stop("app.R not found in package directory", call. = FALSE)
  }
  
  shiny::runApp(
    appDir = pkg_dir,
    launch.browser = launch.browser,
    port = port,
    host = host
  )
}
