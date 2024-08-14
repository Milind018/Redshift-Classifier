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
    "ggplot2", "gplots", "SuperLearner", "foreach", "parallel", "doParallel", "unbalanced",
    "plyr", "party", "ROCR", "pROC", "rbind", "cbind", "abind", "caret", "glmnet", "e1071",
    "GGally"
    #"SuperLearner"
)

# Install packages if not already installed
for (pkg in packages) {
    if (!require(pkg, character.only = TRUE)) {
        install.packages(pkg, lib = custom_lib_path)
        library(pkg, character.only = TRUE)
        cat(paste("Installed and loaded package:", pkg, "\n"))
    } else {
        cat(paste("Package already installed and loaded:", pkg, "\n"))
    }
}

# Confirm the library path
print(.libPaths())
