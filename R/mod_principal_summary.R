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

  main_summary <- get_principal_high_level(
    r,
    c("admissions", "attendances", "walk-in", "ambulance")
  ) |>
    dplyr::inner_join(pods, by = "pod")

  tele_attendances <- get_principal_high_level(r, "tele_attendances") |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::filter(pod_name != "Outpatient Procedure") |>
    dplyr:: mutate(
      pod_name = stringr::str_replace(pod_name, "Attendance", "Tele-attendance")
    )

  bed_occupancy <- get_bed_occupancy(r) |>
    dplyr::filter(.data$model_run == 1) |>
    dplyr::group_by(.data$quarter) |>
    dplyr::summarise(dplyr::across(c("baseline", "principal"), sum)) |>
    dplyr::summarise(
      dplyr::across(c("baseline", "principal"), mean),
      sitetret = "trust",
      pod_name = "Beds Available"
    )

  dplyr::bind_rows(main_summary, tele_attendances, bed_occupancy) |>
    dplyr::mutate(
      dplyr::across(
        "activity_type",
        ~forcats::fct_relevel(.x, "ip", "op", "aae"))
    ) |>
    dplyr::arrange(activity_type, pod) |>
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
      selected_data() |>
        mod_principal_summary_data()
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
