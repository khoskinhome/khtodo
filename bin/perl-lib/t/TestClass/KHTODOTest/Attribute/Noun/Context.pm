package KHTODOTest::Attribute::Noun::Context;
use strict;

use base qw( Test::Class );

use File::Path;
use Test::More;
use Test::Exception;

use Data::Dumper;

use KHTODO::Attribute::Noun::Context;

sub make_fixture : Test(setup) {
    my ( $self ) = @_;


}


sub test_blah : Test(no_plan) {
    my ($self) = @_;

##     my $khtpf = KHTODO::ParseFile->new();

    ok ( 1, "ok !");

}


1;
