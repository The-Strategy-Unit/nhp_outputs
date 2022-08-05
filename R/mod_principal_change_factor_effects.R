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
    shiny::fluidRow(
      col_4(shiny::selectInput(ns("activity_type"), "Activity Type", NULL)),
      col_4(shiny::selectInput(ns("measure"), "Measure", NULL)),
      shiny::checkboxInput(ns("include_baseline"), "Include baseline?", TRUE)
    ),
    shinycssloaders::withSpinner(
      plotly::plotlyOutput(ns("change_factors"), height = "600px")
    ),
    shinyjs::hidden(
      shiny::tags$div(
        id = ns("individual_change_factors"),
        shiny::h2("Individual Change Factors"),
        shiny::selectInput(ns("sort_type"), "Sort By", c("alphabetical", "descending value")),
        shinycssloaders::withSpinner(
          shiny::fluidRow(
            col_6(plotly::plotlyOutput(ns("admission_avoidance"), height = "600px")),
            col_6(plotly::plotlyOutput(ns("los_reduction"), height = "600px"))
          )
        )
      )
    )
  )
}

mod_principal_change_factor_effects_summarised <- function(data, measure, include_baseline) {
  data <- data |>
    dplyr::filter(
      .data$measure == .env$measure,
      include_baseline | .data$change_factor != "baseline",
      .data$value != 0
    ) |>
    tidyr::drop_na(.data$value) |>
    dplyr::mutate(
      dplyr::across(
        .data$change_factor,
        forcats::fct_reorder,
        -.data$value
      ),
      # baseline may now not be the first item, move it back to start
      dplyr::across(
        .data$change_factor,
        forcats::fct_relevel,
        "baseline"
      )
    )

  cfs <- data |>
    dplyr::group_by(.data$change_factor) |>
    dplyr::summarise(dplyr::across(.data$value, sum, na.rm = TRUE)) |>
    dplyr::mutate(cuvalue = cumsum(.data$value)) |>
    dplyr::mutate(
      hidden = tidyr::replace_na(dplyr::lag(.data$cuvalue) + pmin(.data$value, 0), 0),
      colour = dplyr::case_when(
        .data$change_factor == "Baseline" ~ "#686f73",
        .data$value >= 0 ~ "#f9bf07",
        TRUE ~ "#2c2825"
      ),
      dplyr::across(.data$value, abs)
    ) |>
    dplyr::select(-.data$cuvalue)

  levels <- unique(c("baseline", levels(forcats::fct_drop(cfs$change_factor)), "Estimate"))
  if (!include_baseline) {
    levels <- levels[-1]
  }

  cfs |>
    dplyr::bind_rows(
      dplyr::tibble(
        change_factor = "Estimate",
        value = sum(data$value),
        hidden = 0,
        colour = "#ec6555"
      )
    ) |>
    tidyr::pivot_longer(c(.data$value, .data$hidden)) |>
    dplyr::mutate(
      dplyr::across(.data$colour, ~ ifelse(.data$name == "hidden", NA, .x)),
      dplyr::across(.data$name, forcats::fct_relevel, "hidden", "value"),
      dplyr::across(.data$change_factor, factor, rev(levels))
    )
}

mod_principal_change_factor_effects_cf_plot <- function(data) {
  ggplot2::ggplot(data, ggplot2::aes(.data$value, .data$change_factor)) +
    ggplot2::geom_col(ggplot2::aes(fill = .data$colour), show.legend = FALSE, position = "stack") +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(labels = scales::comma) +
    ggplot2::scale_y_discrete(labels = snakecase::to_title_case) +
    ggplot2::labs(x = "", y = "")
}

mod_principal_change_factor_effects_ind_plot <- function(data, change_factor, colour, title, x_axis_label) {
  data |>
    dplyr::filter(.data$change_factor == .env$change_factor) |>
    ggplot2::ggplot(ggplot2::aes(.data$value, .data$strategy)) +
    ggplot2::geom_col(fill = "#f9bf07") +
    ggplot2::scale_x_continuous(labels = scales::comma) +
    ggplot2::scale_y_discrete(labels = snakecase::to_title_case) +
    ggplot2::labs(title = title, x = x_axis_label, y = "")
}

#' principal_change_factor_effects Server Functions
#'
#' @noRd
mod_principal_change_factor_effects_server <- function(id, selected_model_run_id) {
  shiny::moduleServer(id, function(input, output, session) {
    shiny::observe({
      activity_types <- get_activity_type_pod_measure_options() |>
        dplyr::distinct(
          dplyr::across(
            tidyselect::starts_with("activity_type")
          )
        ) |>
        set_names()

      shiny::updateSelectInput(session, "activity_type", choices = activity_types)
    })

    principal_change_factors <- shiny::reactive({
      at <- shiny::req(input$activity_type)

      id <- selected_model_run_id()

      cosmos_get_principal_change_factors(id, at) |>
        dplyr::mutate(
          dplyr::across(.data$change_factor, forcats::fct_inorder),
          dplyr::across(
            .data$change_factor,
            forcats::fct_relevel,
            "baseline",
            "population_factors",
            "health_status_adjustment"
          )
        )
    }) |>
      shiny::bindCache(selected_model_run_id(), input$activity_type)

    shiny::observeEvent(principal_change_factors(), {
      at <- shiny::req(input$activity_type)
      pcf <- shiny::req(principal_change_factors())

      measures <- unique(pcf$measure)

      shiny::req(length(measures) > 0)

      shiny::updateSelectInput(session, "measure", choices = measures)
    })

    individual_change_factors <- shiny::reactive({
      m <- shiny::req(input$measure)

      d <- principal_change_factors() |>
        dplyr::filter(
          .data$measure == m,
          .data$strategy != "-",
          .data$value < 0
        )

      if (input$sort_type == "descending value") {
        dplyr::mutate(d, dplyr::across(.data$strategy, forcats::fct_reorder, -.data$value))
      } else {
        dplyr::mutate(d, dplyr::across(.data$strategy, forcats::fct_reorder, .data$strategy))
      }
    })

    shiny::observeEvent(individual_change_factors(), {
      d <- individual_change_factors()

      shinyjs::toggle("individual_change_factors", condition = nrow(d) > 0)
    })

    output$change_factors <- plotly::renderPlotly({
      measure <- shiny::req(input$measure)

      p <- principal_change_factors() |>
        mod_principal_change_factor_effects_summarised(measure, input$include_baseline) |>
        mod_principal_change_factor_effects_cf_plot()

      plotly::ggplotly(p) |>
        plotly::layout(showlegend = FALSE)
    })

    output$admission_avoidance <- plotly::renderPlotly({
      mod_principal_change_factor_effects_ind_plot(
        individual_change_factors(),
        "admission_avoidance",
        "#f9bf07",
        "Admission Avoidance",
        "Admissions"
      ) |>
        plotly::ggplotly() |>
        plotly::layout(showlegend = FALSE)
    })

    output$los_reduction <- plotly::renderPlotly({
      mod_principal_change_factor_effects_ind_plot(
        individual_change_factors(),
        "los_reduction",
        "#ec6555",
        "Length of Stay Reduction",
        "Bed Days"
      ) |>
        plotly::ggplotly() |>
        plotly::layout(showlegend = FALSE)
    })
  })
}
