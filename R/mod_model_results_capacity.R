#' capacity_beds UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_model_results_capacity_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Distribution of projections: capacity requirements distribution"),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Beds",
        width = 12,
        shiny::selectInput(
          ns("beds_quarter"),
          "Quarter",
          purrr::set_names(c("q1", "q2", "q3", "q4"), stringr::str_to_upper)
        ),
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("beds"), height = "800px"),
        )
      ),
      bs4Dash::box(
        title = "Elective 4 hour sessions",
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("fhs"), height = "800px"),
        )
      )
    )
  )
}

mod_model_results_capacity_beds_density_plot <- function(data, baseline) {
  data |>
    ggplot2::ggplot(ggplot2::aes(.data$n)) +
    ggplot2::geom_density(fill = "#f9bf07", colour = "#2c2825", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = baseline) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )
}

mod_model_results_capacity_beds_beeswarm_plot <- function(data, baseline) {
  data |>
    ggplot2::ggplot(ggplot2::aes("1", .data$n, colour = .data$variant)) +
    ggbeeswarm::geom_quasirandom(alpha = 0.5) +
    ggplot2::geom_hline(yintercept = baseline) +
    # have to use coord flip with boxplots/violin plots and plotly...
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::labs(x = "", y = "Number of beds available") +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    )
}

mod_model_results_capacity_beds_available_plot <- function(data) {
  b <- data |>
    dplyr::filter(.data$model_run == 1) |>
    dplyr::pull(.data$baseline) |>
    sum()

  d <- data |>
    dplyr::count(.data$model_run, .data$variant, wt = .data$value)

  p1 <- mod_model_results_capacity_beds_density_plot(d, b)
  p2 <- mod_model_results_capacity_beds_beeswarm_plot(d, b)

  p1p <- plotly::ggplotly(p1)
  p2p <- plotly::ggplotly(p2)

  sp <- plotly::subplot(p1p, p2p, nrows = 2)

  plotly::layout(sp, legend = list(orientation = "h"))
}

mod_model_results_capacity_fhs_available_plot <- function(data) {
  data |>
    dplyr::group_by(.data$model_run, .data$variant) |>
    dplyr::summarise(dplyr::across(c("baseline", "value"), sum), .groups = "drop") |>
    ggplot2::ggplot(ggplot2::aes("1", .data$value, colour = .data$variant)) +
    ggbeeswarm::geom_quasirandom(alpha = 0.5) +
    ggplot2::geom_hline(ggplot2::aes(yintercept = .data$baseline), colour = "#2c2825") +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank()
    ) +
    ggplot2::labs(x = "", y = "Elective 4 hour sessions") +
    ggplot2::coord_flip()
}


#' capacity_beds Server Functions
#'
#' @noRd
mod_model_results_capacity_server <- function(id, selected_model_run_id) {
  shiny::moduleServer(id, function(input, output, session) {
    beds_data <- shiny::reactive({
      id <- selected_model_run_id()
      cosmos_get_bed_occupancy(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    variants <- shiny::reactive({
      id <- selected_model_run_id()
      cosmos_get_variants(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    theatres_data <- shiny::reactive({
      id <- selected_model_run_id() # nolint
      cosmos_get_theatres_available(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    four_hour_sessions <- shiny::reactive({
      theatres_data()$four_hour_sessions |>
        dplyr::mutate(dplyr::across("model_runs", purrr::map, tibble::enframe, "model_run")) |>
        tidyr::unnest("model_runs") |>
        dplyr::inner_join(variants(), by = "model_run")
    })

    output$beds <- plotly::renderPlotly({
      beds_data() |>
        dplyr::filter(.data$quarter == input$beds_quarter) |>
        mod_model_results_capacity_beds_available_plot()
    })

    output$fhs <- plotly::renderPlotly({
      four_hour_sessions() |>
        mod_model_results_capacity_fhs_available_plot() |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(orientation = "h"))
    })
  })
}
