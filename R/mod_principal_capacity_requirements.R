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
        width = 12,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("beds"))
        )
      )
    )
  )
}

mod_principal_capacity_requirements_beds_table <- function(data) {
  data |>
    dplyr::mutate(
      change = .data$principal - .data$baseline,
      change_pcnt = .data$change / .data$baseline
    ) |>
    dplyr::arrange(
      .data[["quarter"]],
      dplyr::desc(.data[["principal"]]),
      dplyr::desc(.data[["baseline"]])
    ) |>
    dplyr::filter(.data[["principal"]] > 0.5) |>
    tidyr::pivot_wider(
      names_from = "quarter",
      values_from = c("baseline", "principal", "change", "change_pcnt")
    ) |>
    gt::gt(rowname_col = "ward_group", groupname_col = "ward_type") |>
    gt::fmt_integer(-c("ward_group", tidyselect::starts_with("change_pcnt"))) |>
    gt::fmt_percent(tidyselect::starts_with("change_pcnt"), decimals = 0) |>
    gt::summary_rows(
      fns = list(id = "sum", label = "Total") ~ sum(., na.rm = TRUE),
      fmt = ~ gt::fmt_integer(.)
    ) |>
    gt::grand_summary_rows(
      fns = list(id = "sum", label = "Grand Total") ~ sum(., na.rm = TRUE),
      fmt = ~ gt::fmt_integer(.)
    ) |>
    gt::sub_missing() |>
    gt::tab_spanner("Q1 (Apr-Jun)", tidyselect::ends_with("Q1")) |>
    gt::tab_spanner("Q2 (Jul-Sep)", tidyselect::ends_with("Q2")) |>
    gt::tab_spanner("Q3 (Oct-Dec)", tidyselect::ends_with("Q3")) |>
    gt::tab_spanner("Q4 (Jan-Mar)", tidyselect::ends_with("Q4")) |>
    gt::cols_label(
      baseline_q1 = "Baseline",
      principal_q1 = "Principal",
      change_q1 = "Change",
      change_pcnt_q1 = "Percent Change",
      baseline_q2 = "Baseline",
      principal_q2 = "Principal",
      change_q2 = "Change",
      change_pcnt_q2 = "Percent Change",
      baseline_q3 = "Baseline",
      principal_q3 = "Principal",
      change_q3 = "Change",
      change_pcnt_q3 = "Percent Change",
      baseline_q4 = "Baseline",
      principal_q4 = "Principal",
      change_q4 = "Change",
      change_pcnt_q4 = "Percent Change"
    ) |>
    gt::tab_style(
      style = gt::cell_borders(
        sides = "right",
        color = "#d3d3d3"
      ),
      locations = gt::cells_body(
        columns = tidyselect::matches("change_pcnt_q[1-3]")
      )
    ) |>
    gt_theme()
}

#' principal_capacity_requirements Server Functions
#'
#' @noRd
mod_principal_capacity_requirements_server <- function(id, selected_data) {
  shiny::moduleServer(id, function(input, output, session) {
    beds_data <- shiny::reactive({
      selected_data() |>
        get_bed_occupancy() |>
        dplyr::filter(.data$model_run == 1) |>
        dplyr::select("quarter", "ward_type", "ward_group", "baseline", "principal")
    })

    output$beds <- gt::render_gt({
      beds_data() |>
        mod_principal_capacity_requirements_beds_table()
    })
  })
}
