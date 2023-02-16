#' principal_capacity_requirements UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_capacity_requirements_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: capacity requirements"),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Beds",
        width = 6,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("beds"))
        )
      ),
      bs4Dash::box(
        title = "Elective 4 Hour Sessions",
        width = 6,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("fhs"))
        )
      )
    )
  )
}

mod_principal_capacity_requirements_beds_table <- function(data) {
  data |>
    dplyr::select(
      "quarter",
      "ward_group",
      old_beds = "baseline",
      new_beds = "principal"
    ) |>
    dplyr::arrange(
      .data$quarter,
      dplyr::desc(.data$new_beds),
      dplyr::desc(.data$old_beds)
    ) |>
    dplyr::filter(.data$new_beds > 0.5) |>
    dplyr::group_by(.data$quarter) |>
    gt::gt(rowname_col = "ward_group") |>
    gt::fmt_integer(c("old_beds", "new_beds")) |>
    gt::summary_rows(
      groups = TRUE,
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

mod_principal_capacity_requirements_fhs_table <- function(data) {
  data |>
    gt::gt(rowname_col = "tretspef") |>
    gt::cols_label(
      baseline = "Baseline",
      principal = "Principal"
    ) |>
    gt::summary_rows(
      columns = c("baseline", "principal"),
      fns = list(total = "sum"),
      formatter = gt::fmt_integer
    ) |>
    gt_theme()
}

#' principal_capacity_requirements Server Functions
#'
#' @noRd
mod_principal_capacity_requirements_server <- function(id, selected_model_run_id) {
  shiny::moduleServer(id, function(input, output, session) {
    beds_data <- shiny::reactive({
      id <- selected_model_run_id()
      cosmos_get_bed_occupancy(id) |>
        dplyr::filter(.data$model_run == 1) |>
        dplyr::select("quarter", "ward_group", "baseline", "principal")
    }) |>
      shiny::bindCache(selected_model_run_id())

    theatres_data <- shiny::reactive({
      id <- selected_model_run_id()
      cosmos_get_theatres_available(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    four_hour_sessions <- shiny::reactive({
      theatres_data()$four_hour_sessions |>
        dplyr::select("tretspef", "baseline", "principal")
    })

    output$beds <- gt::render_gt({
      beds_data() |>
        mod_principal_capacity_requirements_beds_table()
    })

    output$fhs <- gt::render_gt({
      four_hour_sessions() |>
        mod_principal_capacity_requirements_fhs_table()
    })
  })
}
