include "./public/interfaces/ValidatorInterface.iol"

inputPort Validator {
Location: "local"
Interfaces: ValidatorInterface
}

main{
  [validate( )( response ){
    /*1) Check that JockerLocation points to a valid port
    with JockerContainer waiting on it*/

    /*2) Check that the developer didn't choose a port between 60000-65000
    locally for the ms, because they are used by the tool for testing */

    /*3) Check that the section ExternalVariables has exactly the Parameters
    listed by the developer inside the file dependencies.iol placed in a
    known directory AND that parameters follow the format "JDEP_*" */

    /*4) Check that there is a file named "main.ol" in the repo */

    /*5) Check that the section Dependencies contains the variable nameService
    and that services listed here exist as port in the MetaData*/

    /*6) Check that include inside init.ol of dependency has depservice as
    extension */
    response = "VALIDATION Passed!! \nJoUnit's rules followed"
  }]
}
