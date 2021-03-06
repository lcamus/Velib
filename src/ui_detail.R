tabPanel("d�tail", icon=icon("info-circle"),
         
         h2("Stations s�lectionn�es"),
         tableOutput(outputId = "stationsSelect"),
         
         # h2("Distance g�o entre stations s�lectionn�es"),
         # textOutput(outputId = "distanceGeoStationsSelect"),
         
         h2("Stations proches des stations s�lectionn�es"),
         fluidRow(
           column(width=12,
                  radioButtons("choixStationDepartArrivee", "Station :",
                               c("d�part" = "from", "arriv�e" = "to"),
                               inline = T)
           )
         ),
         tableOutput(outputId = "stationsProches")
)