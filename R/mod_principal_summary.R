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
    shiny::h1("Principal projection: summary"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes-beddays.md"),
      htmltools::p("Bed-availability data is not available at site level.")
    ),
    bs4Dash::box(
      title = "Summary by point of delivery",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("summary_table"))
      )
    )
  )
}

mod_principal_summary_data <- function(r, sites) {
  pods <- mod_principal_los_pods() # uses same POD lookup as LoS summary

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
      "pod_name" = stringr::str_replace(
        .data$pod_name,
        "Attendance",
        "Tele-attendance"
      )
    )

  bed_days <- get_principal_high_level(r, "beddays", sites) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::mutate(
      "pod_name" = stringr::str_replace(.data$pod_name, "Admission", "Bed Days")
    )

  dplyr::bind_rows(
    main_summary,
    tele_attendances,
    bed_days
  ) |>
    dplyr::mutate(
      dplyr::across(
        "activity_type",
        ~ dplyr::case_match(
          .data$activity_type,
          "ip" ~ "Inpatient",
          "op" ~ "Outpatient",
          "aae" ~ "A&E"
        )
      ),
      dplyr::across(
        "activity_type",
        ~ factor(.x, levels = c("Inpatient", "Outpatient", "A&E"))
      ),
      measure = dplyr::case_when(
        stringr::str_detect(.data$pod_name, "Admission$") ~ "admission",
        stringr::str_detect(.data$pod_name, "Attendance$") ~ "attendance",
        stringr::str_detect(.data$pod_name, "Tele-attendance$") ~
          "tele_attendance",
        stringr::str_detect(.data$pod_name, "Procedure$") ~ "procedure",
        stringr::str_detect(.data$pod_name, "Bed Days$") ~ "bed_days"
      ),
      change = .data$principal - .data$baseline,
      change_pcnt = .data$change / .data$baseline
    ) |>
    dplyr::arrange(.data$activity_type, .data$measure, .data$pod_name) |>
    dplyr::select(
      "pod_name",
      "activity_type",
      "baseline",
      "principal",
      "change",
      "change_pcnt"
    )
}

mod_principal_summary_table <- function(data) {
  data |>
    dplyr::mutate(
      dplyr::across(
        "principal",
        \(.x) gt_bar(.x, scales::comma_format(1), "#686f73", "#686f73")
      ),
      dplyr::across("change", \(.x) gt_bar(.x, scales::comma_format(1))),
      dplyr::across("change_pcnt", \(.x) gt_bar(.x, scales::percent_format(1)))
    ) |>
    dplyr::mutate(
      "activity_type" = as.character(.data$activity_type),
      "activity_type" = dplyr::case_when(
        # include admissions/beddays in gt groupnames
        stringr::str_detect(.data$pod_name, "Admission") ~
          glue::glue("{.data$activity_type} Admissions"),
        stringr::str_detect(.data$pod_name, "Bed Days") ~
          glue::glue("{.data$activity_type} Bed Days"),
        .default = .data$activity_type
      )
    ) |>
    gt::gt(groupname_col = "activity_type") |>
    gt::cols_align(align = "left", columns = "pod_name") |>
    gt::cols_label(
      "pod_name" = "Point of Delivery",
      "baseline" = "Baseline",
      "principal" = "Principal",
      "change" = "Change",
      "change_pcnt" = "Percent Change"
    ) |>
    gt::fmt_integer("baseline") |>
    gt::cols_width(
      .data$principal ~ gt::px(150),
      .data$change ~ gt::px(150),
      .data$change_pcnt ~ gt::px(150)
    ) |>
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
