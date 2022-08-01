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
          dplyr::across(c(.data$baseline, .data$principal), sum)
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
          dplyr::across(c(.data$baseline, .data$principal), sum)
        )
    ) |>
    dplyr::select(.data$pod_name, .data$baseline, .data$principal)
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
    gt::fmt_integer(c(.data$baseline, .data$principal)) |>
    gt_theme()
}
    
#' principal_summary Server Functions
#'
#' @noRd 
mod_principal_summary_server <- function(id, selected_model_run_id) {
  moduleServer(id, function(input, output, session) {
    summary_data <- shiny::reactive({
      id <- selected_model_run_id()
      mod_principal_summary_data(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    output$summary_table <- gt::render_gt({
      summary_data() |>
        mod_principal_summary_table()
    })
  })
}
    
## To be copied in the UI
# 
    
## To be copied in the server
# mod_principal_summary_server("principal_summary_1")
