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
        plotly::plotlyOutput(ns("available_plot"))
      ),
      bs4Dash::box(
        title = "Elective Four Hour Sesssions",
        width = 12,
        collapsible = FALSE,
        shiny::fluidRow(
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

mod_capacity_theatres_get_available_plot <- function(data) {
  b <- data |>
    dplyr::filter(.data$model_run == 1) |>
    dplyr::pull(.data$baseline)

  data |>
    ggplot2::ggplot(ggplot2::aes(.data$value)) +
    ggplot2::geom_bar(fill = "#f9bf07", colour = "#2c2825", alpha = 0.5) +
    ggplot2::geom_vline(xintercept = b) +
    ggplot2::theme(
      axis.title = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank()
    )
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
      id <- selected_model_run_id() # nolint
      variants <- cosmos_get_variants(id)

      theatres_data()$theatres |>
        dplyr::select(-.data$tretspef) |>
        dplyr::mutate(dplyr::across(.data$model_runs, purrr::map, tibble::enframe, "model_run")) |>
        tidyr::unnest(.data$model_runs) |>
        dplyr::inner_join(variants, by = "model_run")
    })

    output$utilisation_table <- gt::render_gt({
      mod_capacity_theatres_get_utilisation_table(four_hour_sessions())
    })

    output$utilisation_plot <- plotly::renderPlotly({
      four_hour_sessions() |>
        mod_capacity_theatres_get_utilisation_plot() |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(orientation = "h"))
    })

    output$available_plot <- plotly::renderPlotly({
      theatres_available() |>
        mod_capacity_theatres_get_available_plot() |>
        plotly::ggplotly() |>
        plotly::layout(legend = list(orientation = "h"))
    })
  })
}
