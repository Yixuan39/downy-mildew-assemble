# Shared with workflow scripts through exported environment variables.
project_path <- function(...) {
  file.path(path.expand(Sys.getenv("PROJECT_DATA", "~/project_data/downy")), ...)
}

db_path <- function(...) {
  file.path(path.expand(Sys.getenv("DB_ROOT", "~/db")), ...)
}
