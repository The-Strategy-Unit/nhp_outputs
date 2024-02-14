#' info_params UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_info_params_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::h1("Information: input parameters"),
    bs4Dash::box(
      title = "Notes",
      collapsible = FALSE,
      width = 12,
      htmltools::p(
        "This page contains a reminder of the parameter values you provided to the model inputs app.",
        "Further information about the model and these outputs can be found on the",
        htmltools::a(
          href = "https://connect.strategyunitwm.nhs.uk/nhp/project_information",
          "model project information site."
        ),
      )
    ),
    bs4Dash::box(
      title = "Model Run",
      collapsed = TRUE,
      width = 12,
      gt::gt_output(ns("params_model_run"))
    ),
    bs4Dash::box(
      title = "Demographic factors",
      collapsed = TRUE,
      width = 12,
      gt::gt_output(ns("params_demographic_factors"))
    ),
    bs4Dash::box(
      title = "Baseline adjustment",
      collapsed = TRUE,
      width = 12,
      gt::gt_output(ns("params_baseline_adjustment"))
    ),
    bs4Dash::box(
      title = "Covid adjustment",
      collapsed = TRUE,
      width = 12,
      gt::gt_output(ns("params_covid_adjustment"))
    ),
    bs4Dash::box(
      title = "Waiting list adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::tags$p(
        "Time Profile:",
        shiny::textOutput(ns("time_profile_waiting_list_adjustment"), inline = TRUE)
      ),
      gt::gt_output(ns("params_waiting_list_adjustment"))
    ),
    bs4Dash::box(
      title = "Expatriation",
      collapsed = TRUE,
      width = 12,
      shiny::tags$p(
        "Time Profile:",
        shiny::textOutput(ns("time_profile_expat"), inline = TRUE)
      ),
      gt::gt_output(ns("params_expat"))
    ),
    bs4Dash::box(
      title = "Repatriation (local)",
      collapsed = TRUE,
      width = 12,
      shiny::tags$p(
        "Time Profile:",
        shiny::textOutput(ns("time_profile_repat_local"), inline = TRUE)
      ),
      gt::gt_output(ns("params_repat_local"))
    ),
    bs4Dash::box(
      title = "Repatriation (non-local)",
      collapsed = TRUE,
      width = 12,
      shiny::tags$p(
        "Time Profile:",
        shiny::textOutput(ns("time_profile_repat_nonlocal"), inline = TRUE)
      ),
      gt::gt_output(ns("params_repat_nonlocal"))
    ),
    bs4Dash::box(
      title = "Non-demographic adjustment",
      collapsed = TRUE,
      width = 12,
      gt::gt_output(ns("params_non_demographic_adjustment"))
    ),
    bs4Dash::box(
      title = "Activity avoidance",
      collapsed = TRUE,
      width = 12,
      gt::gt_output(ns("params_activity_avoidance"))
    ),
    bs4Dash::box(
      title = "Efficiencies",
      collapsed = TRUE,
      width = 12,
      gt::gt_output(ns("params_efficiencies"))
    ),
    bs4Dash::box(
      title = "Bed occupancy",
      collapsed = TRUE,
      width = 12,
      shiny::fluidRow(
        col_6(
          shiny::h4("Day and night"),
          gt::gt_output(ns("params_bed_occupancy_day_night")),
        ),
        col_6(
          shiny::h4("Specialty mapping"),
          gt::gt_output(ns("params_bed_occupancy_specialty_mapping"))
        )
      )
    )
  )
}

