# Define the custom library path
custom_lib_path <- "~/Rlibs"

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
    "ggplot2", "gplots", "SuperLearner", "foreach", "parallel", "doParallel", "unbalanced",
    "plyr", "party", "ROCR", "pROC", "rbind", "cbind", "abind", "caret", "glmnet", "e1071",
    "GGally"
    #"SuperLearner"
)

# Combine all packages (default + new)
packages <- unique(c(default_packages, new_packages))

# Install and load packages in the custom library path if not already present
for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, lib.loc = custom_lib_path)) {
        install.packages(pkg, lib = custom_lib_path)
        library(pkg, character.only = TRUE, lib.loc = custom_lib_path)
        cat(paste("Installed and loaded package in custom library:", pkg, "\n"))
    } else {
        cat(paste("Package already present in custom library and loaded:", pkg, "\n"))
    }
}

# Confirm the library path
print(.libPaths())
