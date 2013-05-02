package KHTODOTest::Action;
use strict;

use base qw( Test::Class );

use Test::More;
use Test::Exception;

use Data::Dumper;

use KHTODO::Item;
use KHTODO::State;

sub make_fixture : Test(setup) {
    my ( $self ) = @_;

    $self->{gs}  = KHTODO::State->new();
    $self->{tdi} = KHTODO::Item->new( global_state=>$self->{gs} );

}

sub test_blah : Test(no_plan) {
    my ( $self ) = @_;

    ok(1,"blah");

}


1;
