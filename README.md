# JoUnit
Tool used for Unit Test of Jolie Microservices

## Requirement

1. Microservice to test (re)named as "main.ol"

1. Directory "test_suite" in the project to test's repository.
    Within this directory you must put every file needed for the test:
    - init.ol (needed) -> here you will write tests in the format explained below
    - dependencies.ol.test (facultative) -> here you will write variables needed for the test
    - every other file needed for the test (such for example as a JSON with some structured data needed for an operations)

1. Format of "init.ol":

    If you need dependencies.ol.test file, you must include it in init.ol

    ```jolie
    include "./test_suite/dependencies.ol.test"
    ```

    Format of "dependencies.ol.test":
    
    ```jolie
    constants {
      nameConst1=<valueConst1>,
      nameConst2=<valueConst2>,
      ...
    }
    ```

    If your microservice has dependencies, you must include every of it.

    The syntax for importing a dependency is:
    
    ```jolie
    include "<outputPortName>.depservice"
    ```
    For dependency we mean an external microservice connected with an output port with our microservice to test.
    
    
    In the init's main we can write our tests, that needs to be surrounded with ```run( request )( response ) { ... }``` block.
    
    ```jolie
    main{
        run( request )( response ){
            /*First test*/
            goalrq.request_message = <operation1's Request>;
            goalrq.name = "/<inputPort's Name>/<operation1's Name>";
            
            
            // If you DONT'T NEED dependency for this operation's test
            goal@GoalManager( grq )( testResponse );
            
            // If you NEED a dependency's operation named ```twice``` for this operation's test
            goal@GoalManager( grq )( testResponse ) | twice( request )( response ){ response = <what dependency should respond>;
            
            
            expectedResponse = <operation1's expected response>;
            if( testResponse != expectedResult ){
              fault.message = <significative error message's string>;
              fault.faultname = <fault's name>;
              throw( ExecutionFault, fault)
            }
            
            
            
            /*Second test*/
            goalrq.request_message = <operation2's Request>;
            goalrq.name = "/<inputPort's Name>/<operation2's Name>";
            ...
            ...
         }
    ```
    
