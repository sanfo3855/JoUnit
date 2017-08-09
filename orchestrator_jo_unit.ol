

include "public/interfaces/InterfaceAPI.iol"
include "ini_utils.iol"
include "console.iol"
include "file.iol"
include "string_utils.iol"

outputPort Jocker {
Location: "auto:ini:/Locations/JockerLocation:file:config.ini"
Protocol: sodep
Interfaces: InterfaceAPI
}

inputPort PortName {
Location: "socket://172.17.0.1:10000" //sostituire con la prima porta disponibile in automatico
Protocol: sodep
RequestResponse:
  println( string )( void ),
  subscribeSessionListener( string )( void ),
  enableTimestamp( bool )( void ),
  registerForInput( bool )( void ),
  print( string )( void),
  unsubscribeSessionListener( string )( void )
}

execution { concurrent }

init{
  file.filename = "TestJoEC.tar"; //sostitire con path del Tar da usare
  file.format = "binary";
  readFile@File( file )( rqImg.file );
  rqImg.t = "test-joec:latest";
  rqCnt.name = "test-joec-1";
  rqCnt.Image = "test-joec";
  psCnt.filters.name = rqCnt.name;
  psCnt.filters.status = "exited";
  rmCnt.id = rqCnt.name;
  crq.id = rqCnt.name;

  /* Build Container Image from Dockerfile */
  build@Jocker( rqImg )( response );
  println@Console( "*********** CREATED IMAGE "+ rqImg.t + " **********" )( );
  /* Check if Container already exists */
  containers@Jocker( psCnt )( response );
  if( response.container[0].Names[0] == "/" + rqCnt.name ) {
    removeContainer@Jocker( rmCnt )( response );
    println@Console( "*********** REMOVED "+ rmCnt.id + " **********" )( )
  };
  /* Create Container */
  createContainer@Jocker( rqCnt )( response );
  println@Console( "*********** CREATED CONTAINER "+ rqCnt.name +" **********" )( );
  /* Run Container */
  startContainer@Jocker( crq )( response );
  println@Console( "*********** STARTED "+ crq.id + " **********" )( )
}

main {
  [println ( request )( response ){
    println@Console( request )( response )
  }]

  [subscribeSessionListener( request )( response ) {
    subscribeSessionListener@Console( request )( response )
  }]

  [enableTimestamp( request )( response ){
    enableTimestamp@Console( request )( response )
  }]

  [registerForInput( request )( response ){
    registerForInput@Console( request )( response )
  }]

  [print( request )( response ){
    print@Console( request )( response )
  }]

  [unsubscribeSessionListener( request )( response ){
    unsubscribeSessionListener@Console( request )( response )
  }]
}
