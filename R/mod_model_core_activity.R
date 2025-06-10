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
        md_file_to_html("app", "text", "notes-beddays.md")
      ),
      bs4Dash::box(
        title = "Summary by activity type and measure",
        collapsible = FALSE,
        width = 12,
        bs4Dash::tabsetPanel(
          shiny::tabPanel(
            "Median",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("core_activity_median"))
            )
          ),
          shiny::tabPanel(
            "Principal",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("core_activity_principal"))
            )
          )
        )
      ),
      col_3()
    )
  )
}

mod_model_core_activity_server_table <- function(
  data,
  value_type = c("median", "principal")
) {
  value_type <- match.arg(value_type)
  data_prep <- data |>
    dplyr::mutate(
      change = .data[[value_type]] - .data$baseline,
      change_pcnt = .data$change / .data$baseline,
      measure = .data$measure |>
        stringr::str_to_sentence() |>
        stringr::str_replace("_", "-") |> # tele_attendances
        stringr::str_replace("Beddays", "Bed days"),
      activity_type_name = factor(
        .data$activity_type_name,
        levels = c("Inpatients", "Outpatients", "A&E")
      )
    ) |>
    dplyr::arrange(.data$activity_type_name, .data$pod_name) |>
    dplyr::select(
      "activity_type_name",
      "pod_name",
      "measure",
      "baseline",
      .env$value_type,
      "change",
      "change_pcnt",
      "lwr_pi",
      "upr_pi"
    )

  data_prep |>
    gt::gt(groupname_col = c("activity_type_name", "pod_name")) |>
    gt::fmt_integer(c(
      "baseline",
      .env$value_type,
      "change",
      "lwr_pi",
      "upr_pi"
    )) |>
    gt::fmt_percent("change_pcnt", decimals = 0) |>
    gt::cols_align(align = "left", columns = "measure") |>
    gt::cols_label_with(fn = stringr::str_to_title) |>
    gt::cols_label(
      "change_pcnt" = gt::html("Percent<br>Change"),
      "lwr_pi" = "Lower",
      "upr_pi" = "Upper"
    ) |>
    gt::tab_spanner(
      "80% prediction interval",
      c("lwr_pi", "upr_pi")
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

    output$core_activity_median <- gt::render_gt({
      summarised_data() |>
        mod_model_core_activity_server_table(value_type = "median")
    })

    output$core_activity_principal <- gt::render_gt({
      summarised_data() |>
        mod_model_core_activity_server_table(value_type = "principal")
    })
  })
}
