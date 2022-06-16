#' model_results_distribution UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_model_results_distribution_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h1("Simulation Results"),
    fluidRow(
      mod_measure_selection_ui(ns("measure_selection"), 4),
    ),
    shiny::checkboxInput(ns("show_origin"), "Show Origin (zero)?"),
    shinycssloaders::withSpinner(
      plotly::plotlyOutput(ns("distribution"), height = "800px")
    )
  )
}

mod_model_results_distribution_get_data <- function(id, selected_measure) {
  c(activity_type, pod, measure) %<-% selected_measure
  cosmos_get_model_run_distribution(id, pod, measure)
}

mod_model_results_distibution_density_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]

  data |>
    ggplot2::ggplot(aes(.data$value)) +
    ggplot2::geom_density(fill = "#f9bf07", colour = "#2c2825", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = b) +
    ggplot2::expand_limits(x = ifelse(show_origin, 0, b)) +
    ggplot2::theme(
      axis.text = element_blank(),
      axis.title = element_blank(),
      axis.ticks = element_blank()
    )
}

mod_model_results_distibution_beeswarm_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]
  data |>
    ggplot2::ggplot(aes("1", .data$value, colour = .data$variant)) +
    ggbeeswarm::geom_quasirandom(groupOnX = TRUE, alpha = 0.5) +
    ggplot2::geom_hline(yintercept = b) +
    ggplot2::expand_limits(y = ifelse(show_origin, 0, b)) +
    ggplot2::scale_fill_manual(values = c(
      "principal" = "#f9bf07",
      "high_migration" = "#5881c1"
    )) +
    # have to use coord flip with boxplots/violin plots and plotly...
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme(
      axis.text.y = element_blank(),
      axis.title.y = element_blank(),
      axis.ticks.y = element_blank()
    )
}

mod_model_results_distibution_plot <- function(data, show_origin) {
  req(data)
  req(nrow(data) > 0)
  req(is.logical(show_origin))

  p1 <- plotly::ggplotly(mod_model_results_distibution_density_plot(data, show_origin))
  p2 <- plotly::ggplotly(mod_model_results_distibution_beeswarm_plot(data, show_origin))

  sp <- plotly::subplot(p1, p2, nrows = 2)

  plotly::layout(sp, legend = list(orientation = "h"))
}

#' model_results_distribution Server Functions
#'
#' @noRd
mod_model_results_distribution_server <- function(id, selected_model_run_id) {
  moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    selected_data <- reactive({
      mod_model_results_distribution_get_data(selected_model_run_id(), selected_measure())
    }) |>
      shiny::bindCache(selected_model_run_id(), selected_measure(), cache = get_data_cache())

    output$distribution <- plotly::renderPlotly({
      mod_model_results_distibution_plot(selected_data(), input$show_origin)
    })
  })
}
