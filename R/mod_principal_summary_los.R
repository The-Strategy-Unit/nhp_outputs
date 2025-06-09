#' principal_summary_los UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_summary_los_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: length of stay summary"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes-beddays.md")
    ),
    bs4Dash::box(
      title = "Bed days summary by length of stay and point of delivery",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("summary_los_table_beddays"))
      )
    ),
    bs4Dash::box(
      title = "Admissions summary by length of stay and point of delivery",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("summary_los_table_admissions"))
      )
    )
  )
}

mod_principal_los_pods <- function() {
  get_activity_type_pod_measure_options() |>
    dplyr::filter(.data$activity_type != "aae") |>
    dplyr::distinct(.data$activity_type, .data$pod, .data$pod_name) |>
    dplyr::bind_rows(data.frame(
      activity_type = "aae",
      pod = "aae",
      pod_name = "A&E Attendance"
    )) |>
    dplyr::mutate(dplyr::across("pod_name", forcats::fct_inorder))
}

mod_principal_summary_los_data <- function(r, sites, measure) {
  pods <- mod_principal_los_pods()

  summary_los <- r$results[["tretspef_raw+los_group"]] |>
    dplyr::filter(.data$measure == .env$measure) |>
    dplyr::select(-"tretspef_raw") |>
    trust_site_aggregation(sites) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::mutate(
      change = .data$principal - .data$baseline,
      change_pcnt = .data$change / .data$baseline
    ) |>
    dplyr::select(
      "pod_name",
      "los_group",
      "baseline",
      "principal",
      "change",
      "change_pcnt"
    )

  if (measure == "beddays") {
    summary_los <- summary_los |>
      dplyr::mutate(
        pod_name = forcats::fct_relabel(
          .data$pod_name,
          \(.x) stringr::str_replace(.x, "Admission", "Bed Days")
        )
      )
  }

  summary_los[order(summary_los$pod_name, summary_los$los_group), ]
}

mod_principal_summary_los_table <- function(data) {
  data |>
    dplyr::mutate(
      dplyr::across(
        "principal",
        \(.x) gt_bar(.x, scales::comma_format(1), "#686f73", "#686f73")
      ),
      dplyr::across("change", \(.x) gt_bar(.x, scales::comma_format(1))),
      dplyr::across("change_pcnt", \(.x) gt_bar(.x, scales::percent_format(1)))
    ) |>
    gt::gt(groupname_col = "pod_name") |>
    gt::cols_align(align = "left", columns = "los_group") |>
    gt::cols_label(
      "los_group" = "Length of Stay",
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
mod_principal_summary_los_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    summary_los_data_beddays <- shiny::reactive({
      selected_data() |>
        mod_principal_summary_los_data(selected_site(), measure = "beddays")
    })

    summary_los_data_admissions <- shiny::reactive({
      selected_data() |>
        mod_principal_summary_los_data(selected_site(), measure = "admissions")
    })

    output$summary_los_table_beddays <- gt::render_gt({
      summary_los_data_beddays() |>
        mod_principal_summary_los_table()
    })

    output$summary_los_table_admissions <- gt::render_gt({
      summary_los_data_admissions() |>
        mod_principal_summary_los_table()
    })
  })
}
