# Define the custom library path
custom_lib_path <- "~/Rlibs"

# Create the directory if it doesn't exist
if (!dir.exists(custom_lib_path)) {
    dir.create(custom_lib_path, recursive = TRUE)
}

# Set the library path
.libPaths(custom_lib_path)

# List of packages to install
packages <- c(
    "abind", "arm", "backports", "base64enc", "BH", "biglasso", 
    "biglm", "bigmemory", "bigmemory.sri", "bit", "bit64", 
    "bitops", "boot", "broom", "broom.helpers", "bslib", "cachem", 
    "car", "carData", "caret", "caTools", "class", "cli", "clipr", 
    "clock", "cluster", "coda", "codetools", "coin", "colorspace", 
    "compiler", "cowplot", "cpp11", "crayon", "cvAUC", "data.table", 
    "datasets", "DBI", "deldir", "DEoptimR", "Deriv", "dgof", 
    "diagram", "digest", "doBy", "doParallel", "dplyr", "e1071", 
    "earth", "evaluate", "fansi", "farver", "fastmap", "fontawesome", 
    "forcats", "foreach", "foreign", "Formula", "fs", "future", 
    "future.apply", "gam", "gbm", "generics", "GGally", "ggplot2", 
    "ggstats", "glmnet", "globals", "glue", "gower", "gplots", 
    "graphics", "grDevices", "grid", "gtable", "gtools", "hardhat", 
    "haven", "highr", "hms", "htmltools", "interp", "ipred", 
    "isoband", "iterators", "jomo", "jpeg", "jquerylib", "jsonlite", 
    "KernelKnn", "kernlab", "KernSmooth", "knitr", "kSamples", 
    "labeling", "labelled", "laeken", "lattice", "latticeExtra", 
    "lava", "libcoin", "lifecycle", "listenv", "lme4", "lmtest", 
    "lubridate", "magrittr", "MASS", "Matrix", "MatrixModels", 
    "matrixStats", "memoise", "methods", "mgcv", "mice", 
    "microbenchmark", "mime", "minqa", "mitml", "ModelMetrics", 
    "modelr", "modeltools", "multcomp", "munsell", "mvtnorm", 
    "ncvreg", "nlme", "nloptr", "nnet", "nnls", "numDeriv", 
    "ordinal", "pan", "parallel", "parallelly", "party", "patchwork", 
    "pbkrtest", "pillar", "pkgconfig", "plotmo", "plotrix", 
    "plyr", "png", "prettyunits", "pROC", "prodlim", "progress", 
    "progressr", "proxy", "purrr", "quantreg", "R6", "randomForest", 
    "ranger", "rappdirs", "RColorBrewer", "Rcpp", "RcppArmadillo", 
    "RcppEigen", "readr", "recipes", "reshape2", "rlang", 
    "rmarkdown", "robustbase", "ROCR", "rpart", "sandwich", 
    "sass", "scales", "shape", "sp", "SparseM", "spatial", 
    "speedglm", "splines", "SQUAREM", "stats", "stats4", "stringi", 
    "stringr", "strucchange", "SuperLearner", "SuppDists", 
    "survival", "tcltk", "TH.data", "tibble", "tidyr", 
    "tidyselect", "timechange", "timeDate", "tinytex", "tools", 
    "tzdb", "ucminf", "utf8", "utils", "uuid", "vcd", "vctrs", 
    "VIM", "viridisLite", "vroom", "withr", "xfun", "xgboost", 
    "yaml", "zoo"
)

# Install the packages to the specified path
install.packages(packages, lib = custom_lib_path)

# Load and confirm installation of each package
lapply(packages, function(pkg) {
    library(pkg, character.only = TRUE)
    cat(paste("Loaded package:", pkg, "\n"))
})

# Confirm the library path
print(.libPaths())
