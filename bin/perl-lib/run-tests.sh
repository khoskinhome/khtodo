#!/bin/bash -v 

reset

prove -v -Ilib -I't/TestClass' t/KHTODOTestClass.t

