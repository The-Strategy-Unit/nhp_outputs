selection_app <- callr::r_bg(\() {
  app <- shiny::runApp(
    "results_selection_app",
    port = 9081
  )
  print(app)
})

cat("Results Selection App: http://127.0.0.1:9081\n")


watchr::watch_files_and_start_task(
  \() {
    try({
      app <- golem::run_dev()
      print(app)
    })
  },
  \() fs::dir_ls(path = c("R"), recurse = TRUE, glob = "*.R"),
  "inst/golem-config.yml",
  "DESCRIPTION",
  "dev/run_dev.R"
)
