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
        title = "Notes",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "Bed days are defined as the difference in days between discharge and admission, plus one day.",
          "See the",
          htmltools::a(
            href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information",
            "model project information site"
          ),
          "for definitions of terms."
        )
      ),
      bs4Dash::box(
        title = "Summary by activity type and measure",
        collapsible = FALSE,
        width = 12,
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
    dplyr::mutate(
      change = .data$median - .data$baseline,
      change_pcnt = .data$change / .data$baseline,
      measure = .data$measure |>
        stringr::str_to_sentence() |>
        stringr::str_replace("_", "-") |>  # tele_attendances
        stringr::str_replace("Beddays", "Bed days"),
      activity_type_name = forcats::fct_relevel(
        .data$activity_type_name,
        "Inpatients",
        "Outpatients",
        "A&E"
      )
    ) |>
    dplyr::arrange(.data$activity_type_name, .data$pod_name)|>
    dplyr::select(
      "activity_type_name",
      "pod_name",
      "measure",
      "baseline",
      "median",
      "change",
      "change_pcnt",
      "lwr_ci",
      "upr_ci"
    ) |>
    gt::gt(groupname_col = c("activity_type_name", "pod_name")) |>
    gt::fmt_integer(c("baseline", "median", "change", "lwr_ci", "upr_ci")) |>
    gt::fmt_percent("change_pcnt", decimals = 0) |>
    gt::cols_align(align = "left", columns = "measure") |>
    gt::cols_label(
      "measure" = "Measure",
      "baseline" = "Baseline",
      "median" = "Median",
      "change" = "Change",
      "change_pcnt" = gt::html("Percent<br>Change"),
      "lwr_ci" = "Lower",
      "upr_ci" = "Upper"
    ) |>
    gt::tab_spanner(
      "80% Confidence Interval",
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
        dplyr::inner_join(atpmo, by = c("pod", "measure" = "measures"))
    })

    output$core_activity <- gt::render_gt({
      summarised_data() |>
        mod_model_core_activity_server_table()
    })
  })
}
