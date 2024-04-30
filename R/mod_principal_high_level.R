#' principal_high_level UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_high_level_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: activity summary by year"),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Notes",
        collapsible = FALSE,
        width = 12,
        htmltools::p(
          "See the",
          htmltools::a(
            href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/glossary.html",
            "model project information site"
          ),
          "for definitions of terms."
        )
      ),
      bs4Dash::box(
        title = "Activity by type and year",
        collapsible = FALSE,
        bs4Dash::tabsetPanel(
          shiny::tabPanel(
            "Value",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("activity_value"))
            )
          ),
          shiny::tabPanel(
            "Change",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("activity_change"))
            )
          ),
          shiny::tabPanel(
            "Percent change",
            shinycssloaders::withSpinner(
              gt::gt_output(ns("activity_change_pcnt"))
            )
          )
        ),
        width = 12
      )
    ),
    shiny::fluidRow(
      bs4Dash::box(
        title = "Inpatient admissions",
        collapsible = FALSE,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("ip_admissions"))
        ),
        width = 6
      ),
      bs4Dash::box(
        title = "Inpatient bed days",
        collapsible = FALSE,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("ip_beddays"))
        ),
        width = 6
      ),
      bs4Dash::box(
        title = "Outpatient attendances",
        collapsible = FALSE,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("op"))
        ),
        width = 6
      ),
      bs4Dash::box(
        title = "A&E attendances",
        collapsible = FALSE,
        shinycssloaders::withSpinner(
          plotly::plotlyOutput(ns("aae"))
        ),
        width = 6
      )
    )
  )
}

mod_principal_high_level_pods <- function() {
  get_activity_type_pod_measure_options() |>
    dplyr::filter(.data$activity_type != "aae") |>
    dplyr::mutate(
      dplyr::across(
        "pod_name",
        ~ dplyr::if_else(
          .data$measures == "beddays",
          .data$pod_name |> stringr::str_replace("Admission", "Bed Days"),
          .data$pod_name
        )
      ),
      dplyr::across(
        "pod",
        ~ dplyr::if_else(
          .data$activity_type == "ip",
          glue::glue("{.data$pod}_{.data$measures}"),
          .data$pod
        )
      )
    ) |>
    dplyr::mutate(
      dplyr::across(
        "measures",
        ~ forcats::fct_relevel(.data$measures, "admissions", "beddays")
      )
    ) |>
    dplyr::arrange(.data$measures) |>
    dplyr::distinct(.data$activity_type, .data$pod, .data$pod_name) |>
    dplyr::bind_rows(
      data.frame(  # so ambulance and walk-ins can be aggregated under the same pod_name
        activity_type = "aae",
        pod = "aae",
        pod_name = "A&E Attendance"
      )
    ) |>
    dplyr::mutate(dplyr::across("pod_name", forcats::fct_inorder))
}

mod_principal_high_level_summary_data <- function(
    r,
    pods = mod_principal_high_level_pods(),
    sites
) {
  get_time_profiles(r, "default") |>
    dplyr::filter(!.data[["measure"]] %in% c("procedures", "tele_attendances")) |>
    dplyr::mutate(
      dplyr::across(
        "pod",
        ~ dplyr::if_else(
          stringr::str_detect(.data$pod, "^ip_"),
          glue::glue("{.data$pod}_{.data$measure}"),  # unique pod value for admissions and beddays
          .data$pod
        )
      ),
      dplyr::across("pod", ~ ifelse(stringr::str_starts(.x, "aae"), "aae", .x)),
      fyear = fyear_str(.data[["year"]])
    ) |>
    dplyr::summarise(
      dplyr::across("value", sum),
      .by = -c("value", "measure")
    ) |>
    trust_site_aggregation(sites) |>
    dplyr::inner_join(pods, by = "pod") |>
    dplyr::mutate(
      .by = c("pod_name"),
      change = .data$value - dplyr::lag(.data$value),
      change_pcnt = .data$change / dplyr::lag(.data$value)
    ) |>
    dplyr::arrange(.data$activity_type, .data$pod_name) |>
    dplyr::select(-"pod")
}

