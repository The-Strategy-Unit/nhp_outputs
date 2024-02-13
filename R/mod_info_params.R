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
      title = "Years",
      collapsed = TRUE,
      width = 12,
      shiny::tableOutput(ns("params_years"))
    ),
    bs4Dash::box(
      title = "Demographic factors",
      collapsed = TRUE,
      width = 12,
      shiny::tableOutput(ns("params_demographic_factors"))
    ),
    bs4Dash::box(
      title = "Baseline adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_baseline_adjustment_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_baseline_adjustment_op")),
      shiny::p("A&E"),
      shiny::tableOutput(ns("params_baseline_adjustment_aae"))
    ),
    bs4Dash::box(
      title = "Covid adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_covid_adjustment_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_covid_adjustment_op")),
      shiny::p("A&E"),
      shiny::tableOutput(ns("params_covid_adjustment_aae"))
    ),
    bs4Dash::box(
      title = "Waiting list adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_waiting_list_adjustment_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_waiting_list_adjustment_op"))
    ),
    bs4Dash::box(
      title = "Expatriation",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_expat_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_expat_op")),
      shiny::p("A&E"),
      shiny::tableOutput(ns("params_expat_aae"))
    ),
    bs4Dash::box(
      title = "Repatriation (local)",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_repat_local_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_repat_local_op")),
      shiny::p("A&E"),
      shiny::tableOutput(ns("params_repat_local_aae"))
    ),
    bs4Dash::box(
      title = "Repatriation (non-local)",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_repat_nonlocal_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_repat_nonlocal_op")),
      shiny::p("A&E"),
      shiny::tableOutput(ns("params_repat_nonlocal_aae"))
    ),
    bs4Dash::box(
      title = "Non-demographic adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_non_demographic_adjustment_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_non_demographic_adjustment_op")),
      shiny::p("A&E"),
      shiny::tableOutput(ns("params_non_demographic_adjustment_aae"))
    ),
    bs4Dash::box(
      title = "Activity avoidance",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_activity_avoidance_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_activity_avoidance_op")),
      shiny::p("A&E"),
      shiny::tableOutput(ns("params_activity_avoidance_aae"))
    ),
    bs4Dash::box(
      title = "Efficiencies",
      collapsed = TRUE,
      width = 12,
      shiny::p("Inpatients"),
      shiny::tableOutput(ns("params_efficiencies_ip")),
      shiny::p("Outpatients"),
      shiny::tableOutput(ns("params_efficiencies_op"))
    ),
    bs4Dash::box(
      title = "Bed occupancy",
      collapsed = TRUE,
      width = 12,
      shiny::p("Day and night"),
      shiny::tableOutput(ns("params_bed_occupancy_day_night")),
      shiny::p("Specialty mapping"),
      shiny::tableOutput(ns("params_bed_occupancy_specialty_mapping"))
    ),
    bs4Dash::box(
      title = "Time profile mappings",
      collapsed = TRUE,
      width = 12,
      shiny::p("Activity avoidance"),
      shiny::tableOutput(ns("params_time_profile_mappings_activity_avoidance")),
      shiny::p("Efficiencies"),
      shiny::tableOutput(ns("params_time_profile_mappings_efficiencies")),
      shiny::p("Others"),
      shiny::tableOutput(ns("params_time_profile_mappings_others"))
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

    output$params_years <- shiny::renderTable({
      params_data()[["years"]]
    })

    output$params_demographic_factors <- shiny::renderTable({
      params_data()[["demographic_factors"]]
    })

    output$params_baseline_adjustment_ip <- shiny::renderTable({
      params_data()[["baseline_adjustment"]][["ip"]]
    })
    output$params_baseline_adjustment_op <- shiny::renderTable({
      params_data()[["baseline_adjustment"]][["op"]]
    })
    output$params_baseline_adjustment_aae <- shiny::renderTable({
      params_data()[["baseline_adjustment"]][["aae"]]
    })

    output$params_covid_adjustment_ip <- shiny::renderTable({
      params_data()[["covid_adjustment"]][["ip"]]
    })
    output$params_covid_adjustment_op <- shiny::renderTable({
      params_data()[["covid_adjustment"]][["op"]]
    })
    output$params_covid_adjustment_aae <- shiny::renderTable({
      params_data()[["covid_adjustment"]][["aae"]]
    })

    output$params_waiting_list_adjustment_ip <- shiny::renderTable({
      params_data()[["waiting_list_adjustment"]][["ip"]]
    })
    output$params_waiting_list_adjustment_op <- shiny::renderTable({
      params_data()[["waiting_list_adjustment"]][["op"]]
    })

    output$params_expat_ip <- shiny::renderTable({
      params_data()[["expat"]][["ip"]]
    })
    output$params_expat_op <- shiny::renderTable({
      params_data()[["expat"]][["op"]]
    })
    output$params_expat_aae <- shiny::renderTable({
      params_data()[["expat"]][["aae"]]
    })

    output$params_repat_local_ip <- shiny::renderTable({
      params_data()[["repat_local"]][["ip"]]
    })
    output$params_repat_local_op <- shiny::renderTable({
      params_data()[["repat_local"]][["op"]]
    })
    output$params_repat_local_aae <- shiny::renderTable({
      params_data()[["repat_local"]][["aae"]]
    })

    output$params_repat_nonlocal_ip <- shiny::renderTable({
      params_data()[["repat_nonlocal"]][["ip"]]
    })
    output$params_repat_nonlocal_op <- shiny::renderTable({
      params_data()[["repat_nonlocal"]][["op"]]
    })
    output$params_repat_nonlocal_aae <- shiny::renderTable({
      params_data()[["repat_nonlocal"]][["aae"]]
    })

    output$params_non_demographic_adjustment_ip <- shiny::renderTable({
      params_data()[["non-demographic_adjustment"]][["ip"]]
    })
    output$params_non_demographic_adjustment_op <- shiny::renderTable({
      params_data()[["non-demographic_adjustment"]][["op"]]
    })
    output$params_non_demographic_adjustment_aae <- shiny::renderTable({
      params_data()[["non-demographic_adjustment"]][["aae"]]
    })

    output$params_activity_avoidance_ip <- shiny::renderTable({
      params_data()[["activity_avoidance"]][["ip"]]
    })
    output$params_activity_avoidance_op <- shiny::renderTable({
      params_data()[["activity_avoidance"]][["op"]]
    })
    output$params_activity_avoidance_aae <- shiny::renderTable({
      params_data()[["activity_avoidance"]][["aae"]]
    })

    output$params_efficiencies_ip <- shiny::renderTable({
      params_data()[["efficiencies"]][["ip"]]
    })
    output$params_efficiencies_op <- shiny::renderTable({
      params_data()[["efficiencies"]][["op"]]
    })

    output$params_bed_occupancy_day_night <- shiny::renderTable({
      params_data()[["bed_occupancy"]][["day+night"]]
    })
    output$params_bed_occupancy_specialty_mapping <- shiny::renderTable({
      params_data()[["bed_occupancy"]][["specialty_mapping"]]
    })

    output$params_time_profile_mappings_activity_avoidance <- shiny::renderTable({
      params_data()[["time_profile_mappings"]][["activity_avoidance"]]
    })
    output$params_time_profile_mappings_efficiencies <- shiny::renderTable({
      params_data()[["time_profile_mappings"]][["efficiencies "]]
    })
    output$params_time_profile_mappings_others <- shiny::renderTable({
      params_data()[["time_profile_mappings"]][["others"]]
    })
  })
}
