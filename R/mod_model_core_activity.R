#' model_core_activity UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_model_core_activity_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Distribution of projections: activity distribution summary"),
    shiny::fluidRow(
      col_3(),
      bs4Dash::box(
        title = "Summary",
        collapsible = FALSE,
        width = 6,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("core_activity"))
        )
      ),
      col_3()
    )
  )
}

mod_model_core_activity_server_table <- function(data) {
  data |>
    dplyr::select(
      "activity_type_name",
      "pod_name",
      "measure",
      "baseline",
      "median",
      "lwr_ci",
      "upr_ci"
    ) |>
    gt::gt(groupname_col = c("activity_type_name", "pod_name")) |>
    gt::fmt_integer(c("baseline", "median", "lwr_ci", "upr_ci")) |>
    gt::cols_label(
      "measure" = "Measure",
      "baseline" = "Baseline",
      "median" = "Central Projection",
      "lwr_ci" = "Lower",
      "upr_ci" = "Upper"
    ) |>
    gt::tab_spanner(
      "90% Confidence Interval",
      c("lwr_ci", "upr_ci")
    ) |>
    gt_theme()
}

#' model_core_activity Server Functions
#'
#' @noRd
mod_model_core_activity_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    atpmo <- get_activity_type_pod_measure_options()

    summarised_data <- shiny::reactive({
      selected_data() |>
        get_model_core_activity(selected_site()) |>
        dplyr::inner_join(atpmo, by = c("pod", "measure" = "measures")) |>
        dplyr::mutate(
          change = .data$principal - .data$baseline,
          change_pcnt = (.data$principal - .data$baseline) / .data$baseline
        )
    })

    output$core_activity <- gt::render_gt({
      summarised_data() |>
        mod_model_core_activity_server_table()
    })
  })
}
