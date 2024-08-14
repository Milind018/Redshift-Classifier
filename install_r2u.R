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
    #"ggplt2", "gplots", "SuperLearner", "foreach", "parallel", "doParallel", "unbalanced",
    #"plyr", "party", "ROCR", "pROC", "rbind", "cbind", "abind", "caret", "glmnet", "e1071",
    #"GGally"
    "SuperLearner"
)

# Install the packages to the specified path
install.packages(packages, lib = custom_lib_path, dependencies = TRUE)

# Load and confirm installation of each package
lapply(packages, function(pkg) {
    library(pkg, character.only = TRUE)
    cat(paste("Loaded package:", pkg, "\n"))
})

# Confirm the library path
print(.libPaths())
