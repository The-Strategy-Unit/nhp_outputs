#' capacity_theatres UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_capacity_theatres_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::fluidRow(
      bs4Dash::box(
        title = "Theatres Available",
        width = 12,
        htmltools::tags$span(
          "Available (baseline): ",
          shiny::textOutput(ns("available_baseline"))
        ),
        htmltools::tags$span(
          "Available (principal): ",
          shiny::textOutput(ns("available_principal"))
        )
      ),
      bs4Dash::box(
        title = "Four Hour Sesssions",
        width = 12,
        collapsible = FALSE,
        bs4Dash::column(
          width = 9,
          shinycssloaders::withSpinner(
            plotly::plotlyOutput(ns("utilisation_plot"), height = "800px"),
          )
        ),
        bs4Dash::column(
          width = 3,
          shinycssloaders::withSpinner(
            gt::gt_output(ns("utilisation_table"))
          )
        )
      )
    )
  )
}

mod_capacity_theatres_get_utilisation_table <- function(data) {
  data |>
    dplyr::select(
      .data$tretspef,
      old_fhs = .data$baseline,
      new_fhs = .data$principal
    ) |>
    dplyr::arrange(dplyr::desc(.data$new_fhs), dplyr::desc(.data$old_fhs)) |>
    gt::gt(rowname_col = "tretspef") |>
    gt::fmt_integer(c("old_fhs", "new_fhs")) |>
    gt::summary_rows(
      columns = c("old_fhs", "new_fhs"),
      fns = list(total = "sum"),
      formatter = gt::fmt_integer
    ) |>
    gt::cols_label(
      old_fhs = "Baseline",
      new_fhs = "Principal"
    ) |>
    gt::tab_spanner("4 hour sessions", c("old_fhs", "new_fhs")) |>
    gt::tab_options(
      row_group.background.color = "#686f73",
      summary_row.background.color = "#b2b7b9"
    )
}

mod_capacity_theatres_get_utilisation_plot <- function(data) {
  data |>
    dplyr::mutate(dplyr::across(.data$tretspef, forcats::fct_reorder, .data$principal)) |>
    ggplot2::ggplot(ggplot2::aes(.data$principal, .data$tretspef)) +
    ggplot2::geom_col(fill = "#f9bf07") +
    ggplot2::geom_errorbar(ggplot2::aes(xmin = .data$baseline, xmax = .data$baseline), colour = "#2c2825")
}

#' capacity_theatres Server Functions
#'
#' @noRd
mod_capacity_theatres_server <- function(id, selected_model_run_id) {
  shiny::moduleServer(id, function(input, output, session) {
    theatres_data <- shiny::reactive({
      id <- selected_model_run_id() # nolint
      cosmos_get_theatres_available(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    four_hour_sessions <- shiny::reactive({
      theatres_data()$four_hour_sessions
    })

    theatres_available <- shiny::reactive({
      theatres_data()$theatres
    })

    output$available_baseline <- shiny::renderText(theatres_available()$baseline)
    output$available_principal <- shiny::renderText(theatres_available()$principal)

    output$utilisation_table <- gt::render_gt({
      mod_capacity_theatres_get_utilisation_table(four_hour_sessions())
    })

    output$utilisation_plot <- plotly::renderPlotly({
      four_hour_sessions() |>
        mod_capacity_theatres_get_utilisation_plot() |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })
  })
}
