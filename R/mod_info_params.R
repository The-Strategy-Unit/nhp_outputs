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
        "You can download a file of this information in the 'Downloads' tab."
      )
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
    params_data <- shiny::reactive({
      get_params(selected_data())
    })

    output$params_demographic_factors <- gt::render_gt({
      info_params_table_demographic_adjustment(params_data())
    })

    output$params_baseline_adjustment <- gt::render_gt({
      info_params_table_baseline_adjustment(params_data())
    })

    output$params_covid_adjustment <- gt::render_gt({
      info_params_table_covid_adjustment(params_data())
    })

    output$params_waiting_list_adjustment <- gt::render_gt({
      info_params_table_waiting_list_adjustment(params_data())
    })

    output$params_expat <- gt::render_gt({
      info_params_table_expat_repat_adjustment(params_data(), "expat")
    })

    output$params_repat_local <- gt::render_gt({
      info_params_table_expat_repat_adjustment(params_data(), "repat_local")
    })

    output$params_repat_nonlocal <- gt::render_gt({
      info_params_table_expat_repat_adjustment(params_data(), "repat_nonlocal")
    })

    output$params_non_demographic_adjustment <- gt::render_gt({
      info_params_table_non_demographic_adjustment(params_data())
    })

    output$params_activity_avoidance <- gt::render_gt({
      info_params_table_activity_avoidance(params_data())
    })

    output$params_efficiencies <- gt::render_gt({
      info_params_table_efficiencies(params_data())
    })

    output$params_bed_occupancy_day_night <- gt::render_gt({
      info_params_table_bed_occupancy_day_night(params_data())
    })

    output$params_bed_occupancy_specialty_mapping <- gt::render_gt({
      info_params_table_bed_occupancy_specialty_mapping(params_data())
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
