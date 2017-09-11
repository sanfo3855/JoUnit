# JoUnit
Tool used for Unit Test of Jolie Microservices


[1 - Requirement](https://github.com/sanfo3855/JoUnit#1---requirement)

[1.1 - Format of init.ol](https://github.com/sanfo3855/JoUnit#11---format-of-initol)

[1.2 - Format of test.ol](https://github.com/sanfo3855/JoUnit#12---format-of-a-testnameol)

[2 - JoUnit Configuration](https://github.com/sanfo3855/JoUnit#2---jounit-configuration)

[3 - JoUnit Usage](https://github.com/sanfo3855/JoUnit#3---jounit-usage)





## 1 - Requirement

1. Microservice to test (re)named as "main.ol"

2. Directory "test_suite" in the project to test's repository.
    Within this directory you must put every file needed for the test:
    - init.ol (needed) -> here you will write only a list of goal (format explained below)
    - \<testname\>.ol -> test's code (you can recursively write goal to another <testname1>.ol here)
    - dependencies.ol.test (facultative) -> here you will write variables needed for the test
    - every other file needed for the test (such for example as a JSON with some structured data needed for an operations)
    
3. You need [JolieLang](http://jolie-lang.org/) and [Docker](https://www.docker.com/) installed on your computer

4. You need a Running Docker Container of [Jocker](https://github.com/jolie/jocker). How to correct run jocker [HERE](http://claudioguidi.blogspot.it/2017/07/orchestrating-docker-containers-with.html)

### 1.1 - Format of ```init.ol```:

The init.ol is simply a list of goal to test surrounded with a ```run( request )( response ) { ... }``` block. Every goal point to a file with test's code inside.
    
Example of ```init.ol``` for 3 separate testing file (```<testname1>.ol```, ```<testname2>.ol```, ```<testname3>.ol```):

```jolie
    main{
    run( request )( response ){

        grq.name = "<testname1>";
        goal@GoalManager( grq )( testResponse );

        gorq.name = "<testname2>";
        goal@GoalManager( grq )( testResponse );

        grq.name = "<testname3>";
        goal@GoalManager( grq )( testResponse );
     }
```
Here we execute 3 goal, calling each test we wrote. 

For "Goal" we mean something that needs to be executed successfully for proceeding to the next goal. Every goal should return SUCCESS or FAILED (with a fault message in that case)

If, for example, ```<testname2>```'s goal has a fault, it recursively stop every super-goal in waiting.
    
### 1.2 - Format of a ```<testname.ol>```

If you need ```dependencies.ol.test``` file, you must include it in ```<testname>.ol```

```jolie
include "./test_suite/dependencies.ol.test"
```

Format of ```dependencies.ol.test```:

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


In the ```<testname>```'s main we can write our test, that needs to be surrounded with ```run( request )( response ) { ... }``` block.

```jolie
main{
    run( request )( response ){
        /*First operation test*/
        goalrq.request_message = <operation1's Request>;
        goalrq.name = "/<inputPort's Name>/<operation1's Name>";

        // If you DONT'T NEED dependency
        goal@GoalManager( grq )( testResponse );

        // If you NEED a dependency with an operation named "twice"
        { goal@GoalManager( grq )( testResponse ) | twice( request )( response ){ response = <what dependency should respond> };

        expectedResponse = <operation1's expected response>;
        if( testResponse != expectedResult ){
          fault.message = <significative error message's string>;
          fault.faultname = <fault's name>;
          throw( ExecutionFault, fault)
        }
     }
```


In the node .request_message we put the input of ```<operation1>```

```jolie
goalrq.request_message = <operation1's Request>;
```

In the node .name we put the name of the input port on which we can find our service and the operation we need to test

```jolie
goalrq.name = "/<inputPort's Name>/<operation1's Name>";
```

There are two ways of calling a goal:
- If you DONT'T NEED dependency for this operation's test we simply call a goal
```jolie
goal@GoalManager( grq )( testResponse );
```
- If you NEED a dependency with an operation named "twice" for this operation's test, we need to call a goal and in parallel we need to provide the dependency's operation needed for the goal

```jolie
{ goal@GoalManager( grq )( testResponse ) | twice( request )( response ){ response = <what dependency should respond> };
```

When we receive the ```testResponse```, we have to compare it with an ```expectedResult```. If ```testResponse``` and ```expectedResult``` don't match we throw a fault that will stop recursively every super-goal.


### Packaging

You must pack your microservice, every needed dependencies and the folder test_suite inside a clonable repository.

An example easy to understand can be found [here](https://github.com/sanfo3855/test1)

## 2 - JoUnit Configuration

After cloning JoUnit's repository, you maybe need to edit the ```config.ini``` in the root directory.

- ```JockerLocation=socket://localhost:8008``` if you have configured Jocker's container as written in [this article](http://claudioguidi.blogspot.it/2017/07/orchestrating-docker-containers-with.html). You must change the port if you have configured Jocker with a different port on your PC's side.

- ```OrchestratorLocation=socket://172.17.0.1:10005``` is the local IP address on which microservice's container will send the output and on which the orchestrator are waiting. You can change the port, but NOT the address (you will not see the output of every test, even if the test will run successfully).

## 3 - JoUnit Usage

The only way of using the tool is from this command ``` jolie orchestrator_jo_unit.ol <repoaddress> ``` (you can also write a Script with a list of similar command and different address)
