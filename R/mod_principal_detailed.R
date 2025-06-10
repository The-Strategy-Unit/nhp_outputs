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
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h1("Principal projection: activity in detail"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      md_file_to_html("app", "text", "notes-beddays.md")
    ),
    bs4Dash::box(
      title = "Make selections",
      collapsible = FALSE,
      width = 12,
      shiny::fluidRow(
        mod_measure_selection_ui(ns("measure_selection"), width = 3),
        col_3(shiny::selectInput(ns("aggregation"), "Show Results By", NULL))
      )
    ),
    bs4Dash::box(
      title = "Activity by sex and age or treatment specialty",
      collapsible = FALSE,
      width = 12,
      shinycssloaders::withSpinner(
        gt::gt_output(ns("results"))
      )
    )
  )
}

mod_principal_detailed_table <- function(data, aggregation, final_year) {
  data |>
    dplyr::mutate(
      dplyr::across("sex", \(.x) ifelse(.x == 1, "Male", "Female")),
      dplyr::across(
        "final",
        \(.x) gt_bar(.x, scales::comma_format(1), "#686f73", "#686f73")
      ),
      dplyr::across("change", \(.x) gt_bar(.x, scales::comma_format(1))),
      dplyr::across("change_pcnt", \(.x) gt_bar(.x, scales::percent_format(1)))
    ) |>
    gt::gt(groupname_col = "sex") |>
    gt::cols_label(
      agg = dplyr::case_match(
        aggregation,
        "age_group" ~ "Age Group",
        "tretspef" ~ "Treatment Specialty",
        .default = aggregation
      ),
      baseline = "Baseline",
      final = paste0("Final (", final_year, ")"),
      change = "Change",
      change_pcnt = "Percent Change",
    ) |>
    gt::fmt_integer(c("baseline")) |>
    gt::cols_width(
      .data$final ~ gt::px(150),
      .data$change ~ gt::px(150),
      .data$change_pcnt ~ px(150)
    ) |>
    gt::cols_align(
      align = "left",
      columns = c("agg", "final", "change", "change_pcnt")
    ) |>
    gt_theme()
}

#' principal_detailed Server Functions
#'
#' @noRd
mod_principal_detailed_server <- function(id, selected_data, selected_site) {
  shiny::moduleServer(id, function(input, output, session) {
    selected_measure <- mod_measure_selection_server("measure_selection")

    tretspef_lookup <- jsonlite::read_json(
      app_sys("app", "data", "tx-lookup.json"),
      simplifyVector = TRUE
    ) |>
      dplyr::mutate(
        dplyr::across("Description", \(x) stringr::str_remove(x, " Service$")),
        dplyr::across(
          "Description",
          \(x) paste0(.data$Code, ": ", .data$Description)
        ),
      ) |>
      dplyr::select(-"Group") |>
      dplyr::add_row(Code = "&", Description = "Not known") # as per HES dictionary

    available_aggregations <- shiny::reactive({
      selected_data() |>
        get_available_aggregations()
    })

    shiny::observe({
      c(activity_type, pod, measure) %<-% selected_measure()

      a <- available_aggregations()[[activity_type]] |>
        # for this page, just keep the aggregations of the form "a+b"
        stringr::str_subset("^\\w+\\+\\w+$") |>
        # then remove the first word
        stringr::str_remove_all("^\\w+\\+")

      an <- c("age_group" = "Age Group", "tretspef" = "Treatment Specialty")

      agg_choices <- unname(an[a])
      agg_choices <- agg_choices[!is.na(agg_choices)]

      shiny::updateSelectInput(session, "aggregation", choices = agg_choices)
    })

    aggregated_data <- shiny::reactive({
      activity_type <- pod <- measure <- NULL
      c(activity_type, pod, measure) %<-% selected_measure()

      agg_col <- switch(
        shiny::req(input$aggregation),
        "Age Group" = "age_group",
        "Treatment Specialty" = "tretspef"
      )

      dat <- selected_data() |>
        get_aggregation(pod, measure, agg_col, selected_site()) |>
        shiny::req() |>
        dplyr::transmute(
          .data$sex,
          agg = .data[[agg_col]],
          .data$baseline,
          final = .data$principal,
          change = .data$final - .data$baseline,
          change_pcnt = .data$change / .data$baseline
        )

      if (agg_col == "tretspef") {
        dat <- dat |>
          dplyr::left_join(
            tretspef_lookup,
            by = dplyr::join_by("agg" == "Code")
          ) |>
          dplyr::mutate(
            dplyr::across(
              "Description",
              \(x) dplyr::if_else(is.na(x), .data$agg, .data$Description)
            ),
          ) |>
          dplyr::select("sex", "Description", dplyr::everything(), -"agg") |>
          dplyr::rename("agg" = "Description")
      }

      dat
    })

    output$results <- gt::render_gt({
      d <- aggregated_data()

      # handle some edge cases where a dropdown is changed and the next dropdowns aren't yet changed: we get 0 rows of
      # data which causes a bunch of warning messages
      shiny::req(nrow(d) > 0)

      end_year <- selected_data()[["params"]][["end_year"]]
      end_fyear <- paste0(
        end_year,
        "/",
        as.numeric(stringr::str_extract(end_year, "\\d{2}$")) + 1
      )

      mod_principal_detailed_table(d, shiny::req(input$aggregation), end_fyear)
    })
  })
}
