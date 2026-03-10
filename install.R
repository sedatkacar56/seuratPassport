os <- Sys.info()["sysname"]

if (os == "Windows") {

  install.packages(
    "https://github.com/sedatkacar56/seuratPassport/releases/download/v0.1.0/seuratPassport_0.1.0.zip",
    repos = NULL,
    type  = "binary"
  )

} else {

  install.packages(
    "https://github.com/sedatkacar56/seuratPassport/releases/download/v0.1.0/seuratPassport_0.1.0.tar.gz",
    repos = NULL,
    type  = "source"
  )

}

# Silent install counter
tryCatch({
  download.file(
    "https://sedatkacar56.goatcounter.com/count?p=/seuratPassport-install",
    destfile = tempfile(),
    quiet = TRUE
  )
}, error = function(e) invisible())

message("✅ seuratPassport installed! Run library(seuratPassport)")
