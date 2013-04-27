package KHTODOTest::ParseFile;
use strict;

use base qw( Test::Class );

use File::Path;
use Test::More;
use Test::Exception;

use Data::Dumper;

#use KHTODO::Item;
#use KHTODO::State;
use KHTODO::ParseFile;

sub make_fixture : Test(setup) {
    my ( $self ) = @_;


}

# just if you wondered why I picked the var names :-
# tdi = todo-item object
# tdigs = todo-item object global state.


# TODO :-

=pod TODO


test and implement a way that global state hashref fields can be fully emptied,
and emptied of 1 tag at a time.

more multiline testing.

=cut 



sub test_blah : Test(no_plan) {
    my ($self) = @_;

    my $khtpf = KHTODO::ParseFile->new();

    ok ( 1, "ok !");

}

=pod 

mkdir /tmp/khtodo-test

cat some files out to /tmp/khtodo-test

KHTODO->new(dirs_to_search=>

=cut 

sub test_parse_some_files : Test(no_plan) {
    my ($self) = @_;

    my $tmpdir = "/tmp/khtodo-test/";

    if ( ! -d $tmpdir ) {
        File::Path::make_path($tmpdir);
    }

    unlink "$tmpdir/*";


my $file1contents =<<'FILE1';
;todo;

;@;somewhere

;project;karlstodo ;3p; ;2c;

    create a todo file format and parser in perl start_date;2013-03-03

;project-end;karlstodo


FILE1

    burp("${tmpdir}todo1.txt", $file1contents);


my $file2contents =<<'FILE1';
;todo;

;@;home

;project;automate-everything ;3p; ;1c;

    make the lights remotely switchable

;project-end;automate-everything

done; todo line outside project bounds 5c;

FILE1

    burp("${tmpdir}todo2.txt", $file2contents);
    
    
    my $expected = {
        "create a todo file format and parser in perl start_date;2013-03-03" => {
            projects   => { 'karlstodo' => 1 },
            priority   => 3,
            complexity => 2,
            contexts   => { somewhere=>1 },
            done       => 0,
        },
        "make the lights remotely switchable" => {
            projects   => { 'automate-everything' => 1 },
            priority   => 3,
            complexity => 1,
            contexts   => { 'home' => 1 },
            done       => 0,
        },
        "done; todo line outside project bounds 5c;" => {
            projects   => { },
            priority   => 3,
            complexity => 5,
            contexts   => { 'home' => 1 },
            done       => 1,
        },
    };

    
    
    
    my $khtpf = KHTODO::ParseFile->new();
    
    $khtpf->dirs_to_search([$tmpdir]);
    $khtpf->parseTodoFiles();  
 
#    print STDERR Dumper ( $khtpf->todos );

    my $got = {};
    for my $ttd ( @{$khtpf->todos} ) {
        my $line = trim($ttd->line);
        $got->{$line} = {    
            projects   => $ttd->projects,
            priority   => $ttd->priority,
            complexity => $ttd->complexity,
            contexts   => $ttd->contexts,
            done       => $ttd->done,
#            priority => $ttd->projects,
#            priority => $ttd->projects,

        };
    }
 
#    print STDERR Dumper ( $got );

    is_deeply($got, $expected, "todo results parsed from several files" ) ;

    ok ( 1, "ok is ok !");    
    
}

sub trim {
    my ($txt) = @_;

    $txt =~ s/^\s+//g;
    $txt =~ s/\s+$//g;
    return $txt;
}

sub burp {
    my( $file_name ) = shift ;
    open( my $fh, ">$file_name" ) || 
        die "can't create $file_name $!" ;
    print $fh @_ ;
}


1;
