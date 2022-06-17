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
    shiny::h1("Simulation Results"),
    shiny::fluidRow(
      mod_measure_selection_ui(ns("measure_selection"), 4),
    ),
    shiny::checkboxInput(ns("show_origin"), "Show Origin (zero)?"),
    shinycssloaders::withSpinner(
      plotly::plotlyOutput(ns("distribution"), height = "800px")
    )
  )
}

mod_model_results_distribution_get_data <- function(id, selected_measure) {
  activity_type <- pod <- measure <- NULL
  c(activity_type, pod, measure) %<-% selected_measure
  cosmos_get_model_run_distribution(id, pod, measure)
}

mod_model_results_distibution_density_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]

  data |>
    ggplot2::ggplot(ggplot2::aes(.data$value)) +
    ggplot2::geom_density(fill = "#f9bf07", colour = "#2c2825", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = b) +
    ggplot2::expand_limits(x = ifelse(show_origin, 0, b)) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )
}

mod_model_results_distibution_beeswarm_plot <- function(data, show_origin) {
  b <- data$baseline[[1]]
  data |>
    ggplot2::ggplot(ggplot2::aes("1", .data$value, colour = .data$variant)) +
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
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )
}

mod_model_results_distibution_plot <- function(data, show_origin) {
  p1 <- plotly::ggplotly(mod_model_results_distibution_density_plot(data, show_origin))
  p2 <- plotly::ggplotly(mod_model_results_distibution_beeswarm_plot(data, show_origin))

  sp <- plotly::subplot(p1, p2, nrows = 2)

  plotly::layout(sp, legend = list(orientation = "h"))
}

#' model_results_distribution Server Functions
#'
#' @noRd
mod_model_results_distribution_server <- function(id, selected_model_run_id) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    selected_data <- shiny::reactive({
      mod_model_results_distribution_get_data(selected_model_run_id(), selected_measure())
    }) |>
      shiny::bindCache(selected_model_run_id(), selected_measure())

    output$distribution <- plotly::renderPlotly({
      data <- shiny::req(selected_data())
      shiny::req(nrow(data) > 0)
      shiny::req(is.logical(input$show_origin))

      mod_model_results_distibution_plot(data, input$show_origin)
    })
  })
}
