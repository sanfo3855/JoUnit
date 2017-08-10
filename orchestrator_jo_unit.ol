

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

inputPort OrchestratorIn {
Location: "auto:ini:/Locations/OrchestratorLocation:file:config.ini"
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

  /* Variables for creating a running testing container */
  rqImg.t = "jounit:latest";
  rqCnt.name = "jounit-1";
  rqCnt.Image = "jounit";
  psCnt.filters.name = rqCnt.name;
  psCnt.filters.status = "exited";
  crq.id = rqCnt.name;


  /* Build New Container Image from Dockerfile */
  build@Jocker( rqImg )( response );
  println@Console( "*********** IMAGE CREATED: "+ rqImg.t + " **********" )( );
  /* Create Container */
  createContainer@Jocker( rqCnt )( response );
  println@Console( "*********** CONTAINER CREATED: "+ rqCnt.name +" **********" )( );
  /* Run Container */
  startContainer@Jocker( crq )( response );
  println@Console( "*********** CONTAINER STARTED: "+ crq.id + " **********" )( )
}

main {
  [println ( request )( response ){
    println@Console( request )( )
  }]{
    if( request == "SUCCESS: init" ){
      /* Variables for clearing testing Container and Image */
      rmCnt.id = "jounit-1";
      rmImg.name = "jounit";
      /* Stop testing Container */
      stopContainer@Jocker( rmCnt )( response );
      println@Console( "*********** CONTAINER STOPPED: "+ rmCnt.id + " **********" )();
      /* Remove testing Container */
      removeContainer@Jocker( rmCnt )( response );
      println@Console( "*********** CONTAINER REMOVED: "+ rmCnt.id + " **********" )();
      /* Remove testing Image*/
      removeImage@Jocker( rmImg )( response );
      println@Console( "*********** IMAGE REMOVED: "+ rmCnt.id + " **********" )()
    }
  }

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
