#!perl 


# all the hashed out "require"s below need unhashing UNLESS explicitly explained why its hashed out.

BEGIN {

    require KHTODOTest::Attribute;

    require KHTODOTest::Attribute::Rating;
    require KHTODOTest::Attribute::Rating::Complexity;
    require KHTODOTest::Attribute::Rating::Priority;

    require KHTODOTest::Attribute::DateTimeBool;
    require KHTODOTest::Attribute::DateTimeBool::Done;
    require KHTODOTest::Attribute::DateTimeBool::Waiting;

    require KHTODOTest::Attribute::DateTime;
    require KHTODOTest::Attribute::DateTime::EndDate;
    require KHTODOTest::Attribute::DateTime::StartDate;

    require KHTODOTest::Attribute::Bool;
    require KHTODOTest::Attribute::Bool::Information;
    require KHTODOTest::Attribute::Bool::Meeting;

    require KHTODOTest::Attribute::Duration;
    require KHTODOTest::Attribute::Duration::Actual;
    require KHTODOTest::Attribute::Duration::Estimate;

    require KHTODOTest::Attribute::Noun;
    require KHTODOTest::Attribute::Noun::Place;
    require KHTODOTest::Attribute::Noun::Name;
    require KHTODOTest::Attribute::Noun::Person;
    require KHTODOTest::Attribute::Noun::ProjectDependency;
    require KHTODOTest::Attribute::Noun::Project;
    require KHTODOTest::Attribute::Noun::Context;

}

Test::Class->runtests;

=pod 

=cut

