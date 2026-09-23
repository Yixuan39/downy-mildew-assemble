code <- knitr::purl("analysis/read-distribution.Rmd", output = tempfile(fileext = ".R"), quiet = TRUE)
expressions <- parse(file = code)
definition <- Filter(function(x) is.call(x) && identical(x[[1]], as.name("<-")) &&
  identical(x[[2]], as.name("read_kreport")), expressions)
stopifnot(length(definition) == 1L)
eval(definition[[1]])

report_file <- tempfile(fileext = ".kreport")
writeLines(c(
  "10.00\t10\t10\tU\t0\tunclassified",
  "90.00\t90\t0\tR\t1\troot",
  "90.00\t90\t0\tD\t2\t  Bacteria",
  "60.00\t60\t0\tP\t1224\t    Pseudomonadota",
  "60.00\t60\t0\tG\t286\t      Pseudomonas",
  "60.00\t60\t60\tS\t287\t        P. aeruginosa",
  "30.00\t30\t0\tP\t976\t    Bacteroidota",
  "30.00\t30\t30\tS\t111\t      Species"
), report_file)
report <- read_kreport(report_file)
stopifnot(
  is.na(report$P[1]),
  identical(report$P[5:6], rep("p_Pseudomonadota", 2)),
  identical(report$P[7:8], rep("p_Bacteroidota", 2)),
  identical(report$percentage[c(4, 7)], c(60, 30))
)
unlink(c(code, report_file))
