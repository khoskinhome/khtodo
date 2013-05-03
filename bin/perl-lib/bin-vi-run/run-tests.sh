#!/bin/bash -v 

reset

prove -v -I'../lib' -I'../t/TestClass' ../t/KHTODOTestClass.t

