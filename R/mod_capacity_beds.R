#' capacity_beds UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_capacity_beds_ui <- function(id) {
  ns <- shiny::NS(id)
  tagList(
    shiny::fluidRow(
      bs4Dash::column(
        width = 9,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("available_plot"), height = "800px"),
        )
      ),
      bs4Dash::column(
        width = 3,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("available_table"))
        )
      )
    )
  )
}

mod_capacity_beds_get_available_table <- function(data) {
  data |>
    dplyr::select(
      .data$ward_group,
      old_beds = .data$baseline,
      new_beds = .data$principal
    ) |>
    dplyr::arrange(dplyr::desc(.data$new_beds), dplyr::desc(.data$old_beds)) |>
    dplyr::filter(.data$new_beds > 0.5) |>
    gt::gt(rowname_col = "ward_group") |>
    gt::fmt_integer(c("old_beds", "new_beds")) |>
    gt::summary_rows(
      columns = c("old_beds", "new_beds"),
      fns = list(total = "sum"),
      formatter = gt::fmt_integer
    ) |>
    gt::cols_label(
      old_beds = "Baseline",
      new_beds = "Principal"
    ) |>
    gt::tab_spanner("Number of Beds", c("old_beds", "new_beds")) |>
    gt::tab_options(
      row_group.background.color = "#686f73",
      summary_row.background.color = "#b2b7b9"
    )
}

mod_capacity_beds_get_available_density_plot <- function(data, baseline) {
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

mod_capacity_beds_get_available_beeswarm_plot <- function(data, baseline) {
  data |>
    ggplot2::ggplot(ggplot2::aes("1", .data$n, colour = .data$variant)) +
    ggbeeswarm::geom_quasirandom(groupOnX = TRUE, alpha = 0.5) +
    ggplot2::geom_hline(yintercept = baseline) +
    # have to use coord flip with boxplots/violin plots and plotly...
    ggplot2::coord_flip() +
    ggplot2::scale_y_continuous(labels = scales::comma) +
    ggplot2::theme(
      axis.text = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )
}

mod_capacity_beds_get_available_plot <- function(data) {
  b <- data |>
    dplyr::filter(.data$model_run == 1) |>
    dplyr::pull(.data$baseline) |>
    sum()

  d <- data |>
    dplyr::count(.data$model_run, .data$variant, wt = .data$value)

  p1 <- mod_capacity_beds_get_available_density_plot(d, b)
  p2 <- mod_capacity_beds_get_available_beeswarm_plot(d, b)

  p1p <- plotly::ggplotly(p1)
  p2p <- plotly::ggplotly(p2)

  sp <- plotly::subplot(p1p, p2p, nrows = 2)

  plotly::layout(sp, legend = list(orientation = "h"))
}

#' capacity_beds Server Functions
#'
#' @noRd
mod_capacity_beds_server <- function(id, selected_model_run_id) {
  shiny::moduleServer(id, function(input, output, session) {
    beds_data <- shiny::reactive({
      id <- selected_model_run_id() # nolint
      cosmos_get_bed_occupancy(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    output$available_table <- gt::render_gt({
      beds_data() |>
        dplyr::filter(.data$model_run == 1) |>
        mod_capacity_beds_get_available_table()
    })

    output$available_plot <- plotly::renderPlotly({
      beds_data() |>
        mod_capacity_beds_get_available_plot()
    })
  })
}
