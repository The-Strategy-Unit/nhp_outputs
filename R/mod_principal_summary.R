#' principal_summary UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_summary_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::fluidRow(
      col_3(),
      bs4Dash::box(
        title = "Summary",
        collapsible = FALSE,
        width = 6,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("summary_table"))
        )
      ),
      col_3()
    )
  )
}

mod_principal_summary_data <- function(r) {
  pods <- mod_principal_high_level_pods()

  get_principal_high_level(r) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::bind_rows(
      get_bed_occupancy(r) |>
        dplyr::filter(.data$model_run == 1) |>
        dplyr::group_by(.data$quarter) |>
        dplyr::summarise(
          dplyr::across(c("baseline", "principal"), sum)
        ) |>
        dplyr::summarise(
          dplyr::across(c("baseline", "principal"), mean),
          sitetret = "trust",
          pod_name = "Beds Available"
        ),
      get_theatres_available(r) |>
        dplyr::summarise(
          sitetret = "trust",
          pod_name = "4 Hour Elective Theatre Sessions",
          dplyr::across(c("baseline", "principal"), sum)
        )
    ) |>
    dplyr::select("sitetret", "pod_name", "baseline", "principal")
}

mod_principal_summary_table <- function(data) {
  gt::gt(data) |>
    gt::cols_align(
      align = "left",
      columns = "pod_name"
    ) |>
    gt::cols_label(
      "pod_name" = ""
    ) |>
    gt::fmt_integer(c("baseline", "principal")) |>
    gt_theme()
}

#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_data <- shiny::reactive({
      id <- selected_data()
      mod_principal_summary_data(id)
    })

    site_data <- shiny::reactive({
      summary_data() |>
        dplyr::filter(.data$sitetret == selected_site()) |>
        dplyr::select(-"sitetret")
    })

    output$summary_table <- gt::render_gt({
      site_data() |>
        mod_principal_summary_table()
    })
  })
}
