package KHTODOTest::Action::What;
use strict;

use base qw( Test::Class );

use Test::More;
use Test::Exception;

use Data::Dumper;

use KHTODO::Item;
use KHTODO::State;
use KHTODO::Action::What;

sub make_fixture : Test(setup) {
    my ( $self ) = @_;

    $self->{gs}  = KHTODO::State->new();
    $self->{tdi} = KHTODO::Item->new( global_state=>$self->{gs} );

}

sub test_blah : Test(no_plan) {
    my ( $self ) = @_;

    my $ktawhat  = KHTODO::Action::What->new();

    my $argv = [qw/vim -p karl/];

    $ktawhat->initiate($argv);

    ok(1,"blah");

}


1;
