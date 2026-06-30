shiny::devmode()

selection_app <- callr::r_bg(\() {
  app <- shiny::runApp(
    "results_selection_app",
    port = 9081
  )
  print(app)
})

cat("Results Selection App: http://127.0.0.1:9081\n")

shiny::runApp()
