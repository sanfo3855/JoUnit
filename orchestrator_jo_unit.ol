

include "public/interfaces/InterfaceAPI.iol"
include "__validator/public/interfaces/ValidatorInterface.iol"
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

outputPort Validator {
Interfaces: ValidatorInterface
}

execution { concurrent }

embedded {
  Jolie: "__validator/main_validator.ol" in Validator
}

init{
  if(#args == 0){
    println@Console("Cannot start test without a repo...\n Usage: orchestrator_jo_unit.ol <repo>")( );
    halt@Runtime( )( )
  } else {
    parseIniFile@IniUtils( "config.ini" )( iniParsed );
    repo = args[0];
    repo.regex="/";
    split@StringUtils( repo )( repoSpl );
    repoName = repoSpl.result[#repoSpl.result-1];
    //repoName = args[1];
    println@Console( repoName )();
    println@Console("\n------------ "+ repo + " ------------")();

    validate@Validator( )( response );
    println@Console( response )();

    file.filename = "Dockerfile";
    file.content = ""+
      "FROM jolielang/testdeployer\n"+
      "WORKDIR /tempfile\n"+
      "RUN git clone "+ repo +" && cp -R /tempfile/"+ repoName +"/* /microservice && rm -r /tempfile\n"+
      "WORKDIR /microservice\n"+
      "RUN jolie /JolieTestSuite/__clients_generator/generate_clients.ol main.ol ./test_suite/ yes & jolie /JolieTestSuite/__metadata_tools/getDependenciesPort.ol main.ol\n"+
      "ENV ODEP_LOCATION=" + iniParsed.Locations[0].OrchestratorLocation[0];
    splitRq = iniParsed.Dependencies[0].nameService[0];
    splitRq.regex = ",";
    split@StringUtils( splitRq )( dependencies );
    for ( i = 0, i <= #dependencies, i++ ) {
      file.content = file.content + "\n" +
        "ENV JDEP_DEPSERVICE_"+ i + "=" + dependencies.result[i]
    };
    foreach ( child : iniParsed.ExternalVariables[0] ) {
      file.content = file.content + "\n" +
      "ENV " + child + "=" + iniParsed.ExternalVariables[0].( child )
    };

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
    if( request == " SUCCESS: init" || request == " TEST FAILED: init" ){
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
      halt@Runtime( )( )
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
