/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                                    *
* Copyright (C) 2017 Matteo Sanfelici <sanfelicimatteo@gmail.com>                    *
*                                                                                    *
* Permission is hereby granted, free of charge, to any person obtaining a copy of    *
* this software and associated documentation files (the "Software"), to deal in the  *
* Software without restriction, including without limitation the rights to use,      *
* copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the    *
* Software, and to permit persons to whom the Software is furnished to do so, subject*
* to the following conditions:                                                       *
*                                                                                    *
* The above copyright notice and this permission notice shall be included in all     *
* copies or substantial portions of the Software.                                    *
*                                                                                    *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,*
* INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A      *
* PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT *
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION  *
* OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     *
* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                             *
*                                                                                    *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

include "public/interfaces/InterfaceAPI.iol"
include "public/interfaces/orchestratorInterface.iol"
include "__validator/public/interfaces/ValidatorInterface.iol"
include "ini_utils.iol"
include "console.iol"
include "file.iol"
include "string_utils.iol"
include "exec.iol"
include "runtime.iol"
include "time.iol"

outputPort Jocker {
Location: "auto:ini:/Locations/JockerLocation:file:config.ini"
Protocol: sodep
Interfaces: InterfaceAPI
}

inputPort OrchestratorIn {
Location: "auto:ini:/Locations/OrchestratorLocation:file:config.ini"
Protocol: sodep
Interfaces: OrchestratorInterface
}

outputPort Validator {
Interfaces: ValidatorInterface
}

embedded {
  Jolie: "__validator/main_validator.ol" in Validator
}


execution { concurrent }

define __checkJocker {
  scope( checkJocker )
  {
    connectionAttempt++;
    install( IOException =>
      println@Console( "\nJOCKER !!Connection Refused!!\n\n"+
        "If you have a stopped jocker container yet\n" +
        "-->   sudo docker start <name jocker container>\n\n" +
        "To download Jocker container image from Dockerhub\n"+
        "-->   sudo docker pull jolielang/jocker\n\n" +
        "To run a new Jocekr container\n"+
        "-->   sudo docker run -d -v /var/run/docker.sock:/var/run/docker.sock -p <localPort>:8008 jolielang/jocker\n"
      )();
      halt@Runtime()()
    );
    containers@Jocker( )( response )

  }
}


