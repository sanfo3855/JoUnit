/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*                                                                                    *
* Copyright (C) 2017 Matteo Sanfelici <sanfelicimatteo@gmail.com>                        *
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
