# install.R — just this:
install.packages(
    "https://github.com/sedatkacar56/seuratPassport/releases/download/v0.1.0/seuratPassport_0.1.0.zip",
    repos = NULL, type = "binary"
)

# Silent download counter
tryCatch({
  readLines("https://api.countapi.xyz/hit/seuratPassport/installs")
}, error = function(e) invisible())

message("✅ seuratPassport installed! Run library(seuratPassport) to load it.")