mod_principal_high_level_table <- function(
    data,
    summary_type = c("value", "change", "change_pcnt")
) {
  summary_type = match.arg(summary_type)

  fyear_rx <- "\\d{4}/\\d{2}"

  suppressWarnings( # TODO: warning in test, all_of should work
    summary_table <- data |>
      dplyr::select(
        "fyear", "pod_name",
        tidyselect::matches(fyear_rx),
        tidyselect::all_of(summary_type),
        "activity_type"
      ) |>
      dplyr::mutate(
        dplyr::across(
          "activity_type",
          ~ dplyr::case_when(
            .data$activity_type == "ip" & stringr::str_detect(.data$pod_name, "Admission") ~ "Inpatient Admissions",
            .data$activity_type == "ip" & stringr::str_detect(.data$pod_name, "Bed Days") ~ "Inpatient Bed Days",
            .data$activity_type == "op"  ~ "Outpatient",
            .data$activity_type == "aae" ~ "A&E"
          )
        ),
        dplyr::across(
          "activity_type",
          ~ forcats::fct_relevel(
            .x,
            "Inpatient Admissions",
            "Inpatient Bed Days",
            "Outpatient",
            "A&E"
          )
        )
      ) |>
      dplyr::arrange(.data$activity_type) |>
      tidyr::pivot_wider(names_from = "fyear", values_from = summary_type) |>
      gt::gt(groupname_col = "activity_type") |>
      gt::sub_missing() |>
      gt::cols_align(
        align = "left",
        columns = "pod_name"
      ) |>
      gt::cols_label("pod_name" = "Point of Delivery")
  )

  if (summary_type %in% c("value", "change")) {
    summary_table <- summary_table |>
      gt::fmt_integer(tidyselect::matches(fyear_rx))
  }

  if (summary_type == "change_pcnt") {
    summary_table <- summary_table |>
      gt::fmt_percent(tidyselect::matches(fyear_rx), decimals = 1)
  }

  summary_table |> gt_theme()
}

mod_principal_high_level_plot <- function(
    data,
    activity_type,
    measure = NULL  # needed because of separate admissions and beddays plots
) {
  start_year <- end_year <- NULL
  c(start_year, end_year) %<-% range(data$year)

  data_filtered <- data |>
    dplyr::filter(.data$activity_type == .env$activity_type)

  if (activity_type == "ip" && measure == "admissions") {
    data_filtered <- data_filtered |>
      dplyr::filter(stringr::str_detect(.data$pod_name, "Admission"))
  }

  if (activity_type == "ip" && measure == "beddays") {
    data_filtered <- data_filtered |>
      dplyr::filter(stringr::str_detect(.data$pod_name, "Bed Days"))
  }

  data_filtered |>
    require_rows() |>
    ggplot2::ggplot(
      ggplot2::aes(
        .data$year,
        .data$value,
        colour = .data$pod_name
      )
    ) +
    ggplot2::geom_line() +
    suppressWarnings(  # TODO: works, but 'Ignoring unknown aesthetics: text' warning
      ggplot2::geom_point(ggplot2::aes(text = glue::glue(
        "{pod_name}\n{year}/{(year + 1) %% 100}: ",
        "{scales::comma(value, accuracy = 1)}"
      )))
    ) +
    ggplot2::scale_x_continuous(
      labels = fyear_str,
      breaks = c(start_year, end_year)
    ) +
    ggplot2::scale_y_continuous(
      labels = scales::comma
    ) +
    ggplot2::expand_limits(y = 0) +
    ggplot2::labs(x = NULL, y = NULL, colour = NULL)
}

#' principal_high_level Server Functions
#'
#' @noRd
mod_principal_high_level_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    pods <- mod_principal_high_level_pods()

    summary_data <- shiny::reactive({
      selected_data() |>
        mod_principal_high_level_summary_data(pods, selected_site())
    })

    output$activity_value <- gt::render_gt({
      summary_data() |>
        mod_principal_high_level_table(summary_type = "value")
    })

    output$activity_change <- gt::render_gt({
      summary_data() |>
        mod_principal_high_level_table(summary_type = "change")
    })

    output$activity_change_pcnt <- gt::render_gt({
      summary_data() |>
        mod_principal_high_level_table(summary_type = "change_pcnt")
    })

    output$aae <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("aae") |>
        plotly::ggplotly(tooltip = "text") |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })

    output$ip_admissions <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("ip", "admissions") |>
        plotly::ggplotly(tooltip = "text") |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })

    output$ip_beddays <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("ip", "beddays") |>
        plotly::ggplotly(tooltip = "text") |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })

    output$op <- plotly::renderPlotly({
      summary_data() |>
        mod_principal_high_level_plot("op") |>
        plotly::ggplotly(tooltip = "text") |>
        plotly::layout(legend = list(
          orientation = "h"
        ))
    })
  })
}
