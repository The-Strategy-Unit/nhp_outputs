#' principal_detailed UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_detailed_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::h1("Principal projection: activity in detail"),
    shiny::fluidRow(
      mod_measure_selection_ui(ns("measure_selection"), width = 3),
      col_3(shiny::selectInput(ns("aggregation"), "Show Results By", NULL))
    ),
    shinycssloaders::withSpinner(
      gt::gt_output(ns("results"))
    )
  )
}

mod_principal_detailed_table <- function(data, aggregation) {
  data |>
    dplyr::mutate(
      dplyr::across("sex", ~ ifelse(.x == 1, "Male", "Female")),
      dplyr::across("final", gt_bar, scales::comma_format(1), "#686f73", "#686f73"),
      dplyr::across("change", gt_bar, scales::comma_format(1)),
      dplyr::across("change_pcnt", gt_bar, scales::percent_format(1))
    ) |>
    gt::gt(groupname_col = "sex") |>
    gt::cols_label(
      agg = aggregation,
      baseline = "Baseline",
      final = "Final",
      change = "Change",
      change_pcnt = "Percent Change",
    ) |>
    gt::fmt_integer(c("baseline")) |>
    gt::cols_width(.data$final ~ px(150), .data$change ~ px(150), .data$change_pcnt ~ px(150)) |>
    gt::cols_align(
      align = "left",
      columns = c("agg", "final", "change", "change_pcnt")
    ) |>
    gt_theme()
}

#' principal_detailed Server Functions
#'
#' @noRd
mod_principal_detailed_server <- function(id, selected_model_run_id, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    available_aggregations <- shiny::reactive({
      id <- selected_model_run_id()

      cosmos_get_available_aggregations(id)
    }) |>
      shiny::bindCache(selected_model_run_id())

    shiny::observe({
      c(activity_type, pod, measure) %<-% selected_measure()

      a <- available_aggregations()[[activity_type]] |>
        # for this page, just keep the aggregations of the form "a+b"
        stringr::str_subset("^\\w+\\+\\w+$") |>
        # then remove the first word
        stringr::str_remove_all("^\\w+\\+")

      an <- c("age_group" = "Age Group", "tretspef" = "Treatment Specialty")

      shiny::updateSelectInput(session, "aggregation", choices = unname(an[a]))
    })

    selected_data <- shiny::reactive({
      id <- selected_model_run_id()
      activity_type <- pod <- measure <- NULL
      c(activity_type, pod, measure) %<-% selected_measure()

      agg_col <- switch(shiny::req(input$aggregation),
        "Age Group" = "age_group",
        "Treatment Specialty" = "tretspef"
      )

      cosmos_get_aggregation(id, pod, measure, agg_col) |>
        dplyr::transmute(
          .data$sitetret,
          .data$sex,
          agg = .data[[agg_col]],
          .data$baseline,
          final = .data$principal,
          change = .data$final - .data$baseline,
          change_pcnt = .data$change / .data$baseline
        )
    }) |>
      shiny::bindCache(selected_model_run_id(), selected_measure(), input$aggregation)

    site_data <- shiny::reactive({
      selected_data() |>
        dplyr::filter(.data$sitetret == selected_site(), .data$baseline > 0) |>
        dplyr::select(-"sitetret")
    })

    output$results <- gt::render_gt({
      d <- site_data()

      # handle some edge cases where a dropdown is changed and the next dropdowns aren't yet changed: we get 0 rows of
      # data which causes a bunch of warning messages
      shiny::req(nrow(d) > 0)

      mod_principal_detailed_table(d, shiny::req(input$aggregation))
    })
  })
}
