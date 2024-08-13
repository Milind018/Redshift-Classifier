# Set the custom library path
custom_lib_path <- "~/Rlibs"

# Create the directory if it doesn't exist
if (!dir.exists(custom_lib_path)) {
    dir.create(custom_lib_path, recursive = TRUE)
}

# Set the library path
.libPaths(custom_lib_path)

# Install the packages to the specified path
install.packages("ggplot2", lib = custom_lib_path)
install.packages("SuperLearner", lib = custom_lib_path)

# Load the packages
library(ggplot2)
library(SuperLearner)

# Confirm the packages are loaded from the custom path
print(.libPaths())
