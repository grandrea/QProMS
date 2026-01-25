box::use(
  shiny[moduleServer, fluidPage, titlePanel, renderTable, tableOutput, em, h2, h5, hr, strong, tags, fluidRow, column, h4, p, wellPanel, NS, selectInput, br, actionButton, fileInput, radioButtons, observeEvent, observe, div, icon, req, uiOutput, renderUI, updateSelectInput, removeUI],
  bslib[page_fillable, card, card_header, card_body, layout_columns, layout_sidebar, tooltip, navset_card_underline, nav_panel, sidebar, accordion, accordion_panel, nav_select, input_switch, toggle_sidebar, nav_remove, input_task_button],
  reactable[reactableOutput, renderReactable, reactable, colDef],
  rhandsontable[rHandsontableOutput, renderRHandsontable, hot_to_r],
  purrr[map, set_names, imap, keep_at, flatten_chr, discard_at],
  stringr[word, str_remove],
  dplyr[`%>%`, filter, select],
  gargoyle[init, watch, trigger],
  shinyWidgets[radioGroupButtons],
)

box::use(
  app/static/inputs_type_lists
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  
    fluidPage(
      fluidRow(
        column(
          width = 12,
          h2("Proteomics data upload guide"),
          p(
            "This page guides you through the upload of proteomics data and explains ",
            strong("which columns are required"),
            " for each supported software."
          )
        )
      ),
      hr(),
      fluidRow(
        column(
          width = 12,
          h4("Select the source software"),
          radioButtons(
            inputId = ns("software"),
            label = "",
            choices = c("MaxQuant", "Proteome Discoverer (PD)"= "PD", "FragPipe", "DIA-NN", "Spectronaut", "AlphaPept"),
            inline = TRUE
          )
        )
      ),
      br(),
      card(
        card_header("Expected input file"),
        card_body(
          uiOutput(ns("file_info"))
        )
      ),
      card(
        card_header("Required metadata columns"),
        card_body(
          tableOutput(ns("metadata_table"))
        )
      ),
      card(
        card_header("Supported intensity columns"),
        card_body(
          tableOutput(ns("intensity_table")),
          tags$small(em("Sample names must be consistent across intensity columns."))
        )
      ),
      accordion(
        accordion_panel(
          title = "Software-specific notes",
          uiOutput(ns("software_notes"))
        )
      ),
      br(),
      card(
        card_header("Common issues"),
        card_body(
          tags$ul(
            tags$li("Manually renamed columns"),
            tags$li("Excel files with formatting"),
            tags$li("Incorrect field separators"),
            tags$li("Duplicated sample names"),
            tags$li("Less then 3 replicate for each condition will not allow for statistical analysis.")
          )
        )
      ),
      br(),
      card(
        class="border border-info",
        card_header("Custom input tables"),
        card_body(
          p(
            "If your data were generated using a different software, you can upload a custom table. ",
            "Only a minimal set of columns is required."
          ),
          h5("Required columns"),
          tags$ul(
            tags$li(
              strong("Gene"),
              " – Gene identifier used for annotation and downstream analyses. Must be unique!"
            ),
            tags$li(
              strong("Intensity columns (one per sample)"),
              " – Quantitative values for each sample. Column names are interpreted as sample identifiers."
            )
          ),
          tags$small(
            em("Additional columns are allowed and will be ignored if not used by the analysis.")
          )
        )
      )
    )
  }
  

#' @export
server <- function(id, r6, main_session) {
  moduleServer(id, function(input, output, session) {
    
    ns <- session$ns
    
    metadata_list <- inputs_type_lists$metadata_list
    intensity_list <- inputs_type_lists$intensity_list
    
    output$file_info <- renderUI({
      switch(
        input$software,
        "MaxQuant" = tags$ul(
          tags$li("Format: .txt"),
          tags$li("File: proteinGroups.txt"),
          tags$li("Header row required"),
          tags$li("No manual modification required")
        ),
        "PD" = tags$ul(
          tags$li("Format: .txt"),
          tags$li("Header row required"),
          tags$li("No manual modification required")
        ),
        "FragPipe" = tags$ul(
          tags$li("Format: .tsv"),
          tags$li("File: combined_protein.tsv"),
          tags$li("Standard FragPipe output")
        ),
        "DIA-NN" = tags$ul(
          tags$li("Format: .txt"),
          tags$li("File: report.unique_genes_matrix.txt"),
          tags$li("Samples are identified via the .mzML filename")
        ),
        "Spectronaut" = tags$ul(
          tags$li("Format: .tsv"),
          tags$li("File: Report.tsv"),
          tags$li("Protein group–level report")
        ),
        "AlphaPept" = tags$ul(
          tags$li("Format: .csv"),
          tags$li("File: results_proteins.csv"),
          tags$li("No or minimal manual modification required")
        )
      )
    })
    
    output$metadata_table <- renderTable({
      data.frame(
        Column = metadata_list[[input$software]],
        Required = TRUE,
        check.names = FALSE
      )
    })
    
    output$intensity_table <- renderTable({
      intensities <- intensity_list[[input$software]]
      
      if (length(intensities) == 1) {
        data.frame(
          Pattern = intensities,
          Description = "Pattern used to identify sample-specific intensity columns",
          check.names = FALSE
        )
      } else {
        data.frame(
          Column_or_pattern = intensities,
          Description = "Supported intensity column",
          check.names = FALSE
        )
      }
    })
    
    output$software_notes <- renderUI({
      switch(
        input$software,
        "MaxQuant" = tags$ul(
          tags$li("Support for LFQ, iBAQ, and raw intensity values"),
          tags$li("Peptides, Unique Peptides and Razor + Unique Peptides columns are used for QC filtering"),
          tags$li("Reverse Potential contaminant and Only identified by site columns are used for QC filtering")
        ),
        "PD" = tags$ul(
          tags$li("Support for Abundance, and Abundances (Normalized) intensity values"),
          tags$li("Peptides, Unique Peptides and Razor Peptides columns are used for QC filtering")
        ),
        "FragPipe" = tags$ul(
          tags$li("Support for MaxLFQ Intensity and Intensity values"),
          tags$li("Gene and Protein ID columns are mandatory")
        ),
        "DIA-NN" = tags$ul(
          tags$li("Columns containing .mzML and .raw are used to identify samples"),
          tags$li("Exporting report.tsv is recommended")
        ),
        "Spectronaut" = tags$ul(
          tags$li("Support for PG.Quantity, PG.MS1Quantity, and PG.MS2Quantity"),
          tags$li("Protein identification is based on protein groups")
        ),
        "AlphaPept" = tags$ul(
          tags$li("Support only for LFQ intensity values"),
          tags$li("V1 column is automatically created when upload the table"),
          tags$li("V1 column is splitted to exstract proteins ad genes information"),
          tags$li("if V1 column fail to identify, rename the rownames with 'V1'")
        )
      )
    })
    
  })
}

