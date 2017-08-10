

include "public/interfaces/InterfaceAPI.iol"
include "ini_utils.iol"
include "console.iol"
include "file.iol"
include "string_utils.iol"
include "exec.iol"
include "runtime.iol"

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
  if(#args == 0){
    println@Console("Cannot start test without a repo...\n Usage: orchestrator_jo_unit.ol <repo>")( )
  } else {
    repo = args[0];
    println@Console("\n------------ "+ repo + " ------------")();
    file.filename = "Dockerfile";
    file.content = ""+
      "FROM jolielang/testdeployer\n"+
      "WORKDIR /tempfile\n"+
      "RUN git clone "+ repo +" && cp -R /tempfile/JoEC/* /microservice && rm -r /tempfile\n"+
      "WORKDIR /microservice\n"+
      "RUN jolie /JolieTestSuite/__clients_generator/generate_clients.ol main.ol ./test_suite/ yes\n";
    writeFile@File( file )( );

    cmd = "tar -cf Test.tar Dockerfile";
    exec@Exec( cmd )( response );

    filet.filename = "Test.tar";
    filet.format = "binary";
    readFile@File( filet )( rqImg.file );

    cmd = "rm Dockerfile && rm Test.tar";
    exec@Exec( cmd )( response );

    /* Freshname for image and container */
    global.freshname = new;
    /* Variables for creating a running testing container */
    rqImg.t = global.freshname + ":latest";
    rqCnt.name = global.freshname + "-1";
    rqCnt.Image = global.freshname;
    psCnt.filters.name = rqCnt.name;
    psCnt.filters.status = "exited";
    crq.id = rqCnt.name;


    /* Build New Container Image from Dockerfile */
    build@Jocker( rqImg )( response );
    println@Console( "1/6 ---> IMAGE CREATED: "+ rqImg.t )( );
    /* Create Container */
    createContainer@Jocker( rqCnt )( response );
    println@Console( "2/6 ---> CONTAINER CREATED: "+ rqCnt.name )( );
    /* Run Container */
    startContainer@Jocker( crq )( response );
    println@Console( "3/6 ---> CONTAINER STARTED: "+ crq.id )( )
  }

}

main {
  [println ( request )( response ){
    println@Console( request )( )
  }]{
    if( request == " SUCCESS: init" ){
      /* Variables for clearing testing Container and Image */
      rmCnt.id = global.freshname + "-1";
      rmImg.name = global.freshname;
      /* Stop testing Container */
      stopContainer@Jocker( rmCnt )( response );
      println@Console( "4/6 ---> CONTAINER STOPPED: "+ rmCnt.id )();
      /* Remove testing Container */
      removeContainer@Jocker( rmCnt )( response );
      println@Console( "5/6 ---> CONTAINER REMOVED: "+ rmCnt.id )();
      /* Remove testing Image*/
      removeImage@Jocker( rmImg )( response );
      println@Console( "6/6 ---> IMAGE REMOVED: "+ rmCnt.id )();
      halt@Runtime()()
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
