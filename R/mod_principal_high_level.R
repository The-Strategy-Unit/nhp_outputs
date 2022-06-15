#' principal_high_level UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_high_level_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("High level activity estimates (principal projection)"),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Activity Estimates",
        shinycssloaders::withSpinner(
          gt::gt_output(ns("activity"))
        ),
        width = 12
      )
    ),
    shiny::fluidRow(
      bs4Dash::box(
        title = "A&E Attendances",
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("aae"))
        ),
        width = 4
      ),
      bs4Dash::box(
        title = "Inpatient Admissions",
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("ip"))
        ),
        width = 4
      ),
      bs4Dash::box(
        title = "Outpatient Attendances",
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("op"))
        ),
        width = 4
      )
    )
  )
}

mod_principal_high_level_pods <- function() {
  get_activity_type_pod_measure_options() |>
    dplyr::filter(.data$activity_type != "aae") |>
    distinct(.data$activity_type, .data$pod, .data$pod_name) |>
    dplyr::bind_rows(data.frame(activity_type = "aae", pod = "aae", pod_name = "A&E Attendance")) |>
    dplyr::mutate(dplyr::across(.data$pod_name, forcats::fct_inorder))
}

mod_principal_high_level_summary_data <- function(id, pods) {
  c(start_year, end_year) %<-% cosmos_get_model_run_years(id)

  cosmos_get_principal_highlevel(id) |>
    tidyr::pivot_longer(-.data$pod, names_to = "model_run") |>
    dplyr::mutate(year = ifelse(.data$model_run == "baseline", start_year, end_year)) |>
    dplyr::select(-.data$model_run) |>
    tidyr::complete(
      year = seq(start_year, end_year),
      .data$pod
    ) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::select(-.data$pod) |>
    dplyr::group_by(.data$activity_type, .data$pod_name) |>
    dplyr::mutate(
      dplyr::across(.data$value, purrr::compose(as.integer, zoo::na.approx)),
      fyear = fyear_str(.data$year)
    ) |>
    dplyr::ungroup()
}

mod_principal_high_level_table <- function(data) {
  data |>
    dplyr::select(-.data$activity_type, -.data$year) |>
    tidyr::pivot_wider(names_from = .data$fyear, values_from = .data$value) |>
    gt::gt() |>
    gt::cols_align(
      align = "left",
      columns = "pod_name"
    ) |>
    gt::cols_label(
      "pod_name" = ""
    ) |>
    gt::fmt_integer(tidyselect::matches("\\d{4}/\\d{2}")) |>
    gt_theme()
}

mod_principal_high_level_plot <- function(data, activity_type) {
  c(start_year, end_year) %<-% range(data$year)

  data |>
    dplyr::filter(.data$activity_type == .env$activity_type) |>
    ggplot2::ggplot(aes(.data$year, .data$value, colour = .data$pod_name)) +
    ggplot2::geom_line() +
    ggplot2::geom_point() +
    ggplot2::scale_x_continuous(
      labels = fyear_str,
      breaks = seq(start_year, end_year, 2)
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::comma
    ) +
    ggplot2::expand_limits(y = 0) +
    ggplot2::labs(x = NULL, y = NULL, colour = NULL)
}

#' principal_high_level Server Functions
#'
#' @noRd
mod_principal_high_level_server <- function(id, selected_model_run_id) {
  shiny::moduleServer(id, function(input, output, session) {
    pods <- mod_principal_high_level_pods()

    summary_data <- reactive({
      id <- selected_model_run_id()
      mod_principal_high_level_summary_data(id, pods)
    }) |>
      shiny::bindCache(selected_model_run_id(), cache = get_data_cache())

    output$activity <- gt::render_gt({
      summary_data() |>
        mod_principal_high_level_table()
    })

    output$aae <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("aae") |>
        plotly::ggplotly() %>%
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })

    output$ip <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("ip") |>
        plotly::ggplotly() %>%
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })

    output$op <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("op") |>
        plotly::ggplotly() %>%
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })
  })
}
