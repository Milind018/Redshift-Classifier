# Define the custom library path
custom_lib_path <- "~/Rlibs"

# Remove any existing lock files in the custom library path
lock_files <- list.files(custom_lib_path, pattern = "^00LOCK", full.names = TRUE)
if (length(lock_files) > 0) {
    sapply(lock_files, unlink, recursive = TRUE)
    cat("Removed lock files:\n")
    print(lock_files)
}

# Create the directory if it doesn't exist
if (!dir.exists(custom_lib_path)) {
    dir.create(custom_lib_path, recursive = TRUE)
}

# Set the library path
.libPaths(custom_lib_path)

# Get the list of all installed packages in the custom library path
installed_packages <- installed.packages(lib.loc = custom_lib_path)

# List of package names from the custom library path
custom_packages <- installed_packages[, "Package"]

# List of additional packages to install
new_packages <- c(
    "ggplot2", "gplots", "SuperLearner", "foreach", "parallel", "doParallel",
    "plyr", "party", "ROCR", "pROC", "abind", "caret", "glmnet", "e1071",
    "GGally", "arm", "kernlab", "ranger"
    #"SuperLearner", "unbalanced"  # Add any other packages you need here
)

# Combine all packages (custom + new)
packages <- unique(c(custom_packages, new_packages))

# Install and load packages in the custom library path if not already present
for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, lib.loc = custom_lib_path)) {
        # Attempt to install the package from CRAN
        tryCatch({
            install.packages(pkg, lib = custom_lib_path)
            library(pkg, character.only = TRUE, lib.loc = custom_lib_path)
            cat(paste("Installed and loaded package from CRAN in custom library:", pkg, "\n"))
        }, error = function(e) {
            # If CRAN installation fails, try to install from the CRAN archive
            cat(paste("Package", pkg, "not available on CRAN. Trying CRAN archive...\n"))
            tryCatch({
                # Assuming you know the archived version URL
                archived_version_url <- paste0("https://cran.r-project.org/src/contrib/Archive/", pkg, "/", pkg, "_0.6.tar.gz")
                install.packages(archived_version_url, repos = NULL, type = "source", lib = custom_lib_path)
                library(pkg, character.only = TRUE, lib.loc = custom_lib_path)
                cat(paste("Installed and loaded package from CRAN archive in custom library:", pkg, "\n"))
            }, error = function(e) {
                cat(paste("Failed to install package", pkg, "from both CRAN and CRAN archive.\n"))
            })
        })
    } else {
        cat(paste("Package already present in custom library and loaded:", pkg, "\n"))
    }
}

# Install 'randomForest' from R-Forge
if (!requireNamespace("randomForest", quietly = TRUE)) {
    install.packages("randomForest", repos="http://R-Forge.R-project.org")
}

# Install 'devtools' if not already installed
if (!requireNamespace("devtools", quietly = TRUE)) {
    install.packages("devtools")
}

# Install 'xgboost' from the CRAN archive
if (!requireNamespace("xgboost", quietly = TRUE)) {
    install.packages("https://cran.r-project.org/src/contrib/Archive/xgboost/xgboost_0.90.0.1.tar.gz", repos = NULL, type = "source")
}

## Install 'kernlab' and 'ranger' from the CRAN archive if needed
#if (!requireNamespace("kernlab", quietly = TRUE)) {
#    install.packages("https://cran.r-project.org/src/contrib/Archive/kernlab/kernlab_0.9-29.tar.gz", repos = NULL, type = "source")
#}
#if (!requireNamespace("ranger", quietly = TRUE)) {
#    install.packages("https://cran.r-project.org/src/contrib/Archive/ranger/ranger_0.11.2.tar.gz", repos = NULL, type = "source")
#}

# Install packages from GitHub if not already present
if (!requireNamespace("kernelKnn", quietly = TRUE)) {
    devtools::install_github("mlampros/kernelKnn")
}
if (!requireNamespace("biglasso", quietly = TRUE)) {
    devtools::install_github("YaohuiZeng/biglasso")
}

# Confirm the library path
print(.libPaths())
