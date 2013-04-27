package KHTODO::ParseFile;
use strict;

use KHTODO::Config;
use KHTODO::Item;
use KHTODO::State;

use Moose;
use Moose::Util::TypeConstraints;

use Data::Dumper; # TODO get rid of this when done with debugging.
use DateTime;

use File::Find;

has dirs_to_search => ( is=>'rw', isa=>'ArrayRef' ) ;

has todos => ( is=>'rw', isa=>'ArrayRef' , default=>sub {[]} );

#has filenames => ( is=>'rw', isa=>'ArrayRef' , default=>sub {[]} );

my $findfilenames = [];

=pod 

#KHTODO::ParseFile is a singleton

its objective is to take a/some search dirs, find all the files 
in them that have ;todo; as the first entry on the first line.

parse those files in to one big collection (array-ref) of KHTODO::Items
so something else can produce output from the TODO lists / edit the todolists.

=cut 

=item parseTodoFiles 

iterates over "filenames" and parses each one.
creates a KHTODO::Item object for every valid todo-item line,
this object is pushed onto the attribute KHTODO::ParseFile::todos .


=cut 

sub parseTodoFiles {
    my ($self) = @_;
    $self->findTodoFiles();

    for my $filename ( @$findfilenames ) {

        my $global_state = KHTODO::State->new(); # we'll "global" per file !
        open( my $fh, "<", $filename ) or die "can't open $filename";

        my $linecount=0;
        while ( !eof($fh) ) {
            my $line = readline $fh;
            $linecount++;
            if ( $line =~ /^;todo;/i){
                next if $linecount ==1;
                # KHTODO::Item->parse_error will have a parse_error 
                # for any of these that aren't on the first line.
            }
            my $khtdi = KHTODO::Item->new( global_state => $global_state );
            chomp($line);
            $khtdi->line($line);
            if ( $khtdi->isTodo ) {
                $khtdi->filename($filename);
                $khtdi->filelineno($linecount);
                push @{$self->todos} , $khtdi;
            }
        }
        close $fh;
    }
}


=item findTodoFiles 

called with an array ref of directories to search.

populates filenames with a list of files that are recognised at Todo Lists.

=cut 

sub findTodoFiles {
    my ( $self ) = @_;

    find(\&push_to_findfilenames_if_todo, @{$self->dirs_to_search} );

}

=item push_to_findfilenames_if_todo

is a file a todo list ?

which boils down to does it have ";todo;" as the first entry on the first line.

=cut 

sub push_to_findfilenames_if_todo {
    my $filename = $File::Find::name;

    if ( -f $filename ){
        open( my $fh , "<" , $filename ) or die "can't open $filename";
        if ( !eof($fh) ) {
            my $firstline = readline $fh ;

            push @$findfilenames, $filename 
                if $firstline =~ /^;todo;/i;
        }
        close $fh;
    }
}


sub BUILD {
    my ( $self ) = @_;


}

1;
