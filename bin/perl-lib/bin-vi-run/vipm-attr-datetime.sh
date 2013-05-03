#!/bin/bash

vi -p \
../lib/KHTODO/Attribute/DateTime.pm \
../lib/KHTODO/Attribute/DateTime/EndDate.pm \
../lib/KHTODO/Attribute/DateTime/StartDate.pm \
../lib/KHTODO/Attribute/DateTimeBool.pm \
../lib/KHTODO/Attribute/DateTimeBool/Done.pm \
../lib/KHTODO/Attribute/DateTimeBool/Waiting.pm \
vipm-attr-datetime.sh
