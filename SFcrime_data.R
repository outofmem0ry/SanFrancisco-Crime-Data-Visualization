library(sqldf)
library(devtools)
library(rCharts)
library(ggplot2)
library(ggmap)

sfcrimedata = read.csv("SFPD_Incidents_-_Previous_Three_Months.csv")
sfcrimedata = sfcrimedata[,-1]
sfcrimedata$Date = as.Date(sfcrimedata$Date,format="%m/%d/%Y")
sfcrimedata$Location = gsub("[()]","",sfcrimedata$Location)

## Where shouldn't you park your car?
unique(sfcrimedata$Category)
vehicleTheft = sqldf("SELECT * FROM sfcrimedata where Category = \"VEHICLE THEFT\" ")
vehicleTheft$Location = paste(vehicleTheft$Y,vehicleTheft$X,sep=":")

sanF <- get_map("san francisco", zoom = 12,source="osm")
sanFMap <- ggmap(sanF, extent = "device", legend = "topleft")


overlay <- stat_density2d(
  aes(x = X, y = Y, fill = ..level..),alpha = 0.2,
  bins = 4, geom = "polygon",
  data = vehicleTheft,contour=TRUE
)

scale <- scale_fill_gradient(low = "black", high = "red")

sanFMap+overlay+scale


####### - Are certain thefts more common in certain areas?##
sanF <- get_map("san francisco", zoom = 12,scale=4,source="google")
Theft = sqldf("SELECT * FROM sfcrimedata where Category like \"%THEFT%\" ")
sanFMap <-  ggmap(sanF, base_layer = ggplot(aes(x = X, y = Y),
                                            data = Theft))

sanFMap+overlay+scale+facet_wrap(~ DayOfWeek)

