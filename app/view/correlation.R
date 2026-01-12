box::use(
  shiny[moduleServer, NS, selectInput, br, actionButton, observeEvent, updateSelectInput, observe, isolate, icon, reactive],
  bslib[page_sidebar, layout_columns, input_task_button, navset_card_underline, nav_panel, sidebar, accordion, accordion_panel, tooltip, input_switch],
  echarts4r[echarts4rOutput, renderEcharts4r],
  trelliscope[trelliscopeOutput, renderTrelliscope],
  gargoyle[watch, trigger],
  reactable[reactableOutput, renderReactable, getReactableState],
  dplyr[`%>%`, pull]
)

#' @export
ui <- function(id) {
  ns <- NS(id)
  page_sidebar(
    layout_columns(
      navset_card_underline(
        full_screen = TRUE, 
        nav_panel(
          "Heatmap",
          echarts4rOutput(ns("correlation_plot"))
        ),
        nav_panel(
          title = tooltip(
            trigger = list(
              "Scatter Plots",
              icon("info-circle")
            ),
            "Select proteins in the table to see their position in all scatter plots."
          ),
          value = "Scatter plots",
          trelliscopeOutput(ns("scatter_plot"), style = "height: 100%")
        ),
        nav_panel(
          "Table",
          reactableOutput(ns("table"))
        )
      )
    ),
    sidebar = sidebar(
      input_task_button(
        id = ns("update"),
        label = "PROCESS",
        class = "bg-primary"
      ),
      accordion(
        id = ns("accordion"),
        multiple = FALSE,
        accordion_panel(
          title = "Inputs",
          id = ns("subset"),
          selectInput(
            inputId = ns("correlation_input"),
            label = "Correlation method",
            choices = c("Pearson" = "pearson", "Kendall" = "kendall", "Spearman" = "spearman"),
            selected = "pearson"
          ),
          selectInput(
            inputId = ns("x_filter"),
            label = "Scatter plot X",
            choices = NULL,
            selected = NULL,
            multiple = TRUE
          ),
          selectInput(
            inputId = ns("y_filter"),
            label = "Scatter plot Y",
            choices = NULL,
            selected = NULL,
            multiple = TRUE
          )
        )
      )
    )
  )
}

#' @export
server <- function(id, r6) {
  moduleServer(id, function(input, output, session) {
    
    observe({
      watch("session")
      updateSelectInput(inputId = "correlation_input", selected = r6$cor_method)
    })
    
    observe({
      watch("genes")
      if(!is.null(r6$expdesign)) {
        if(nrow(r6$expdesign) > 1) {
          updateSelectInput(inputId = "x_filter", choices = r6$expdesign$label, selected = r6$expdesign$label[[1]])
          updateSelectInput(inputId = "y_filter", choices = r6$expdesign$label, selected = r6$expdesign$label[[2]])
        } else {
          updateSelectInput(inputId = "x_filter", choices = NULL, selected = NULL)
          updateSelectInput(inputId = "y_filter", choices = NULL, selected = NULL)
        }
      }
    })
    
    observeEvent(input$update, {
      r6$cor_method <- input$correlation_input
      trigger("plot")
    })
    
    output$correlation_plot <- renderEcharts4r({
      watch("plot")
      r6$plot_correlation() 
    })
    
    gene_selected <- reactive(getReactableState("table", "selected"))
    
    output$table <- renderReactable({
      watch("plot")
      if(!is.null(r6$imputed_data)) {
        if(r6$imp_methods == "none"){
          data <- r6$print_table(r6$normalized_data, df = TRUE)
          r6$reactable_interactive(data)
        }else{
          data <- r6$print_table(r6$imputed_data, df = TRUE)
          r6$reactable_interactive(data)
        }
      }
    })
    
    output$scatter_plot <- renderTrelliscope({
      watch("plot")
      highlights <- NULL
      if(r6$imp_methods == "none"){
        data <- r6$print_table(r6$normalized_data, df = TRUE)
        if(!is.null(gene_selected())){
          highlights <- data[gene_selected(), ] %>% pull(gene_names)
        }
      }else{
        data <- r6$print_table(r6$imputed_data, df = TRUE)
        if(!is.null(gene_selected())){
          highlights <- data[gene_selected(), ] %>% pull(gene_names)
        }
      }
      x <- isolate(input$x_filter)
      y <- isolate(input$y_filter)
      
      if (length(x) > 0 && length(y) > 0 && !identical(x, y)) {
        if ((length(x) == 1 && length(y) == 1 && x != y) || length(x) > 1 || length(y) > 1) {
          r6$plot_multi_scatter(highlights, x_filter = x, y_filter = y)
        }
      }
    })
  })
}
