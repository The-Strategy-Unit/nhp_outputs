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
        width = 8,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("beds"))
        )
      ),
      bs4Dash::box(
        title = "Elective 4 Hour Sessions",
        width = 4,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("fhs"))
        )
      )
    )
  )
}

mod_principal_capacity_requirements_beds_table <- function(data) {
  data |>
    dplyr::arrange(
      .data$quarter,
      dplyr::desc(.data$principal),
      dplyr::desc(.data$baseline)
    ) |>
    dplyr::filter(.data$principal > 0.5) |>
    tidyr::pivot_wider(names_from = "quarter", values_from = c("baseline", "principal")) |>
    gt::gt(rowname_col = "ward_group") |>
    gt::fmt_integer(-"ward_group") |>
    gt::summary_rows(
      groups = NULL,
      fns = list(Total = "sum"),
      formatter = gt::fmt_integer
    ) |>
    gt::tab_spanner("Q1 (Apr-Jun)", tidyselect::ends_with("Q1")) |>
    gt::tab_spanner("Q2 (Jul-Sep)", tidyselect::ends_with("Q2")) |>
    gt::tab_spanner("Q3 (Oct-Dec)", tidyselect::ends_with("Q3")) |>
    gt::tab_spanner("Q4 (Jan-Mar)", tidyselect::ends_with("Q4")) |>
    gt::cols_label(
      baseline_q1 = "Baseline",
      principal_q1 = "Principal",
      baseline_q2 = "Baseline",
      principal_q2 = "Principal",
      baseline_q3 = "Baseline",
      principal_q3 = "Principal",
      baseline_q4 = "Baseline",
      principal_q4 = "Principal"
    ) |>
    gt::tab_style(
      style = gt::cell_borders(
        sides = "right",
        color = "#d3d3d3"
      ),
      locations = gt::cells_body(
        columns = tidyselect::matches("principal_q[1-3]")
      )
    ) |>
    gt::tab_options(
      grand_summary_row.background.color = "#686f73"
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
