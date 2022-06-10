# Launch the ShinyApp (Do not remove this comment)
setwd(here::here())
readRenviron(".Renviron")

options(
  "golem.app.prod" = FALSE,
  shiny.autoreload = TRUE,
  shiny.autoload.r = FALSE
)
pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
run_app() # add parameters here (if any)
