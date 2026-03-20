#' principal_change_factor_effects UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_principal_change_factor_effects_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: impact of changes"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes-beddays.md"),
      htmltools::p(
        "Regard these results as rough, high-level estimates of the number of",
        "rows added/removed due to each parameter."
      )
    ),
    bs4Dash::box(
      title = "Make selections",
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(
        col_4(shiny::selectInput(ns("activity_type"), "Activity Type", NULL)),
        col_4(shiny::selectInput(
          ns("pods"),
          "Point of Delivery",
          NULL,
          multiple = TRUE
        )),
        col_4(shiny::selectInput(ns("measure"), "Measure", NULL))
      )
    ),
    bs4Dash::box(
      title = "Impact of changes",
      collapsible = FALSE,
      width = 12,
      shiny::checkboxInput(ns("include_baseline"), "Include baseline?", TRUE),
      shinycssloaders::withSpinner(
        shiny::plotOutput(ns("change_factors"), height = "600px")
      )
    ),
    bs4Dash::box(
      title = "Individual change factors",
      collapsible = FALSE,
      width = 12,
      shiny::selectInput(
        ns("sort_type"),
        "Sort By",
        c("Descending value" = "value", "Alphabetical" = "tpma_label")
      ),
      shinycssloaders::withSpinner(
        shiny::fluidRow(
          shiny::plotOutput(ns("individual_change_factors"), height = "1200px")
        )
      )
    )
  )
}


#' principal_change_factor_effects Server Functions
#'
#' @noRd
mod_principal_change_factor_effects_server <- function(
  id,
  selected_data,
  selected_site
) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observe({
      activity_types <- get_activity_type_pod_measure_options() |>
        dplyr::distinct(
          dplyr::across(
            tidyselect::starts_with("activity_type")
          )
        ) |>
        set_names()

      shiny::updateSelectInput(
        session,
        "activity_type",
        choices = activity_types
      )
    })

    principal_change_factors_raw <- shiny::reactive({
      at <- shiny::req(input$activity_type)

      mitigator_lookup <- app_sys("app", "data", "mitigators.json") |>
        yyjsonr::read_json_file() |>
        purrr::simplify() |>
        tibble::enframe("strategy", "mitigator_name")

      selected_data() |>
        get_principal_change_factors(at, selected_site()) |>
        require_rows() |>
        dplyr::mutate(
          dplyr::across("change_factor", forcats::fct_inorder),
          dplyr::across(
            "change_factor",
            \(.x) {
              forcats::fct_relevel(
                .x,
                "baseline",
                "demographic_adjustment",
                "health_status_adjustment"
              )
            }
          )
        ) |>
        dplyr::left_join(
          mitigator_lookup,
          by = dplyr::join_by("strategy")
        ) |>
        tidyr::replace_na(list("mitigator_name" = "-"))
    })

    shiny::observe({
      at <- shiny::req(input$activity_type)
      pcf <- shiny::req(principal_change_factors_raw())

      pod_names <- get_activity_type_pod_measure_options() |>
        dplyr::filter(.data[["activity_type"]] == at) |>
        dplyr::distinct(.data[["pod_name"]], .data[["pod"]]) |>
        tibble::deframe()

      measure_names <- get_golem_config("measures")

      pods <- unique(pcf$pod)
      measures <- unique(pcf$measure)

      shiny::req(length(measures) > 0)

      shiny::updateSelectInput(
        session,
        "pods",
        choices = pod_names[pods %in% pod_names],
        selected = pods
      )

      shiny::updateSelectInput(
        session,
        "measure",
        choices = purrr::set_names(measures, measure_names[measures]),
        selected = ifelse(at == "ip", "beddays", measures[[1]])
      )
    }) |>
      shiny::bindEvent(principal_change_factors_raw())

    output$change_factors <- shiny::renderPlot({
      shiny::req(input$pods)
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_change_factor_data(
          measure = input$measure,
          activity_type = input$activity_type,
          pods = input$pods,
          sites = selected_site(),
          include_baseline = input$include_baseline
        ) |>
        require_rows() |>
        reskit::make_overall_cf_plot() +
        ggplot2::theme(text = ggplot2::element_text(size = 16))
    })

    output$individual_change_factors <- shiny::renderPlot({
      shiny::req(input$pods)
      selected_data() |>
        reskit::shim_results() |>
        reskit::compile_indiv_change_factor_data(
          measure = input$measure,
          activity_type = input$activity_type,
          pods = input$pods,
          sites = selected_site(),
          sort_by = input$sort_type
        ) |>
        require_rows() |>
        reskit::make_individual_cf_plot(
          x_axis_label = snakecase::to_title_case(input$measure)
        ) +
        ggplot2::theme(text = ggplot2::element_text(size = 16))
    })
  })
}
