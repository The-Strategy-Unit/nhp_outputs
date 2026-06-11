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
          include_baseline = input$include_baseline,
          tpma_lookup = reskit::get_tpma_label_lookup(),
          pod_lookup = reskit::get_principal_pods()
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
          sort_by = input$sort_type,
          tpma_lookup = reskit::get_tpma_label_lookup(),
          pod_lookup = reskit::get_principal_pods()
        ) |>
        require_rows() |>
        reskit::make_individual_cf_plot() +
        ggplot2::theme(text = ggplot2::element_text(size = 16))
    })
  })
}
