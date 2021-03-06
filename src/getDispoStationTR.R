# renvoit la derni�re disponibilit� connue (temps r�el) des stations Velib
# entr�e : rien
# sortie : le dataframe contenant les donn�es
getDispoStationTR <- function() {

  DecauxKey <- "78b0313157762db775e02e176699871287378746"
  DecauxContractName <- "Paris"
  
  UrlDecaux <-  paste("https://api.jcdecaux.com/vls/v1/stations?contract=",DecauxContractName,"&apiKey=",DecauxKey,sep="")
  
  library(jsonlite)
  library(RCurl)
  library(curl)
  
  #r�cup�ration des donn�es temps r�el
  stations_dl <- jsonlite::fromJSON(UrlDecaux)
  
  #normalisation de la date
  stations_dl$last_update <- as.POSIXct(stations_dl$last_update, origin="1970-01-01")
  
  #suppression des variables inutiles
  stations_dl$name <- NULL
  stations_dl$address <- NULL
  stations_dl$bonus <- NULL
  
  return(stations_dl)
  
}
