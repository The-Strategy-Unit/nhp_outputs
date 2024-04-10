withr::with_dir(
  "results_selection_app",
  {
    fn <- \() {
      source("app.R")
      print(app)
    }

    results_selection_app <- callr::r_bg(fn)
  }
)
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
