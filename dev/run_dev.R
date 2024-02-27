# need to call this for VS Code debugger to work
readRenviron(".Renviron")

options(golem.app.prod = FALSE)
golem::detach_all_attached()
golem::document_and_reload(export_all = TRUE)

mockery::stub(
  run_app,
  "server_get_results",
  depth = 2,
  \(...) get_results_from_local("inst/sample_results.json")
  # \(...) get_results_from_local(r"{C:\Users\Matt.Dray\Downloads\Leighton-v1-20240214_122450.json\Leighton-v1-20240214_122450.json}")
)

# need to explicitly print for VS Code debugger to work
app <- run_app()
print(app)
