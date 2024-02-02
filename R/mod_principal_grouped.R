#' principal_grouped UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_grouped_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: activity grouped"),
    bs4Dash::box(
      collapsible = FALSE,
      headerBorder = FALSE,
      width = 12,
      shiny::fluidRow(
        mod_measure_selection_ui(ns("measure_selection"), width = 3)
      )
    ),
    bs4Dash::box(
      collapsible = FALSE,
      headerBorder = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("results"))
      )
    )
  )
}

mod_principal_grouped_table <- function(data) {

  data |>
    dplyr::mutate(
      dplyr::across("final", \(.x) gt_bar(.x, scales::comma_format(1), "#686f73", "#686f73")),
      dplyr::across("change", \(.x) gt_bar(.x, scales::comma_format(1))),
      dplyr::across("change_pcnt", \(.x) gt_bar(.x, scales::percent_format(1)))
    ) |>
    gt::gt() |>
    gt::cols_label(
      agg = "Treatment Code Group",
      baseline = "Baseline",
      final = "Final",
      change = "Change",
      change_pcnt = "Percent Change",
    ) |>
    gt::fmt_integer(c("baseline")) |>
    gt::cols_width(
      .data$final ~ px(150),
      .data$change ~ px(150),
      .data$change_pcnt ~ px(150)
    ) |>
    gt::cols_align(
      align = "left",
      columns = c("agg", "final", "change", "change_pcnt")
    ) |>
    gt_theme()
}

#' principal_grouped Server Functions
#'
#' @noRd
mod_principal_grouped_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    aggregated_data <- shiny::reactive({
      activity_type <- pod <- measure <- NULL
      c(activity_type, pod, measure) %<-% selected_measure()

      tretspef_lookup <- jsonlite::read_json(
        app_sys("app", "data", "tx-lookup-mike.json"),
        simplifyVector = TRUE
      )

      agg_data <- selected_data() |>
        get_aggregation(pod, measure, "tretspef_raw", selected_site())

      if (is.null(agg_data)) {
        return(NULL)  # A&E activity type isn't viable if selected
      }

      agg_data |>
        dplyr::left_join(
          tretspef_lookup,
          by = dplyr::join_by("tretspef_raw" == "Code")
        ) |>
        dplyr::mutate(Group = dplyr::if_else(is.na(Group), "Other", Group)) |>
        dplyr::summarise(
          dplyr::across(c("baseline", "principal"), sum),
          .by = "Group"
        ) |>
        dplyr::rename(
          "agg" = "Group",
          "final" = "principal"
        ) |>
        dplyr::mutate(
          change = .data$final - .data$baseline,
          change_pcnt = .data$change / .data$baseline,
          change_pcnt = dplyr::if_else(
            is.infinite(.data$change_pcnt),
            NA_real_,
            .data$change_pcnt
          )
        ) |>
        dplyr::arrange("agg")
    })

    output$results <- gt::render_gt({
      d <- aggregated_data()

      # handle some edge cases where a dropdown is changed and the next dropdowns aren't yet changed: we get 0 rows of
      # data which causes a bunch of warning messages
      shiny::req(nrow(d) > 0)

      mod_principal_grouped_table(d)
    })
  })
}
