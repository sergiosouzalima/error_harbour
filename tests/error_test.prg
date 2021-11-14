/*
    System.......:
    Program......: error_class.prg
    Description..: Error methods class test.
    Author.......: Sergio Lima
    Updated at...: Nov, 2021

	How to compile:
	hbmk2 error_test.hbp

	How to run:
	./error_test

*/

#include "hbclass.ch"
#include "../../hbexpect/lib/hbexpect.ch"

FUNCTION Main()

	begin hbexpect
		LOCAL oError

		describe "Error Class"
			oError := Error():New()

			describe "When instantiate"
				describe "Error():New() --> oError"
					describe "oError"
						context "Class Name" expect(oError) TO_BE_CLASS_NAME("Error")
						context "result" expect(oError) NOT_TO_BE_NIL
						context "type" expect(oError) TO_BE_OBJECT_TYPE
					enddescribe
				enddescribe
			enddescribe

			oError := oError:Destroy()

		enddescribe

	endhbexpect

RETURN NIL