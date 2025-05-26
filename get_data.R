
# get_data.R
if (!dir.exists("data")) dir.create("data")
download.file(
  url      = "https://covid.ourworldindata.org/data/owid-covid-data.csv",
  destfile = "data/owid-covid-data.csv",
  mode     = "wb",
  method   = "libcurl"
)