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
      shiny::htmlOutput(ns("params_demographic_factors"))
    ),
    bs4Dash::box(
      title = "Baseline adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_baseline_adjustment"))
    ),
    bs4Dash::box(
      title = "Waiting list adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_waiting_list_adjustment"))
    ),
    bs4Dash::box(
      title = "Inequalities",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_inequalities"))
    ),
    bs4Dash::box(
      title = "Expatriation",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_expat"))
    ),
    bs4Dash::box(
      title = "Repatriation (local)",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_repat_local"))
    ),
    bs4Dash::box(
      title = "Repatriation (non-local)",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_repat_nonlocal"))
    ),
    bs4Dash::box(
      title = "Non-demographic adjustment",
      collapsed = TRUE,
      width = 12,
      shiny::tags$p(
        "Variant:",
        shiny::textOutput(
          ns("variant_non_demographic_adjustment"),
          inline = TRUE
        )
      ),
      shiny::tags$p(
        "Value type:",
        shiny::textOutput(
          ns("value_type_non_demographic_adjustment"),
          inline = TRUE
        )
      ),
      shiny::htmlOutput(ns("params_non_demographic_adjustment"))
    ),
    bs4Dash::box(
      title = "Activity avoidance",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_activity_avoidance"))
    ),
    bs4Dash::box(
      title = "Efficiencies",
      collapsed = TRUE,
      width = 12,
      shiny::htmlOutput(ns("params_efficiencies"))
    )
  )
}
