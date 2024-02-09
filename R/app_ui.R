#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @noRd
app_ui <- function(request) {
  header <- bs4Dash::dashboardHeader(title = "NHP Model Results")

  sidebar <- bs4Dash::dashboardSidebar(
    fixed = TRUE,
    skin = "light",
    status = "primary",
    bs4Dash::sidebarMenu(
      id = "sidebarMenu",
      bs4Dash::menuItem(
        "Home",
        tabName = "tab_home",
        icon = shiny::icon("home")
      ),
      bs4Dash::menuItem(
        "Principal projection",
        startExpanded = FALSE,
        bs4Dash::menuSubItem(
          text = "Summary",
          tabName = "tab_ps"
        ),
        bs4Dash::menuSubItem(
          text = "Summary by year",
          tabName = "tab_phl"
        ),
        bs4Dash::menuSubItem(
          text = "Activity in detail",
          tabName = "tab_pd"
        ),
        bs4Dash::menuSubItem(
          text = "Impact of changes",
          tabName = "tab_pcf"
        )
      ),
      bs4Dash::menuItem(
        "Distribution of projections",
        startExpanded = FALSE,
        bs4Dash::menuSubItem(
          text = "Activity summary",
          tabName = "tab_mc"
        ),
        bs4Dash::menuSubItem(
          text = "Activity distribution",
          tabName = "tab_md"
        )
      ),
      bs4Dash::menuItem(
        "Information",
        startExpanded = FALSE,
        bs4Dash::menuSubItem(
          text = "Input parameters",
          tabName = "tab_params"
        )
      )
    )
  )

  body <- bs4Dash::dashboardBody(
    bs4Dash::tabItems(
      bs4Dash::tabItem(
        tabName = "tab_home",
        mod_result_selection_ui("result_selection")
      ),
      bs4Dash::tabItem(
        tabName = "tab_ps",
        mod_principal_summary_ui("principal_summary")
      ),
      bs4Dash::tabItem(
        tabName = "tab_phl",
        mod_principal_high_level_ui("principal_high_level")
      ),
      bs4Dash::tabItem(
        tabName = "tab_pd",
        mod_principal_detailed_ui("principal_detailed")
      ),
      bs4Dash::tabItem(
        tabName = "tab_pcf",
        mod_principal_change_factor_effects_ui("principal_change_factor_effects")
      ),
      bs4Dash::tabItem(
        tabName = "tab_mc",
        mod_model_core_activity_ui("model_core_activity")
      ),
      bs4Dash::tabItem(
        tabName = "tab_md",
        mod_model_results_distribution_ui("model_results_distribution")
      ),
      bs4Dash::tabItem(
        tabName = "tab_params",
        mod_info_params_ui("info_params")
      )
    )
  )

  shiny::tagList(
    golem_add_external_resources(),
    shinyjs::useShinyjs(),
    bs4Dash::dashboardPage(
      help = NULL,
      header,
      sidebar,
      body
    )
  )
}
#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  golem::add_resource_path(
    "www", app_sys("app/www")
  )

  htmltools::tags$head(
    golem::favicon(),
    golem::bundle_resources(
      path = app_sys("app/www"),
      app_title = "outputs"
    )
  )
}
