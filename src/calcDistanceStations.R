#### fonctions de calcul de matrice de distance g�o

require(Imap)

ReplaceLowerOrUpperTriangle <- function(m, triangle.to.replace){
  # If triangle.to.replace="lower", replaces the lower triangle of a square matrix with its upper triangle.
  # If triangle.to.replace="upper", replaces the upper triangle of a square matrix with its lower triangle.
  
  if (nrow(m) != ncol(m)) stop("Supplied matrix must be square.")
  if      (tolower(triangle.to.replace) == "lower") tri <- lower.tri(m)
  else if (tolower(triangle.to.replace) == "upper") tri <- upper.tri(m)
  else stop("triangle.to.replace must be set to 'lower' or 'upper'.")
  m[tri] <- t(m)[tri]
  return(m)
}

GeoDistanceInMetresMatrix <- function(df.geopoints){
  # Returns a matrix (M) of distances between geographic points.
  # M[i,j] = M[j,i] = Distance between (df.geopoints$lat[i], df.geopoints$lon[i]) and
  # (df.geopoints$lat[j], df.geopoints$lon[j]).
  # The row and column names are given by df.geopoints$name.
  
  GeoDistanceInMetres <- function(g1, g2){
    # Returns a vector of distances. (But if g1$index > g2$index, returns zero.)
    # The 1st value in the returned vector is the distance between g1[[1]] and g2[[1]].
    # The 2nd value in the returned vector is the distance between g1[[2]] and g2[[2]]. Etc.
    # Each g1[[x]] or g2[[x]] must be a list with named elements "index", "lat" and "lon".
    # E.g. g1 <- list(list("index"=1, "lat"=12.1, "lon"=10.1), list("index"=3, "lat"=12.1, "lon"=13.2))
    DistM <- function(g1, g2){
      require("Imap")
      return(ifelse(g1$index > g2$index, 0, gdist(lat.1=g1$lat, lon.1=g1$lon, lat.2=g2$lat, lon.2=g2$lon, units="m")))
    }
    return(mapply(DistM, g1, g2))
  }
  
  n.geopoints <- nrow(df.geopoints)
  
  # The index column is used to ensure we only do calculations for the upper triangle of points
  df.geopoints$index <- 1:n.geopoints
  
  # Create a list of lists
  list.geopoints <- by(df.geopoints[,c("index", "lat", "lon")], 1:n.geopoints, function(x){return(list(x))})
  
  # Get a matrix of distances (in metres)
  mat.distances <- ReplaceLowerOrUpperTriangle(outer(list.geopoints, list.geopoints, GeoDistanceInMetres), "lower")
  
  # Set the row and column names
  rownames(mat.distances) <- df.geopoints$name
  colnames(mat.distances) <- df.geopoints$name
  
  return(mat.distances)
}


#### calcul des stations les plus proches d'un point g�ographique
# entr�e :
# lat : latitude du point de r�f�rence
# lon : longitude du point de r�f�rence
# mode : mesure de proximit� ("classement" : les plus proches, "distance" : �loignement g�o en m�tres)
# n : facteur de proximit� des stations � retenir (n plus proches ou distantes de n m�tres)
# ---------
# sortie : vecteur des n stations les plus proches
####
getProchesStations <- function(lat, lon, mode, n) {
  v <- stations[stations$status=="OPEN",]
  #v$dist <- round(gdist(v$latitude, v$longitude, lat, lon, units="m"))
  v$dist <- apply(v[,c("latitude","longitude")],1,function(x) {round(gdist(x[1], x[2], lat, lon, units="m"))})
  if (mode=="classement") {
    v <- v[order(v$dist),]
    v <- v[seq(2,n+1),]
  } else if (mode=="distance") {
    v <- v[v$dist<n,]
    v <- tail(v[order(v$dist),],-1)
  }
  return(v)
}

#### distance g�o entre deux stations
# entr�e :
# s1, s2 : les deux stations identifi�es par leur num�ro
#-----
# sortie : la distance g�o entre les deux stations en km
#####
getDistanceGeoStations <- function(s1, s2) {
  d <- mDistanceStation[s1, s2]
  return(d)
}

#convertit une coordonn�e cha�ne en vecteur (lat,lon)
# "1.12,2.33" => ("1.12","2.33")
getLatLon <- function(geo) {
  return(setNames(strsplit(geo, split=",")[[1]],c("lat","lon")))
}

#renvoit la latitude d'une coordonn�e cha�ne
# "1.12,2.33" => 1.12
getLat <- function(geo) {
  return(as.numeric(strsplit(geo, split=",")[[1]][1]))
}  

#renvoit la longitude d'une coordonn�e cha�ne
# "1.12,2.33" => 2.33
getLon <- function(geo) {
  return(as.numeric(strsplit(geo, split=",")[[1]][2]))
}


