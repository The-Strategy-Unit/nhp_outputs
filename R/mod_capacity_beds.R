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

mod_capacity_beds_get_available_plot <- function(data) {
  data |>
    dplyr::mutate(dplyr::across(.data$ward_group, forcats::fct_reorder, .data$principal)) |>
    dplyr::filter(.data$principal > 5) |>
    ggplot2::ggplot(ggplot2::aes(.data$principal, .data$ward_group)) +
    ggplot2::geom_col(fill = "#f9bf07") +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = .data$baseline, xmax = .data$baseline), colour = "#2c2825")
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
      mod_capacity_beds_get_available_table(beds_data())
    })

    output$available_plot <- plotly::renderPlotly({
      beds_data() |>
        mod_capacity_beds_get_available_plot() |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })
  })
}
