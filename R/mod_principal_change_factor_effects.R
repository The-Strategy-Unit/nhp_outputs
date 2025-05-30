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
      htmltools::p(
        "These results should be regarded as rough, high-level estimates of the number of rows added/removed due to each parameter.",
        "Bed days are defined as the difference in days between discharge and admission, plus one day.",
        "One bed day is added to account for zero length of stay spells/partial days at the beginning and end of a spell.",
        "See the",
        htmltools::a(
          href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information/user_guide/glossary.html",
          "model project information site"
        ),
        "for definitions of terms."
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
        plotly::plotlyOutput(ns("change_factors"), height = "600px")
      )
    ),
    bs4Dash::box(
      title = "Individual change factors",
      collapsible = FALSE,
      width = 12,
      shiny::selectInput(
        ns("sort_type"),
        "Sort By",
        c("Descending value", "Alphabetical")
      ),
      shinycssloaders::withSpinner(
        shiny::fluidRow(
          plotly::plotlyOutput(ns("activity_avoidance"), height = "600px"),
          plotly::plotlyOutput(ns("efficiencies"), height = "600px")
        )
      )
    )
  )
}

mod_principal_change_factor_effects_summarised <- function(
  data,
  measure,
  include_baseline
) {
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
      hidden = tidyr::replace_na(
        dplyr::lag(.data$cuvalue) + pmin(.data$value, 0),
        0
      ),
      colour = dplyr::case_when(
        .data$change_factor == "Baseline" ~ "#686f73",
        .data$value >= 0 ~ "#f9bf07",
        TRUE ~ "#2c2825"
      ),
      dplyr::across("value", abs)
    ) |>
    dplyr::select(-"cuvalue")

  levels <- unique(c(
    "baseline",
    levels(forcats::fct_drop(cfs$change_factor)),
    "Estimate"
  ))
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
  # Reorient data for geom_segment
  data_reoriented <- data |>
    tidyr::pivot_wider(
      id_cols = tidyselect::all_of("change_factor"),
      names_from = tidyselect::all_of("name"),
      values_from = tidyselect::all_of("value")
    ) |>
    dplyr::mutate(colour = data[["colour"]][!is.na(data[["colour"]])])

  data_reoriented |>
    dplyr::mutate(
      xstart = .data[["hidden"]],
      xend = .data[["hidden"]] + .data[["value"]]
    ) |>
    ggplot2::ggplot(
      ggplot2::aes(
        x = .data[["xstart"]],
        xend = .data[["xend"]],
        y = .data[["change_factor"]],
        yend = .data[["change_factor"]], # plotly errors if yend not included
        colour = .data[["colour"]]
      )
    ) +
    ggplot2::geom_segment(
      # dynamic: bigger if fewer bars (130 is relative to 600px plot height)
      lwd = 130 / nrow(data_reoriented)
    ) +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_x_continuous(
      breaks = scales::pretty_breaks(5),
      labels = scales::comma
    ) +
    ggplot2::scale_y_discrete(labels = snakecase::to_title_case) +
    ggplot2::labs(x = "", y = "")
}

mod_principal_change_factor_effects_ind_plot <- function(
  data,
  change_factor,
  colour,
  title,
  x_axis_label
) {
  data |>
    dplyr::filter(.data$change_factor == .env$change_factor) |>
    dplyr::mutate(
      tooltip = glue::glue(
        "{mitigator_name}: {scales::comma(value, accuracy = 1)}"
      )
    ) |>
    require_rows() |>
    ggplot2::ggplot(
      ggplot2::aes(.data$value, .data$mitigator_name, text = .data[["tooltip"]])
    ) +
    ggplot2::geom_col(fill = "#2c2825") +
    ggplot2::scale_x_continuous(
      breaks = scales::pretty_breaks(5),
      labels = scales::comma
    ) +
    ggplot2::labs(title = title, x = x_axis_label, y = "")
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
        jsonlite::read_json(simplifyVector = TRUE) |>
        purrr::simplify() |>
        tibble::enframe("strategy", "mitigator_name")

      selected_data() |>
        get_principal_change_factors(at, selected_site()) |>
        require_rows() |>
        dplyr::mutate(
          dplyr::across("change_factor", forcats::fct_inorder),
          dplyr::across(
            "change_factor",
            \(.x) forcats::fct_relevel(.x, "baseline", "demographic_adjustment", "health_status_adjustment")
          )
        ) |>
        dplyr::left_join(mitigator_lookup, by = "strategy") |>
        tidyr::replace_na(list("mitigator_name" = "-"))
    })

    principal_change_factors <- shiny::reactive({
      pods <- shiny::req(input$pods)

      principal_change_factors_raw() |>
        require_rows() |>
        dplyr::filter(.data[["pod"]] %in% pods) |>
        dplyr::select(-"pod") |>
        dplyr::count(
          dplyr::across(-"value"),
          wt = .data[["value"]],
          name = "value"
        )
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

    individual_change_factors <- shiny::reactive({
      m <- shiny::req(input$measure)

      d <- principal_change_factors() |>
        dplyr::filter(
          .data$measure == m,
          .data$strategy != "-",
          .data$value < 0
        )

      if (input$sort_type == "Descending value") {
        d |>
          dplyr::mutate(
            dplyr::across(
              "mitigator_name",
              \(.x) forcats::fct_reorder(.x, -.data$value)
            )
          )
      } else {
        d |>
          dplyr::mutate(
            dplyr::across(
              "mitigator_name",
              \(.x) forcats::fct_rev(forcats::fct_reorder(.x, .data$mitigator_name))
            )
          )
      }
    })

    output$change_factors <- plotly::renderPlotly({
      measure <- shiny::req(input$measure)

      p <- principal_change_factors() |>
        mod_principal_change_factor_effects_summarised(
          measure,
          input$include_baseline
        ) |>
        mod_principal_change_factor_effects_cf_plot()

      plotly::ggplotly(p, tooltip = FALSE) |>
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
        plotly::ggplotly(tooltip = FALSE) |>
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
        plotly::ggplotly(tooltip = FALSE) |>
        plotly::layout(showlegend = FALSE)
    })
  })
}
