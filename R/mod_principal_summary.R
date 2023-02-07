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
    gt::gt_output(ns("summary_table"))
  )
}

mod_principal_summary_data <- function(id) {
  t <- cosmos_get_theatres_available(id)

  pods <- mod_principal_high_level_pods()
  cosmos_get_principal_high_level(id) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::bind_rows(
      cosmos_get_bed_occupancy(id) |>
        dplyr::filter(.data$model_run == 1) |>
        dplyr::summarise(
          pod_name = "Beds Available",
          dplyr::across(c("baseline", "principal"), sum)
        ),
      t$theatres |>
        dplyr::transmute(
          pod_name = "Theatres Available",
          .data$baseline,
          .data$principal
        ),
      t$four_hour_sessions |>
        dplyr::summarise(
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
mod_principal_summary_server <- function(id, selected_model_run_id, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_data <- shiny::reactive({
      id <- selected_model_run_id()
      mod_principal_summary_data(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

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
