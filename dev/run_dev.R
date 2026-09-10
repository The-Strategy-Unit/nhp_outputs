# need to call this for VS Code debugger to work
readRenviron(".Renviron")

options(golem.app.prod = FALSE)
golem::detach_all_attached()
golem::document_and_reload(export_all = TRUE)

# Patch the package namespace directly (rather than chaining
# mockery::stub() calls through run_app(), which doesn't compose when
# stubbing more than one target function -- each call narrows
# environment(run_app) down to just the previous stub) so the app skips
# the real model-run lookup (which expects a `?dataset/model_run_id` query
# string and Azure Table Storage access) and loads results from the local
# sample directory instead of Azure.
ns <- asNamespace("outputs")

utils::assignInNamespace(
  "get_model_run",
  function(...) list(aggregated_results_path = "inst/sample_results"),
  ns = ns
)

utils::assignInNamespace(
  "get_results_from_azure",
  function(...) get_results_from_local("inst/sample_results"),
  ns = ns
)

# need to explicitly print for VS Code debugger to work
app <- run_app()
print(app)
