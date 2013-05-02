package KHTODOTest::Action::Vim;
use strict;

use base qw( Test::Class );

use Test::More;
use Test::Exception;

use Data::Dumper;

use KHTODO::Item;
use KHTODO::State;
use KHTODO::Action::Vim;

sub make_fixture : Test(setup) {
    my ( $self ) = @_;

#    $self->{av}  = KHTODO::Action::Vim->new();

}

sub test_blah : Test(no_plan) {
    my ( $self ) = @_;

    my $ktavim  = KHTODO::Action::Vim->new();

    my $argv = [];

    $ktavim->initiate($argv);

#   @{main::ARGV} 


    ok(1,"blah");

}


1;
