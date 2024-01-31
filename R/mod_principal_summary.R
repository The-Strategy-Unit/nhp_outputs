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
      col_2(),
      bs4Dash::box(
        title = "Summary",
        collapsible = FALSE,
        width = 8,
        shinycssloaders::withSpinner(
          gt::gt_output(ns("summary_table"))
        )
      ),
      col_2()
    )
  )
}

mod_principal_summary_data <- function(r, sites) {
  pods <- mod_principal_high_level_pods()

  main_summary <- get_principal_high_level(
    r,
    c("admissions", "attendances", "walk-in", "ambulance"),
    sites
  ) |>
    dplyr::inner_join(pods, by = "pod")

  tele_attendances <- get_principal_high_level(r, "tele_attendances", sites) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::filter(.data$pod_name != "Outpatient Procedure") |>
    dplyr::mutate(
      "pod_name" = stringr::str_replace(.data$pod_name, "Attendance", "Tele-attendance")
    )

  bed_occupancy <- if (length(sites) == 0) {
    get_bed_occupancy(r) |>
      dplyr::filter(.data$model_run == 1) |>
      dplyr::group_by(.data$quarter) |>
      dplyr::summarise(dplyr::across(c("baseline", "principal"), sum)) |>
      dplyr::summarise(
        dplyr::across(c("baseline", "principal"), mean),
        pod_name = "Beds Available"
      )
  }

  dplyr::bind_rows(main_summary, tele_attendances, bed_occupancy) |>
    dplyr::mutate(
      dplyr::across(
        "activity_type",
        ~ forcats::fct_relevel(.x, "ip", "op", after = 0)
      )
    ) |>
    dplyr::mutate(
      change = .data$principal - .data$baseline,
      change_pcnt = (.data$principal - .data$baseline) / .data$baseline
    ) |>
    dplyr::arrange(.data$activity_type, .data$pod) |>
    dplyr::select("pod_name", "baseline", "principal", "change", "change_pcnt")
}

mod_principal_summary_table <- function(data) {
  data |>
    dplyr::mutate(
      dplyr::across("principal", \(.x) gt_bar(.x, scales::comma_format(1), "#686f73", "#686f73")),
      dplyr::across("change", \(.x) gt_bar(.x, scales::comma_format(1))),
      dplyr::across("change_pcnt", \(.x) gt_bar(.x, scales::percent_format(1)))
    ) |>
    gt::gt() |>
    gt::cols_align(align = "left", columns = "pod_name") |>
    gt::cols_label(
      "pod_name" = "Point of Delivery",
      "baseline" = "Baseline",
      "principal" = "Principal",
      "change" = "Change",
      "change_pcnt" = "Percent Change"
    ) |>
    gt::fmt_integer("baseline") |>
    gt::cols_width(.data$principal ~ px(150), .data$change ~ px(150), .data$change_pcnt ~ px(150)) |>
    gt::cols_align(
      align = "left",
      columns = c("baseline", "principal", "change", "change_pcnt")
    ) |>
    gt_theme()
}

#' principal_summary Server Functions
#'
#' @noRd
mod_principal_summary_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_data <- shiny::reactive({
      selected_data() |>
        mod_principal_summary_data(selected_site())
    })

    output$summary_table <- gt::render_gt({
      summary_data() |>
        mod_principal_summary_table()
    })
  })
}
