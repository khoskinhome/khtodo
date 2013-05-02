#!/usr/bin/perl -w

# by Karl Hoskin .Spring 2013 .

use strict;



our $DEBUG = 1;

########### Parsing >>> ###########
use KHTODO::Item;
use KHTODO::State;
use KHTODO::ParseFile;
########### Action >>>> ###########
use KHTODO::Action::Add;
use KHTODO::Action::ClearDone;
use KHTODO::Action::Delete;
use KHTODO::Action::Done;
use KHTODO::Action::Edit;
use KHTODO::Action::Emacs;
use KHTODO::Action::Git;
use KHTODO::Action::IMAP;
use KHTODO::Action::Rebase;
use KHTODO::Action::Update;
use KHTODO::Action::Vim;
use KHTODO::Action::What;
#########################


my $actions = {
    add          => "KHTODO::Action::Add",
    'clear-done' => "KHTODO::Action::ClearDone",
    delete       => "KHTODO::Action::Delete",
    done         => "KHTODO::Action::Done",
    edit         => "KHTODO::Action::Edit",
    emacs        => "KHTODO::Action::Emacs",
    git          => "KHTODO::Action::Git",
    imap         => "KHTODO::Action::IMAP",
    rebase       => "KHTODO::Action::Rebase",
    update       => "KHTODO::Action::Update",
    vim          => "KHTODO::Action::Vim",
    what         => "KHTODO::Action::What"
};

my $primary_action = $ARGV[0] || '';

die "no actions ($primary_action) !\n" if  ! $primary_action;

die "'$primary_action' not a valid action\n" if ! $actions->{$primary_action};

my $lkup = $actions->{$primary_action};

my %do = (do=>"${lkup}::new" );

do { 
    no strict 'refs';
    my $action = $do{do}($lkup);
    $action->initiate(\@ARGV);
};

