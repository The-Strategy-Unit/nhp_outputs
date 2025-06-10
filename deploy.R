files <- c(
  dir(".", "*.R"),
  dir(".", "*.yml"),
  dir(".", "*.json"),
  dir(".", "*.Rds"),
  dir(".", "*.md")
)

files <- files[!files == "deploy.R"]

rsconnect::deployApp(
  server = "connect.strategunitwm.nhs.uk",
  appId = 212,
  appFiles = files
)

rsconnect::deployApp(
  server = "connect.su.mlcsu.org",
  appId = 128,
  appFiles = files
)
