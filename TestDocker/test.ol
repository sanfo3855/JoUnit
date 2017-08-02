

include "InterfaceAPI.iol"
include "string_utils.iol"
include "console.iol"
//include "json_utils.iol"

outputPort DockerIn {
Location: "socket://localhost:8009"
Protocol: sodep
Interfaces: InterfaceAPI
}

main {
  println@Console("***** RETURN THE LIST OF ALL CONTAINER *****")();
	rq.all = true;
	containers@DockerIn(rq)(response);
	valueToPrettyString@StringUtils(response)(s);
  println@Console( s )()
}
