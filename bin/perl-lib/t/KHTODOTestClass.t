#!perl 


# all the hashed out "use"s below need unhashing UNLESS explicitly explained why its hashed out.
use KHTODOTest::Item;
use KHTODOTest::ParseFile;

use KHTODOTest::Action;
use KHTODOTest::Action::Vim;
use KHTODOTest::Action::What;


Test::Class->runtests;