#' info_params Server Functions
#'
#' @noRd
mod_info_params_server <- function(id, selected_data) {
  shiny::moduleServer(id, function(input, output, session) {
    at <- get_activity_type_pod_measure_options() |>
      dplyr::distinct(
        dplyr::across(
          tidyselect::starts_with("activity_type")
        )
      )

    specs <- app_sys("app", "data", "tx-lookup.json") |>
      jsonlite::read_json(simplifyVector = TRUE) |>
      dplyr::select(
        "specialty" = "Code",
        "specialty_name" = "Description"
      )

    strategies <- app_sys("app", "data", "mitigators.json") |>
      jsonlite::read_json(simplifyVector = TRUE) |>
      unlist() |>
      tibble::enframe("strategy", "mitigator_name")

    fix_data <- function(df) {
      fix_activity_type <- function(df) {
        if (!"activity_type" %in% colnames(df)) {
          return(df)
        }

        df |>
          dplyr::inner_join(at, by = dplyr::join_by("activity_type")) |>
          dplyr::select(-"activity_type")
      }

      fix_specialty <- function(df) {
        if (!"specialty" %in% colnames(df)) {
          return(df)
        }

        df |>
          dplyr::left_join(specs, by = dplyr::join_by("specialty")) |>
          dplyr::mutate(
            dplyr::across(
              "specialty_name",
              \(.x) ifelse(is.na(.x), .data[["specialty"]], .x)
            )
          ) |>
          dplyr::select(-"specialty")
      }

      fix_strategy <- function(df) {
        if (!"strategy" %in% colnames(df)) {
          return(df)
        }

        df |>
          dplyr::left_join(strategies, by = dplyr::join_by("strategy")) |>
          dplyr::select(-"strategy")
      }

      df |>
        fix_activity_type() |>
        fix_specialty() |>
        fix_strategy()
    }

    params_data <- shiny::reactive({
      get_params(selected_data())
    })

    output$params_model_run <- gt::render_gt({
      p <- params_data()

      p_model_run <- purrr::keep(p, rlang::is_atomic)

      p_model_run[["start_year"]] <- scales::number(
        p_model_run[["start_year"]] + ((p_model_run[["start_year"]] + 1) %% 100) / 100,
        0.01,
        big.mark = "", decimal.mark = "/"
      )
      p_model_run[["end_year"]] <- scales::number(
        p_model_run[["end_year"]] + ((p_model_run[["end_year"]] + 1) %% 100) / 100,
        0.01,
        big.mark = "",
        decimal.mark = "/"
      )

      p_model_run[["create_datetime"]] <- p_model_run[["create_datetime"]] |>
        lubridate::fast_strptime("%Y%m%d_%H%M%S") |>
        format("%d-%b-%Y %H:%M%:%S")

      p_model_run |>
        unlist() |>
        tibble::enframe() |>
        gt::gt("name") |>
        gt_theme()
    })

    output$params_demographic_factors <- gt::render_gt({
      p <- params_data()

      demographic_adjustment <- p[["demographic_factors"]]

      shiny::validate(
        shiny::need(demographic_adjustment, "No parameters provided")
      )

      demographic_adjustment |>
        purrr::pluck("variant_probabilities") |>
        unlist() |>
        tibble::enframe("variant", "value") |>
        gt::gt("variant") |>
        gt::fmt_percent("value") |>
        gt_theme()
    })

    output$params_baseline_adjustment <- gt::render_gt({
      p <- params_data()

      baseline_adjustment <- local({
        x <- p[["baseline_adjustment"]]
        if (!is.null(x[["aae"]])) {
          x[["aae"]] <- purrr::map(x[["aae"]], \(.x) list(Other = .x))
        }
        return(x)
      })

      shiny::validate(
        shiny::need(baseline_adjustment, "No parameters provided")
      )

      baseline_adjustment |>
        purrr::map_depth(2, tibble::enframe, "specialty") |>
        purrr::map(dplyr::bind_rows, .id = "pod") |>
        dplyr::bind_rows(.id = "activity_type") |>
        fix_data() |>
        dplyr::relocate("value", .after = tidyselect::everything()) |>
        tidyr::unnest_wider("value") |>
        gt::gt("specialty_name", c("activity_type_name", "pod")) |>
        gt_theme()
    })

    output$params_covid_adjustment <- gt::render_gt({
      p <- params_data()

      covid_adjustment <- p[["covid_adjustment"]]

      shiny::validate(
        shiny::need(covid_adjustment, "No parameters provided")
      )

      covid_adjustment |>
        purrr::map(tibble::enframe, "pod") |>
        dplyr::bind_rows(.id = "activity_type") |>
        tidyr::unnest_wider("value") |>
        fix_data() |>
        gt::gt("pod", "activity_type_name") |>
        gt_theme()
    })

    output$params_waiting_list_adjustment <- gt::render_gt({
      p <- params_data()

      waiting_list_adjustment <- p[["waiting_list_adjustment"]]

      shiny::validate(
        shiny::need(waiting_list_adjustment, "No parameters provided")
      )

      waiting_list_adjustment |>
        purrr::map(tibble::enframe, "specialty", "value") |>
        dplyr::bind_rows(.id = "activity_type") |>
        tidyr::unnest("value") |>
        fix_data() |>
        tidyr::pivot_wider(names_from = "activity_type_name") |>
        gt::gt("specialty_name") |>
        gt::sub_missing(missing_text = "") |>
        gt_theme()
    })

    output$params_expat <- gt::render_gt({
      p <- params_data()

      expat <- local({
        x <- p[["expat"]]
        if (!is.null(x[["op"]])) {
          x[["op"]] <- list("-" = x[["op"]])
        }
        if (!is.null(x[["aae"]])) {
          x[["aae"]] <- purrr::map(x[["aae"]], \(.x) list(Other = .x))
        }
        return(x)
      })

      shiny::validate(
        shiny::need(expat, "No parameters provided")
      )

      expat |>
        purrr::map_depth(2, tibble::enframe, "specialty") |>
        purrr::map(dplyr::bind_rows, .id = "pod") |>
        dplyr::bind_rows(.id = "activity_type") |>
        tidyr::unnest_wider("value") |>
        fix_data() |>
        dplyr::relocate("lo", "hi", .after = tidyselect::everything()) |>
        gt::gt("specialty_name", c("activity_type_name", "pod")) |>
        gt_theme()
    })

    output$params_repat_local <- gt::render_gt({
      p <- params_data()

      repat <- local({
        x <- p[["repat_local"]]
        if (!is.null(x[["op"]])) {
          x[["op"]] <- list("-" = x[["op"]])
        }
        if (!is.null(x[["aae"]])) {
          x[["aae"]] <- purrr::map(x[["aae"]], \(.x) list(Other = .x))
        }
        return(x)
      })

      shiny::validate(
        shiny::need(repat, "No parameters provided")
      )

      repat |>
        purrr::map_depth(2, tibble::enframe, "specialty") |>
        purrr::map(dplyr::bind_rows, .id = "pod") |>
        dplyr::bind_rows(.id = "activity_type") |>
        tidyr::unnest_wider("value") |>
        fix_data() |>
        dplyr::relocate("lo", "hi", .after = tidyselect::everything()) |>
        gt::gt("specialty_name", c("activity_type_name", "pod")) |>
        gt_theme()
    })

    output$params_repat_nonlocal <- gt::render_gt({
      p <- params_data()

      repat <- local({
        x <- p[["repat_nonlocal"]]
        if (!is.null(x[["op"]])) {
          x[["op"]] <- list("-" = x[["op"]])
        }
        if (!is.null(x[["aae"]])) {
          x[["aae"]] <- purrr::map(x[["aae"]], \(.x) list(Other = .x))
        }
        return(x)
      })

      shiny::validate(
        shiny::need(repat, "No parameters provided")
      )

      repat |>
        purrr::map_depth(2, tibble::enframe, "specialty") |>
        purrr::map(dplyr::bind_rows, .id = "pod") |>
        dplyr::bind_rows(.id = "activity_type") |>
        tidyr::unnest_wider("value") |>
        fix_data() |>
        dplyr::relocate("lo", "hi", .after = tidyselect::everything()) |>
        gt::gt("specialty_name", c("activity_type_name", "pod")) |>
        gt_theme()
    })

    output$params_non_demographic_adjustment <- gt::render_gt({
      p <- params_data()

      non_demographic_adjustment <- p[["non-demographic_adjustment"]]

      shiny::validate(
        shiny::need(non_demographic_adjustment, "No parameters provided")
      )

      non_demographic_adjustment |>
        purrr::map(tibble::enframe, "pod") |>
        dplyr::bind_rows(.id = "activity_type") |>
        fix_data() |>
        tidyr::unnest_wider("value") |>
        gt::gt("pod", "activity_type_name") |>
        gt_theme()
    })

    output$params_activity_avoidance <- gt::render_gt({
      p <- params_data()

      actitvity_avoidance <- p[["activity_avoidance"]]

      shiny::validate(
        shiny::need(actitvity_avoidance, "No parameters provided")
      )

      time_profiles <- p[["time_profile_mappings"]][["activity_avoidance"]] |>
        purrr::map(unlist) |>
        purrr::map(tibble::enframe, "strategy", "time_profile") |>
        dplyr::bind_rows(.id = "activity_type")

      actitvity_avoidance |>
        purrr::map_depth(2, "interval") |>
        purrr::map(tibble::enframe, "strategy") |>
        dplyr::bind_rows(.id = "activity_type") |>
        tidyr::unnest_wider("value") |>
        dplyr::left_join(
          time_profiles,
          by = dplyr::join_by("activity_type", "strategy")
        ) |>
        fix_data() |>
        dplyr::arrange("activity_type_name", "mitigator_name") |>
        gt::gt("mitigator_name", "activity_type_name") |>
        gt_theme()
    })

    output$params_efficiencies <- gt::render_gt({
      p <- params_data()


      efficiencies <- p[["efficiencies"]]

      shiny::validate(
        shiny::need(efficiencies, "No parameters provided")
      )

      time_profiles <- p[["time_profile_mappings"]][["efficiencies"]] |>
        purrr::map(unlist) |>
        purrr::map(tibble::enframe, "strategy", "time_profile") |>
        dplyr::bind_rows(.id = "activity_type")

      efficiencies |>
        purrr::map_depth(2, "interval") |>
        purrr::map(tibble::enframe, "strategy") |>
        dplyr::bind_rows(.id = "activity_type") |>
        tidyr::unnest_wider("value") |>
        dplyr::left_join(
          time_profiles,
          by = dplyr::join_by("activity_type", "strategy")
        ) |>
        fix_data() |>
        dplyr::arrange("activity_type_name", "mitigator_name") |>
        gt::gt("mitigator_name", "activity_type_name") |>
        gt_theme()
    })

    output$params_bed_occupancy_day_night <- gt::render_gt({
      p <- params_data()

      p[["bed_occupancy"]][["day+night"]] |>
        shiny::req() |>
        dplyr::bind_rows(.id = "ward_group") |>
        dplyr::mutate(
          dplyr::across(
            "ward_group",
            \(.x) {
              .x |>
                forcats::fct_relevel(sort(.x)) |>
                forcats::fct_relevel("Other", after = Inf)
            }
          )
        ) |>
        dplyr::arrange(.data[["ward_group"]]) |>
        dplyr::mutate(
          dplyr::across(
            "ward_group",
            as.character
          )
        ) |>
        gt::gt("ward_group") |>
        gt::fmt_percent(c("lo", "hi")) |>
        gt_theme()
    })

    output$params_bed_occupancy_specialty_mapping <- gt::render_gt({
      p <- params_data()

      p[["bed_occupancy"]][["specialty_mapping"]] |>
        shiny::req() |>
        purrr::map(unlist) |>
        purrr::map(tibble::enframe, "specialty", "ward_group") |>
        dplyr::bind_rows(.id = "specialty_group") |>
        fix_data() |>
        gt::gt("specialty_name", "specialty_group") |>
        gt::cols_label("ward_group" = "Ward Group") |>
        gt_theme()
    })

    output$time_profile_waiting_list_adjustment <- shiny::renderText({
      params_data()[["time_profile_mappings"]][["waiting_list_adjustment"]]
    })

    output$time_profile_expat <- shiny::renderText({
      params_data()[["time_profile_mappings"]][["expat"]]
    })

    output$time_profile_repat_local <- shiny::renderText({
      params_data()[["time_profile_mappings"]][["repat_local"]]
    })

    output$time_profile_repat_nonlocal <- shiny::renderText({
      params_data()[["time_profile_mappings"]][["repat_nonlocal"]]
    })
  })
}
