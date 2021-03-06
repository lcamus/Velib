
# ---
# actualise les infos m�t�o (pr�cipitations, temp�rature en fonction de l'heure souhait�e)
# dt : l'heure souhait�e
# mode : d�finit la profondeur d'acc�s aux donn�es m�t�o ("day" : toute la journ�e, "time" : ponctuelle)
# ---
# renvoit un data frame avec la pr�cipitation et la temp�rature (et fixe les m�mes infos en variable globale)
# ---
getMeteo <- function(dt,mode) {
  
# message(dt)
# message(mode)
  #r�cup�ration de la m�t�o disponible
  res <- tryCatch(
    # tm <- get_current_forecast(as.numeric(getLat(geoParis)),
    #                            as.numeric(getLon(geoParis)),
    #                            dt,
    #                            units="si",language = "fr"),
    tm <- get_forecast_for(as.numeric(getLat(geoParis)),
                               as.numeric(getLon(geoParis)),
                               dt,
                               units="si",language = "fr"),
    error=function(e) {
      message("erreur dans l'acc�s � l'API m�t�o")
      return(NA)
    },
    warning=function(w) {message("alerte dans l'acc�s � l'API m�t�o")}
  )
  
  if (all(is.na(res))) meteo <- NA
  else {
    if (missing(mode) || mode=="time") {
      #filtrage sur l'heure courante ainsi que sur les deux premi�res heures disponibles
      v <- c("time","precipIntensity","temperature")
      meteo <- data.frame()
      meteo <- rbind.data.frame(meteo, as.data.frame(tm$currently[,v]))
      meteo <- rbind.data.frame(meteo, as.data.frame(tm$hourly[1,v]))
      meteo <- rbind.data.frame(meteo, as.data.frame(tm$hourly[2,v]))
      
      #on retient la m�t�o la plus proche de l'heure souhait�e  
      meteo0 <- meteo[which.min(difftime(meteo$time,as.POSIXct(dt, origin="1970-01-01"))),]
      
      #fixe variables globales
      meteoPrecipitations <<- ifelse(all(is.na(meteo0)),NA,meteo$precipIntensity)
      meteoTemperature <<- ifelse(all(is.na(meteo0)),NA,meteo$temperature)
      
      return(meteo)
    }
    else { #mode full
     return(tm) 
    }
  }

}


# #renvoit la temp�rature d'un objet m�t�o
# getTemp <- function(meteo) {
#   return(meteo[1])
# }
# 
# 
# #renvoit les pr�cipitations d'un objet m�t�o
# getPrecip <- function(meteo) {
#   return(meteo[2])
# }
