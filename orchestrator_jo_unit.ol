

include "public/interfaces/InterfaceAPI.iol"
include "ini_utils.iol"
include "console.iol"

outputPort DockerOut {
Location: "auto:ini:/Locations/JockerLocation:file:config.ini"
Protocol: sodep
Interfaces: InterfaceAPI
}

execution { single }

main{
  println@Console( "Non faccio niente" )()
}
