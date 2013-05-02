package KHTODO::Action;

use Data::Dumper;
use Getopt::Long qw/GetOptionsFromArray/;

########### Parsing >>> ###########
use KHTODO::Item;
use KHTODO::State;
use KHTODO::ParseFile;
###################################

use Moose;

# banned_cli_opts is set by the subclass in the sub-classes parse_argv() so the base-class::parse_cli_options() knows what to ban.
has banned_cli_opts =>(is =>'rw', isa=>'HashRef' );

has global_state =>(is=>'rw', isa=>'KHTODO::State');

has argv => (is=>'rw', isa=>'ArrayRef' );

# TODO . Do cli opts need breaking out into a completely separate module ? Probably yes.

#has filter_cli_opts =>(is=>

=pod 

process is :-
:w


        parse_argv() to see if 
            1a) anything more needs pulling off ARGV 
            1b) if any cli-options are barred for Action.
        before cli-option parsing 
    2) parse_cli_option(s)
    3) delegates back to the sub class for the main run()



=cut 


my $cli_opts = {


#    priority => 



};

=pod 
        filter params ( for all actions ) :-
            -pX <priority> (only show/edit/process todos with a priority the same as or higher )
            -cX <complexity> (only show/edit/process todos with a complexity the same as or higher )
            -m/--mtg
            -n/--nouns ( filter on all the hashref based noun lists. context, name , person, place, project etc.. )
            --nm/--names
            -p/--persons
            -c/--contexts <context>
            --plc/--places
            --prj/--projects
            --prjdep/--project-depend/--project-dependencies
            -d/--done

            -w/--waiting

            --sb/--start-before/--start-date-before <iso8601>
            --sa/--start-after/--start-date-after <iso8601>
            --eb/--end-bef/--end-before/--end-date-before <iso8601>
            --ea/--end/--end-date   <iso8601>

        sort-order params :-
            --sort attribute-names:colon-separated
=cut 






sub initiate {
    my ($self, $argv_ra) = @_;

    die "need argv supplied to initiate()!\n"
        if ref ($argv_ra) ne 'ARRAY' ;

    $self->argv([@{$argv_ra}]);

    print "... initiate ... \n" if $main::DEBUG;

    if ($self->can("parse_argv")){
        $self->parse_argv;
    }

    $self->parse_cli_options();

    $self->run();

}


sub parse_cli_options {
    my ($self) = @_;

    print "... parse_cli_options ... \n" if $main::DEBUG;

    $self->_build_getopts();

=pod

    my $file;
    my $length = 24;
    my $verbose;

    GetOptionsFromArray ( $self->argv, 
        "length=i" => \$length,    # numeric
        "file=s"   => \$file,      # string
        "verbose"  => \$verbose)   # flag
    or die("Error in command line arguments\n");

    print "file = $file \n" if $file;
    
=cut

    print "finished parsing cli opts \n";


}


sub _build_getopts {

    my ($self) = @_;
    
    for my $attr ( $self->global_state->getAttributeNames() ){
        print "...attr = $attr \n";


    }

}


sub BUILD {
    my ($self) = @_;

    $self->global_state(KHTODO::State->new());
}


1;