init{
  // Parse configuration file
  parseIniFile@IniUtils( "config.ini" )( iniParsed );
  // Checking if JoUnit con reach JokerContainer;
  println@Console( "\nChecking if JOCKER is online..." )();
  __checkJocker;
  sleep@Time( 3000 )( );

  if(#args == 0){
    // error if args = 0 (there are no argument)
    println@Console("Cannot start test without a repo...\n Usage: orchestrator_jo_unit.ol <repo>")( );
    halt@Runtime( )( )
  } else {
    // in agrs[0] we have (local or online) address of the repo
    repo = args[0];
    repo.regex="/";
    split@StringUtils( repo )( repoSpl );
    // name repository
    repoName = repoSpl.result[#repoSpl.result-1];
    println@Console("\n############## "+ repo + " ##############")();
    // clone repository (local o online)
    println@Console( "GETTING Project Source..." )();
    cmd = "git clone " + repo + " ./tmp";
    cmd.stdOutConsoleEnable = true;
    exec@Exec( cmd )( response );

    cmd = "rm -rf ./tmp/.git/";
    exec@Exec( cmd )( response );

    /* validate@Validator( )( response );
    println@Console( response )(); */


    // Creating Dockerfile
    file.filename = "Dockerfile";
    file.content = ""+
      "FROM jolielang/unit-test-suite\n"+
      "WORKDIR /microservice\n"+
      "COPY ./tmp .\n"+
      // creating clients and depservice (if needed)
      /*"RUN jolie /JolieTestSuite/__clients_generator/generate_clients.ol main.ol ./test_suite/ yes & jolie /JolieTestSuite/__metadata_tools/getDependenciesPort.ol main.ol\n"+*/
      "ENV ODEP_LOCATION=" + iniParsed.Locations[0].OrchestratorLocation[0];
      /* reading ExternalVariables */
    foreach ( child : iniParsed.ExternalVariables[0] ) {
      file.content = file.content + "\n" +
      "ENV " + child + "=" + iniParsed.ExternalVariables[0].( child )
    };

    writeFile@File( file )( );

    // creating Test.tar with Dockerfile and context needed with
    // project source code ready for testing
    cmd = "tar -cf Test.tar Dockerfile tmp";
    exec@Exec( cmd )( response );

    filet.filename = "Test.tar";
    filet.format = "binary";
    readFile@File( filet )( rqImg.file );
    rqImf.filename = "Dockerfile";
    cmd = "rm Dockerfile && rm Test.tar && rm -rf tmp";
    exec@Exec( cmd )( response );

    // Freshname for image and container
    global.freshname = new;
    // Variables for creating a running testing container
    rqImg.t = global.freshname + ":latest";
    rqCnt.name = global.freshname + "-1";
    rqCnt.Image = global.freshname;
    psCnt.filters.name = rqCnt.name;
    psCnt.filters.status = "exited";
    crq.id = rqCnt.name;

    println@Console( "Connecting to JOCKER..." )( );
    scope( buildScope )
    {
      install( ServerError => println@Console("Fault Raised: ServerError  " + buildScope.ServerError.message)( ); halt@Runtime()() );
      install( BadParam => println@Console("Fault Raised: BadParam  " + buildScope.BadParam.message)( ); halt@Runtime()() );

      // Build New Container Image from Dockerfile
      build@Jocker( rqImg )( response );
      println@Console( "1/6 ---> IMAGE CREATED: "+ rqImg.t )( )
    };

    scope( createScope )
    {
      install( Conflict => println@Console("Fault Raised: Conflict  " + createScope.Conflict.message)( ); halt@Runtime()() );
      install( ServerError => println@Console("Fault Raised: ServerError  " + createScope.ServerError.message)( ); halt@Runtime()() );
      install( NoAttachment => println@Console("Fault Raised: NoAttachment  " + createScope.NoAttachment.message)( ); halt@Runtime()() );
      install( BadParam => println@Console("Fault Raised: BadParam  " + createScope.BadParam.message)( ); halt@Runtime()() );
      install( NoSuchImage => println@Console("Fault Raised: NoSuchImage  " + createScope.NoSuchImage.message)( ); halt@Runtime()() );

      // Create Container
      createContainer@Jocker( rqCnt )( response );
      println@Console( "2/6 ---> CONTAINER CREATED: "+ rqCnt.name )( )
    };

    scope( startScope ) {
      install( NoSuchContainer => println@Console("Fault Raised: NoSuchContainer  " + startScope.NoSuchContainer.message)( ); halt@Runtime()() );
      install( ServerError => println@Console("Fault Raised: ServerError  " + startScope.ServerError.message)( ); halt@Runtime()() );
      install( AlreadyStarted => println@Console("Fault Raised: AlreadyStarted  " + startScope.AlreadyStarted.message)( ); halt@Runtime()() );

      // Run Container
      startContainer@Jocker( crq )( response );
      println@Console( "3/6 ---> CONTAINER STARTED: "+ crq.id )( )
    }
  }

}

main {
  // Re-implementation of console.iol
  // orchestrator_jo_unit works like a console for unit-test containers and
  // it has to reimplement every operations of Console.iol
  [println ( request )( response ){
    println@Console( request )( )
  }]{
    if( request == " SUCCESS: init" || request == " TEST FAILED! : init" || request == "GoalNotFound: init"){
      // Variables for remove testing Container and Image
      rmCnt.id = global.freshname + "-1";
      rmImg.name = global.freshname;

      scope( stopScope )
      {
        install( NoSuchContainer => println@Console("Fault Raised: NoSuchContainer  " + stopScope.NoSuchContainer.message)( ); halt@Runtime()() );
        install( ServerError => println@Console("Fault Raised: ServerError  " + stopScope.ServerError.message)( ); halt@Runtime()() );
        install( AlreadyStarted => println@Console("Fault Raised: AlreadyStarted  " + stopScope.AlreadyStarted.message)( ); halt@Runtime()() );

        // Stop testing Container
        stopContainer@Jocker( rmCnt )( response );
        println@Console( "4/6 ---> CONTAINER STOPPED: "+ rmCnt.id )()
      };

      scope( removeScope )
      {
        install( NoSuchContainer => println@Console("Fault Raised: NoSuchContainer  " + removeScope.NoSuchContainer.message)( ); halt@Runtime()() );
        install( ServerError => println@Console("Fault Raised: ServerError  " + removeScope.ServerError.message)( ); halt@Runtime()() );
        install( BadParam => println@Console("Fault Raised: BadParam  " + removeScope.BadParam.message)( ); halt@Runtime()() );

        // Remove testing Container
        removeContainer@Jocker( rmCnt )( response );
        println@Console( "5/6 ---> CONTAINER REMOVED: "+ rmCnt.id )()
      };
      scope( removeImageScope )
      {
        install( Conflict => println@Console("Fault Raised: Conflict  " + removeImageScope.Conflict.message)( ); halt@Runtime()() );
        install( ServerError => println@Console("Fault Raised: ServerError  " + removeImageScope.ServerError.message)( ); halt@Runtime()() );
        install( NoSuchImage => println@Console("Fault Raised: NoSuchImage  " + removeImageScope.NoSuchImage.message)( ); halt@Runtime()() );

        // Remove testing Image
        removeImage@Jocker( rmImg )( response );
        println@Console( "6/6 ---> IMAGE REMOVED: "+ rmCnt.id )();
        halt@Runtime( )( )
      }
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
