#!/usr/bin/perl
use strict;

my $docdir = "$ENV{KHTODODATA}";

my @todofiles; # well ones starting with a ::TODO:: or *todo: or *TODO: or ::todo::
for my $file ( split /\n/, qx{find $docdir} ) {
    next if ! -f $file;
    my $headresult = qx{head -n 1 "$file"};

    if ( $headresult =~ m/^;TODO;/i 
        ||  $headresult =~ m/^\TODO;/i  ) {
        print $file."\n";
        push @todofiles, $file;
    }
};

my $vimrc="";
if ( -f "$ENV{TODOGITBASE}/vimrc" ){
#    $vimrc=" -u $ENV{TODOGITBASE}vimrc";
}

my $vitodocmd = "/usr/bin/vim $vimrc -p ".join( " ",@todofiles);

print $vitodocmd."\n";

system ($vitodocmd);

