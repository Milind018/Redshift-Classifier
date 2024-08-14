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

# Get the list of all installed packages in the default library
installed_packages <- installed.packages(lib.loc = .libPaths()[2])

# List of package names from the default library
default_packages <- installed_packages[, "Package"]

# List of additional packages to install
new_packages <- c(
    "ggplot2", "gplots", "SuperLearner", "foreach", "parallel", "doParallel",
    "plyr", "party", "ROCR", "pROC", "abind", "caret", "glmnet", "e1071",
    "GGally"
    #"SuperLearner", "unbalanced"  # Add any other packages you need here
)

# Combine all packages (default + new)
packages <- unique(c(default_packages, new_packages))

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
                # Assuming you know the archived version URL, e.g., for the package `unbalanced`
                # You can update the URL based on the package and version needed
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

# Confirm the library path
print(.libPaths())
