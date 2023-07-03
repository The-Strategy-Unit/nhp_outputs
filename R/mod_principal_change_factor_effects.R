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
      headerBorder = FALSE,
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(
        col_4(shiny::selectInput(ns("activity_type"), "Activity Type", NULL)),
        col_4(shiny::selectInput(ns("measure"), "Measure", NULL)),
        shiny::checkboxInput(ns("include_baseline"), "Include baseline?", TRUE)
      )
    ),
    bs4Dash::box(
      title = "Impact of Changes",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        plotly::plotlyOutput(ns("change_factors"), height = "600px")
      )
    ),
    bs4Dash::box(
      title = "Individual Change Factors",
      collapsible = FALSE,
      width = 12,
      shiny::selectInput(ns("sort_type"), "Sort By", c("alphabetical", "descending value")),
      shinycssloaders::withSpinner(
        shiny::fluidRow(
          col_6(plotly::plotlyOutput(ns("activity_avoidance"), height = "600px")),
          col_6(plotly::plotlyOutput(ns("efficiencies"), height = "600px"))
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
    tidyr::drop_na("value") |>
    dplyr::mutate(
      dplyr::across(
        "change_factor",
        \(.x) forcats::fct_reorder(.x, -.data$value)
      ),
      # baseline may now not be the first item, move it back to start
      dplyr::across(
        "change_factor",
        \(.x) forcats::fct_relevel(.x, "baseline")
      )
    )

  cfs <- data |>
    dplyr::group_by(.data$change_factor) |>
    dplyr::summarise(dplyr::across("value", \(.x) sum(.x, na.rm = TRUE))) |>
    dplyr::mutate(cuvalue = cumsum(.data$value)) |>
    dplyr::mutate(
      hidden = tidyr::replace_na(dplyr::lag(.data$cuvalue) + pmin(.data$value, 0), 0),
      colour = dplyr::case_when(
        .data$change_factor == "Baseline" ~ "#686f73",
        .data$value >= 0 ~ "#f9bf07",
        TRUE ~ "#2c2825"
      ),
      dplyr::across("value", abs)
    ) |>
    dplyr::select(-"cuvalue")

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
    tidyr::pivot_longer(c("value", "hidden")) |>
    dplyr::mutate(
      dplyr::across("colour", \(.x) ifelse(.data$name == "hidden", NA, .x)),
      dplyr::across("name", \(.x) forcats::fct_relevel(.x, "hidden", "value")),
      dplyr::across("change_factor", \(.x) factor(.x, rev(levels)))
    )
}

mod_principal_change_factor_effects_cf_plot <- function(data) {
  data |>
    dplyr::mutate(
      tooltip = ifelse(
        .data[["name"]] == "hidden",
        0,
        value
      ),
      tooltip = glue::glue("{change_factor}: {scales::comma(sum(tooltip), accuracy = 1)}"),
      .by = "change_factor"
    ) |>
    ggplot2::ggplot(
      ggplot2::aes(
        .data[["value"]],
        .data[["change_factor"]],
        text = .data[["tooltip"]]
      )
    ) +
    ggplot2::geom_col(
      ggplot2::aes(
        fill = .data[["colour"]]
      ),
      show.legend = FALSE,
      position = "stack"
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(labels = scales::comma) +
    ggplot2::scale_y_discrete(labels = snakecase::to_title_case) +
    ggplot2::labs(x = "", y = "")
}

mod_principal_change_factor_effects_ind_plot <- function(data, change_factor, colour, title, x_axis_label) {
  data |>
    dplyr::filter(.data$change_factor == .env$change_factor) |>
    require_rows() |>
    ggplot2::ggplot(ggplot2::aes(.data$value, .data$strategy)) +
    ggplot2::geom_col(fill = "#f9bf07") +
    ggplot2::scale_x_continuous(labels = scales::comma) +
    ggplot2::scale_y_discrete(labels = snakecase::to_title_case) +
    ggplot2::labs(title = title, x = x_axis_label, y = "")
}

#' principal_change_factor_effects Server Functions
#'
#' @noRd
mod_principal_change_factor_effects_server <- function(id, selected_data) {
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

      selected_data() |>
        get_principal_change_factors(at) |>
        dplyr::mutate(
          dplyr::across("change_factor", forcats::fct_inorder),
          dplyr::across(
            "change_factor",
            \(.x) forcats::fct_relevel(.x, "baseline", "demographic_adjustment", "health_status_adjustment")
          )
        )
    })

    shiny::observe({
      at <- shiny::req(input$activity_type)
      pcf <- shiny::req(principal_change_factors())

      measures <- unique(pcf$measure)

      shiny::req(length(measures) > 0)

      shiny::updateSelectInput(session, "measure", choices = measures)
    }) |>
      shiny::bindEvent(principal_change_factors())

    individual_change_factors <- shiny::reactive({
      m <- shiny::req(input$measure)

      d <- principal_change_factors() |>
        dplyr::filter(
          .data$measure == m,
          .data$strategy != "-",
          .data$value < 0
        )

      if (input$sort_type == "descending value") {
        dplyr::mutate(d, dplyr::across("strategy", \(.x) forcats::fct_reorder(.x, -.data$value)))
      } else {
        dplyr::mutate(d, dplyr::across("strategy", \(.x) forcats::fct_reorder(.x, .data$strategy)))
      }
    })

    output$change_factors <- plotly::renderPlotly({
      measure <- shiny::req(input$measure)

      p <- principal_change_factors() |>
        mod_principal_change_factor_effects_summarised(measure, input$include_baseline) |>
        mod_principal_change_factor_effects_cf_plot()

      plotly::ggplotly(p, tooltip = "text") |>
        plotly::layout(showlegend = FALSE)
    })

    output$activity_avoidance <- plotly::renderPlotly({
      mod_principal_change_factor_effects_ind_plot(
        individual_change_factors(),
        "activity_avoidance",
        "#f9bf07",
        "Activity Avoidance",
        snakecase::to_title_case(input$measure)
      ) |>
        plotly::ggplotly() |>
        plotly::layout(showlegend = FALSE)
    })

    output$efficiencies <- plotly::renderPlotly({
      mod_principal_change_factor_effects_ind_plot(
        individual_change_factors(),
        "efficiencies",
        "#ec6555",
        "Efficiencies",
        snakecase::to_title_case(input$measure)
      ) |>
        plotly::ggplotly() |>
        plotly::layout(showlegend = FALSE)
    })
  })
}
