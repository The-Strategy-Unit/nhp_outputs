deploy <- function(server, app_id) {
  if (!file.exists("deploy.R") && dir.exists("results_selection_app")) {
    withr::local_dir("results_selection_app")
  }
  stopifnot(
    "Need to run inside the results_selection_app folder" = file.exists(
      "deploy.R"
    )
  )

  files <- c(
    dir(".", "*.R"),
    dir(".", "*.yml"),
    dir(".", "*.json"),
    dir(".", "*.Rds"),
    dir(".", "*.md")
  )

  files <- files[!files == "deploy.R"]

  withr::local_envvar(
    R_CONFIG_ACTIVE = "production"
  )

  rsconnect::deployApp(
    appId = app_id,
    server = server,
    appFiles = files,
    appName = "nhp-outputs_selection",
    appTitle = "NHP: Outputs Selection",
    envVars = c(
      "R_CONFIG_ACTIVE"
    )
  )
}

deploy(
  server = "connect.strategyunitwm.nhs.uk",
  app_id = 212
)

deploy(
  server = "connect.su.mlcsu.org",
  app_id = 128
)
