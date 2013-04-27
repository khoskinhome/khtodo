package KHTODOTest::Item;
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

# just if you wondered why I picked the var names :-
# tdi = todo-item object
# tdigs = todo-item object global state.


# TODO :-

=pod TODO


test and implement a way that global state hashref fields can be fully emptied,
and emptied of 1 tag at a time.

more multiline testing.

=cut 



sub test_die_if_newline_in_token : Test(no_plan) {
    my ($self) = @_;

    my $tdi =  $self->{tdi}; 

    dies_ok {$tdi->line("a line with a \n in it ")} "dies when a line has a newline in it";
    dies_ok {$tdi->line("a line with a \r in it ")} "dies when a line has a carriage return in it";

}


=item test_isTodo_isInformation

an item isn't a todo item if :-

    1) it is information tagged
    2) has only white space
    3) has only white space before the first #
    4) is an empty line
    5) is only made up of tokens that are tags.

this test should test all of the above.

=cut 

sub test_isTodo_blanks : Test(no_plan) {
    # and it also checks that tags;in the #-ed part aren't parsed.

    # isTodo is the main

    my ($self) = @_;

    my $tdi =  $self->{tdi}; 

    # checking that the non-todo lines are recognised as such :-
    $tdi->line("  #some comment, with a person that shouldn't be found pers;a-person this is not a todo item");
    is ( $tdi->isTodo, 0, "it isn't a todo item, no text before #");
    is ( $tdi->line_tokens , 0, "line_tokens count == 0" );
    is ( $tdi->found_tags_in_tokens, 0, "found_tags_in_tokens == 0" );
    is ( $tdi->parse_error , '' , "no parse_error-s"   ); 

    is_deeply(
        $tdi->persons, {},
        "testing person not extracted after the hash"
    );

    # just space :-
    $tdi->line( "    " ) ;
    is ( $tdi->isTodo, 0, "it isn't a todo item, only spaces, no text ");
    is ( $tdi->line_tokens , 0, "line_tokens count == 0" );
    is ( $tdi->found_tags_in_tokens, 0, "found_tags_in_tokens == 0" );
    is ( $tdi->parse_error , '' , "no parse_error-s"   ); 

    # empty string :-
    $tdi->line( "" ) ;
    is ( $tdi->isTodo, 0, "it isn't a todo item, empty string ");
    is ( $tdi->isMeeting, 0, "it is not a meeting");
    is ( $tdi->line_tokens , 0, "line_tokens count == 0" );
    is ( $tdi->found_tags_in_tokens, 0, "found_tags_in_tokens == 0" );

    # only tags is NOT a todo item :-
    $tdi->line( " pers;karl 1p; ;projects;glob-projey projects;globNlocal ;projects;globNlocal ;project-end;roger " ) ;
    is ( $tdi->parse_error , '' , "no parse_error-s"   ); 

    is ( $tdi->isTodo, 0, "it is not a todo item because there are only tokens that are tags. there aren't any non-tag tokens. ");
    is_deeply(
        $tdi->persons, { karl=>1 },
        "testing person not extracted after the hash"
    );

    is ( $tdi->line_tokens         , 6, "line_tokens count == 6 "   );
    is ( $tdi->found_tags_in_tokens, 6, "found_tags_in_tokens == 6" );

    # a token that isn't a tag should be recognised as a todo-item :-
    $tdi->line( " pers;karl is going todo sod all # pers;not-detected" ) ;
    is ( $tdi->isTodo, 1, "it is a todo item because there are non-tag tokens in it ");
    is_deeply(
        $tdi->persons, { karl=>1 },
        "testing person 'karl' extracted before the hash"
    );
    is ( $tdi->line_tokens , 6, "line_tokens count == 6" );
    is ( $tdi->found_tags_in_tokens, 1, "found_tags_in_tokens == 1" );

}

sub test_isTodo_isInformation_local : Test(no_plan) {
    my ($self) = @_;

    my $tdi =  $self->{tdi}; 

    #########################################
    # info tags local

    $tdi->line( " pers;karl is going todo sod all info; # pers;not-detected " ) ;
    is ( $tdi->isTodo, 0, "a line with an info tag before a hash in it anywhere is not a todo item");
    is ( $tdi->isInformation, 1, "a line with an info tag before a hash has its isInformation tag set ");
    is_deeply(
        $tdi->persons, { karl=>1 },
        "testing person 'karl' extracted before the hash"
    );
    is ( $tdi->line_tokens , 7, "line_tokens count == 7" );
    is ( $tdi->found_tags_in_tokens, 2, "found_tags_in_tokens == 2" );

    # info tag in hash 
    $tdi->line( " pers;karl is going todo sod all # info; pers;not-detected " ) ;
    is ( $tdi->isTodo, 1, "a line with an info tag AFTER a hash in it anywhere is still a todo item");
    is ( $tdi->isInformation, 0, "a line with an info tag AFTER a hash has its isInformation tag unset (0) ");
    is_deeply(
        $tdi->persons, { karl=>1 },
        "testing person 'karl' extracted before the hash"
    );
    is ( $tdi->line_tokens , 6, "line_tokens count == 6" );
    is ( $tdi->found_tags_in_tokens, 1, "found_tags_in_tokens == 1" );

}

sub test_isTodo_isInformation_global : Test(no_plan) {
    my ($self) = @_;

    # info tags global (multiline)
    my $tdi =  $self->{tdi};
    my $tdigs =  $self->{tdi}->global_state; 

    $tdi->line( " ;pers;karl is going todo sod all ;info; # pers;not-detected " ) ;
    is ( $tdi->isTodo, 0, "a line with an info tag before a hash in it anywhere is not a todo item (globla)");
    is ( $tdi->isInformation, 1, "a line with an info tag before a hash has its isInformation tag set (global) ");
    is_deeply(
        $tdi->persons, { karl=>1 },
        "testing person 'karl' extracted before the hash"
    );
    is ( $tdi->line_tokens , 7, "line_tokens count == 7" );
    is ( $tdi->found_tags_in_tokens, 2, "found_tags_in_tokens == 2" );

    

    is ( $tdigs->isInformation, 1, "global isInformation should be 1");
    $tdi->line( " ;info;-- " );
    is ( $tdigs->isInformation, 0, "global isInformation should be 0");

    #########################
    # info tag in hash global (multiline)
    $tdi->line( " ;pers;karl is going todo sod all # ;info; ;pers;not-detected " ) ;
    is ( $tdi->isTodo, 1, "a line with an info tag AFTER a hash in it anywhere is still a todo item");
    is ( $tdi->isInformation, 0, "a line with an info tag AFTER a hash has its isInformation tag unset (0) ");
    is ( $tdigs->isInformation, 0, "global isInformation should be 0");
    is_deeply(
        $tdi->persons, { karl=>1 },
        "testing person 'karl' extracted before the hash"
    );
    is ( $tdi->line_tokens , 6, "line_tokens count == 6" );
    is ( $tdi->found_tags_in_tokens, 1, "found_tags_in_tokens == 1" );

}

=item test_parse_error

test out that a semi-colon in a token, and the token is unrecognised raises a parse_error

=cut 

sub test_parse_error : Test(no_plan) {
    my ($self) = @_;

    my $tdi =  $self->{tdi}; 

    for my $sym ( qw/ ; @ / ){
        $tdi->line( " this-is-a-token${sym}with-a-semicolon in but it isn't a recognised tag. " );
        is ( $tdi->line_tokens , 8, "line_tokens count == 8" );
        is ( $tdi->found_tags_in_tokens, 0, "found_tags_in_tokens == 0" );

        ok ( $tdi->parse_error ne '' , "has a parse error" );
        ok ( $tdi->parse_error =~ /this-is-a-token${sym}with-a-semicolon/ , "has a parse error. regex part of the error string." );
    }
}

=item test_parse_other_linelocal_tags

test the priority, complexity, mtg,
tags in the local;blah form

=cut

sub test_parse_other_linelocal_tags : Test(no_plan) {
    my ($self) = @_;

    my $tdi =  $self->{tdi}; 
    my $tdigs =  $self->{tdi}->global_state; 

    # does it detect meeting tags :-
    for my $ln ( "m;", " m; ", " mtg; blah" , " blha kdkd meeting;" ){
        $tdi->line( $ln ) ;
        is ( $tdi->isMeeting, 1, "it is a meeting");
        is ( $tdigs->isMeeting , 0, "it is not a meeting (global)");
        is ( $tdi->found_tags_in_tokens, 1, "found_tags_in_tokens == 1" );

    }

    # complexity 
    for my $x ( qw/1 2 3 4 5 / ) { # $x = complexity.
        for my $ln ( "${x}c;", " ${x}c; ", " ${x}C; blah" , " blha kdkd ${x}c;" ){
            $tdi->line( $ln ) ;
            is ( $tdi->complexity, uc($x), "complexity is $x");
            is ( $tdigs->complexity, 4, "complexity is $x (global)");
            is ( $tdi->found_tags_in_tokens, 1, "found_tags_in_tokens == 1" );
        }
    }

    # priority
    for my $x ( qw/1 2 3 4 5 /) { # $x = priority.
        for my $ln ( "${x}p;", " ${x}p; ", " ${x}P; blah" , " blha kdkd ${x}p;" ){
            $tdi->line( $ln ) ;
            is ( $tdi->priority, uc($x), "priority is ".uc($x));
            is ( $tdigs->priority, 4, "priority is ".uc($x). "(global)");
            is ( $tdi->found_tags_in_tokens, 1, "found_tags_in_tokens == 1" );
        }
    }

}

=item test_parse_name_linelocal_tags

test the name (noun) tags in the local;blah form
that are all stored in HashRef fields. 

=cut

sub test_parse_name_linelocal_tags : Test(no_plan) {
    my ($self) = @_;

    my $tdi   =  $self->{tdi}; 
    my $tdigs =  $self->{tdi}->global_state; 



    #testing persons, projects, names and places

    my $line =" \@;work:home p;karl:paul:steve are going to plc;London and then plc;Brentwood with per;Alison:steve to work on their project about proj;train-travel and they are using nm;greater-anglia  dep;some-dep:another-dep";
    $tdi->line($line);
    is($tdi->complexity, 4 , "default complexity of 4" ); 
    is($tdi->priority  , 4 , "default priority of 4"   ); 

    is_deeply(
        $tdi->persons,
        { 
            'karl'   => 1,
            'paul'   => 1,
            'Alison' => 1,
            'steve'  => 1,
        },
        "testing person extracted"
    );

    is_deeply( $tdigs->persons,{},"testing person extracted (global)");
        
    is_deeply(
        $tdi->projects,
        { 
            'train-travel'   =>1,
        },
        "testing projects extracted"
    );
    is_deeply( $tdigs->projects,{},"testing projects extracted (global)");

    is_deeply(
        $tdi->project_dependencies,
        { 
            'some-dep' => 1,
            'another-dep' => 1,
        },
        "testing project dependencies extracted"
    );
    is_deeply( $tdigs->project_dependencies,{},"testing project dependencies extracted (global)");


    is_deeply(
        $tdi->names,
        { 
            'greater-anglia'   =>1,
        },
        "testing names extracted"
    );
    is_deeply( $tdigs->names,{},"testing names extracted (global)");

    is_deeply(
        $tdi->places,
        { 
            'London'    => 1,
            'Brentwood' => 1,
        },
        "testing places extracted"
    );
    is_deeply( $tdigs->places,{},"testing places extracted (global)");

    #testing contexts
    is_deeply(
        $tdi->contexts,
        { 
            'work' => 1,
            'home' => 1,
        },
        "testing contexts extracted"
    );
    is_deeply( $tdigs->contexts,{},"testing contexts extracted (global)");

}


=item test_parse_other_lineglobal_tags

test the priority, complexity, mtg, start, end and done
tags in the ;global;blah form

=cut

#TODO test the -- syntax . sortof done ! 
 
sub test_parse_other_lineglobal_tags : Test(no_plan) {
    my ($self) = @_;

    my $tdi =  $self->{tdi}; 

    my $tdigs = $tdi->global_state;

    # does it detect meeting tags :-
    for my $ln ( ";m;", " ;m; ", " ;mtg; blah" , " blha kdkd ;meeting;" ){
        $tdi->line( $ln ) ;
        is($tdi->parse_error , '' , "no parse_error-s"   ); 
        is ( $tdigs->isMeeting, 1, "it is a meeting (global)");
        is ( $tdi->isMeeting, 1, "it is a meeting (local)");
        $tdi->line(" ;m;-- m; ");
        is ( $tdigs->isMeeting, 0, "it is a meeting (global)");
        is ( $tdi->isMeeting, 1, "and the local meeting has been set (local)");
    }

    # complexity 
    for my $x ( qw/1 2 3 4 5/ ) { # $x = complexity.
        for my $ln ( " ;${x}c;", " ;${x}c; ", " ;${x}c; blah" , " blha kdkd ;${x}c;" ){
            $tdi->line( $ln ) ;
            is($tdi->parse_error , '' , "no parse_error-s"   ); 
            is ( $tdigs->complexity, $x, "complexity is $x (global)");
            is ( $tdi->complexity, $x, "complexity is $x (local)");
            $tdi->line(" ;${x}c;-- ${x}c; ");
            is ( $tdigs->complexity, 4, "back to default complexity of 4 on global state");
            is ( $tdi->complexity, $x, "local line has its complexity set to $x");
        }
    }

    # priority
    for my $x ( qw/1 2 3 4 5 /) { # $x = priority.
        for my $ln ( ";${x}p;", " ;${x}p; ", " ;${x}p; blah" , " blha kdkd ;${x}p;" ){
            $tdi->line( $ln ) ;
            is($tdi->parse_error , '' , "no parse_error-s"   ); 
            is ( $tdigs->priority, uc($x), "priority is ".uc($x). " (global)");
            is ( $tdi->priority, uc($x), "priority is ".uc($x). " (local)");
            $tdi->line(" ;${x}p;-- ${x}p; ");
            is ( $tdigs->priority, 4, "back to default priority of 4 on global state");
            is ( $tdi->priority, $x, "local line has its priority set to $x");
        }
    }

    ## TODO check the 'start' 'end' 'done' and 'waiting' dates.

}

=item test_parse_name_lineglobal_tags

test the name (noun) tags in the ;global;blah form

=cut

#TODO test the -- syntax 

sub test_parse_name_lineglobal_tags : Test(no_plan) {
    my ($self) = @_;

    my $tdiMain = $self->{tdi}; 
    my $tdigs   = $self->{tdi}->global_state; 


    #TODO testing start , end , done and waiting dates. iso8601 needs looking . probably sumin on cpan.

    #testing persons, projects, names and places

    for my $tdi ( $tdiMain, $tdigs ) {
        # on global tags , on parsing a single line in a test like this both the local and global state should be the same, even though they are global tags. because the global tags apply to the line they are on as well as following lines 

        my $line =" ;\@;work:home ;p;karl:paul:steve are going to ;plc;London and then ;plc;Brentwood with ;per;Alison:steve to work on their project about ;proj;train-travel and they are using ;nm;greater-anglia  ;dep;some-dep:another-dep";
        $tdiMain->line($line);
        is($tdi->complexity, 4 , "default complexity of 4" ); 
        is($tdi->priority  , 4 , "default priority of 4"   ); 

#    print STDERR Dumper ($tdi->persons);

        is_deeply(
            $tdi->persons,
            { 'karl'   => 1, 'paul'   => 1, 'Alison' => 1, 'steve'  => 1, },
            "testing person extracted"
        );
            
        is_deeply(
            $tdi->projects,
            { 'train-travel'   =>1, },
            "testing projects extracted"
        );

        is_deeply(
            $tdi->project_dependencies,
            { 'some-dep' => 1, 'another-dep' => 1, },
            "testing project dependencies extracted"
        );


        is_deeply(
            $tdi->names,
            { 
                'greater-anglia'   =>1,
            },
            "testing names extracted"
        );

        is_deeply(
            $tdi->places,
            { 
                'London'    => 1,
                'Brentwood' => 1,
            },
            "testing places extracted"
        );

        #testing contexts
        is_deeply(
            $tdi->contexts,
            { 
                'work' => 1,
                'home' => 1,
            },
            "testing contexts extracted"
        );

    }
}


=item test_noun_hashrefs_from_config

test all the hashref nouns against all their variant spellings , 
also test the XXX-end; and the tag;-- formats

=cut 

sub test_noun_hashrefs_from_config : Test(no_plan) {
    my ( $self ) = @_;

    my $tdi   = $self->{tdi};
    my $tdigs = $self->{tdi}->global_state;

    for my $attrname( $tdi->getAttributeNamesByType("HashRef")){
        for my $attr_variant ( @{$tdi->getAttributeWords($attrname)} ) {
            diag("testing HashRef noun '$attrname' against its variant '$attr_variant'\n");
            $self->__test_delete_noun_with_endtags(
                $attrname,
                $attr_variant,
            );
        }
    }
}

sub __test_delete_noun_with_endtags {
    my ($self, $attribute, $attr_variant ) = @_;

    my $tdigs = $self->{gs}  = KHTODO::State->new();
    my $tdi   = $self->{tdi} = KHTODO::Item->new( global_state=>$self->{gs} );

    #############################################################################
    # first line to parse :-
    my $line =" ;$attr_variant;karl:steve:roger:mike  ";
    diag( "process line '$line'\n" );
    $tdi->line($line);

    is_deeply(
        $tdi->getAttribute($attribute),
        { 'karl'   => 1, 'roger'   => 1, 'mike' => 1, 'steve'  => 1, },
        "testing $attribute extracted in local item "
    );

    is_deeply(
        $tdigs->getAttribute($attribute),
        { 'karl'   => 1, 'roger'   => 1, 'mike' => 1, 'steve'  => 1, },
        "testing $attribute extracted in global state "
    );

    #############################################################################
    # pretend we have a new line , with the same global state :-
    # ( as would happen in parsing a file ) 
    my $newtdi = KHTODO::Item->new( global_state=>$self->{gs} );
    #shove a new line into to parse 
    $line = " nothing special in this line ";
    diag( "process line '$line'\n" );
    $newtdi->line($line);

    # all the global and local tags should be set as above :-
    # checking the global ones :-
    is_deeply(
        $tdigs->getAttribute($attribute),
        { 'karl' => 1, 'roger' => 1, 'mike' => 1, 'steve'  => 1, },
        "testing $attribute extracted global state when last line had no local tags in it."
    );

    # all the global and local tags should be set as above 
    # checking the local ones :-
    is_deeply(
        $newtdi->getAttribute($attribute),
        { 'karl' => 1, 'roger' => 1, 'mike' => 1, 'steve'  => 1, },
        "testing $attribute local values . The global state has stuff, but there were no local tags in it."
    );

    ############################################################################
    my $ntdi = KHTODO::Item->new( global_state=>$self->{gs} );
    #shove a new line into to parse 
    $line = " nothing ;$attr_variant-end;roger:mike special ${attr_variant};local-line-man in this line ";
    diag( "process line '$line'\n" );
    $ntdi->line($line);

    # all the global and local tags should be set as above :-
    is_deeply( $self->{gs}->getAttribute($attribute), { 'karl'   => 1, 'steve'  => 1, }, "testing person extracted after we've removed 2 global tags with a '$attr_variant-end' ");

    # and this local one should have the following 
    is_deeply(
        $ntdi->getAttribute($attribute),
        {
            'karl'   => 1,
            'local-line-man'   => 1, # this one has been added locally to this one line
#            'mike' => 1, # he's been removed along with roger by the XXXX-end;roger:mike
            'steve'  => 1,
        },
        "testing $attribute , when we also had a extra local-line-man tag "
    );
    
    ###############################################################################
    # test the -- syntax on the XXX-end tag, and also have a linelocal tag to keep it on its toes !
    my $ntdi5 = KHTODO::Item->new( global_state=>$self->{gs} );
    $line = " nothing ;${attr_variant}-end;-- ${attr_variant};local-line-man in this line ";
    diag( "process line '$line'\n" );
    $ntdi5->line($line) ;

    is_deeply( $self->{gs}->getAttribute($attribute), { }, "testing $attribute extracted for the global state after all the globals had been removed with the -- (minus minus) syntax");

    is_deeply( $ntdi5->getAttribute($attribute), { 'local-line-man'   => 1, },
        "testing $attribute extracted linelocal after all the globals with ;${attr_variant}-end;-- had been removed and a local line tag had been added.."
    );

    ###############################################################################
    ## add some globals back 
    my $ntdi6 = KHTODO::Item->new( global_state=>$self->{gs} );
    $line = " nothing ;${attr_variant};blah:de:blahman ${attr_variant};local-line-man6 in this line ";
    $ntdi6->line( $line ) ;
    diag( "process line '$line'\n" );

    is_deeply( $ntdi6->getAttribute($attribute), { 'local-line-man6' => 1, 'blah'=>1, 'de'=>1,'blahman'=>1 },
        "testing $attribute extracted linelocal after adding 3 globals and 1 linelocal"
    );
    is_deeply( $self->{gs}->getAttribute($attribute), { 'blah'=>1, 'de'=>1,'blahman'=>1 },
        "testing $attribute extracted linelocal after adding 3 globals and 1 linelocal"
    );

    ################################################################################
    my $ntdi7 = KHTODO::Item->new( global_state=>$self->{gs} );


    # due to the sequence here the first ;pers;-- clears all the global state for pers
    # the ;pers;anglb adds one name to the global state, and pers;locyboy adds one to the local item state.
    # unlikely to do this in practice, but I guess it is worth testing
    $ntdi7->line(" ;${attr_variant};-- ;${attr_variant};anglb ${attr_variant};locyboy ") ;

    is_deeply( $ntdi7->getAttribute($attribute), { 'anglb' => 1, 'locyboy'=>1 },
        "testing $attribute extracted after emptying all global and then adding 1 global, on the localstate"
    );
    is_deeply( $self->{gs}->getAttribute($attribute), { 'anglb'=>1 },
        "testing $attribute extracted after emptying all global and then adding 1 global, on the globalstate"
    );

}

=item test_all_nouns_in_one_line

so this test is to get as many different types of attribute and the variants of what they are called all in one line, with global and local variants , and check that it all parses correctly, with unique names, so we should see if there is mis-parsing.

=cut 

sub test_all_nouns_in_one_line : Test(no_plan) {
    my ( $self ) = @_;

    my $tdi   = $self->{tdi};
    my $tdigs = $self->{tdi}->global_state;

    my $tagcounter = 0;
    my $line = '';
    my $expected = {};

    for my $locOrGlob ( qw/local global/ ){
        my $strtag = $locOrGlob eq 'local' ? '' : ';' ;

        for my $attrname( $tdi->getAttributeNamesByType("HashRef")){
            for my $attr_variant ( @{$tdi->getAttributeWords($attrname)} ) {
                $line .= " ${strtag}$attr_variant;";

                for my $let ( qw/a b c/ ){
                    $tagcounter++;
                    my $tagname = $let.$tagcounter.$let;
                    $line .= $tagname.":";

                    # local and global tags need adding to the local expected hash
                    $expected->{$attrname}{local}{$tagname} = 1;
                    if ( $locOrGlob eq 'global' ){
                        # only global ones get added to the global expected hash.
                        $expected->{$attrname}{global}{$tagname} = 1;
                    }
                }
                $line =~ s/:$//;
            }
        }
    }

    ## diag ( $line );
    $tdi->line($line);
    for my $attrname( $tdi->getAttributeNamesByType("HashRef")){
        is_deeply( $tdi->getAttribute($attrname), $expected->{$attrname}{local},
            "testing $attrname localstate on the all nouns in one line "
        );
        is_deeply( $tdigs->getAttribute($attrname), $expected->{$attrname}{global},
            "testing $attrname globalstate on the all nouns in one line "
        );
    }
}


#TODO tests that check that a global-state datetime field can be emptied. with the -- syntax.
#TODO test the start_date_datetime and associated datetime fields.

#TODO test the -- syntax 
sub test_datetime_linelocal_tags : Test(no_plan) {
    my ($self) = @_;
    #TODO 

    my $tdi =  $self->{tdi};
    my $tdigs =  $self->{tdi}->global_state;

    $tdi->line(" start;20140506T134456  end;20150507T233156 done;20160606 waiting;20130420 " ) ;

    my $stateObj = $tdi;

    is ( $stateObj->start_date() , "20140506T134456" , "start_date was found correctly" );
    is ( $stateObj->end_date()   , "20150507T233156" , "end_date was found correctly" );
    is ( $stateObj->done()       , 1 , "done was set to 1 correctly" );
    is ( $stateObj->done_date()  , "20160606" , "done_date was found correctly" );
    is ( $stateObj->waiting()    , 1 , "waiting was set to 1 correctly" );
    is ( $stateObj->waiting_date() , "20130420" , "waiting_date was found correctly" );


    $tdi->line(" start;20140506T134456  done;20160606 " ) ;

    is ( $stateObj->start_date() , "20140506T134456" , "start_date was found correctly" );
    is ( $stateObj->end_date()   , "" , "end_date was unset" );
    is ( $stateObj->done()       , 1 , "done was set to 1 correctly" );
    is ( $stateObj->done_date()  , "20160606" , "done_date was found correctly" );
    is ( $stateObj->waiting()    , 0 , "waiting was set to 0 correctly" );
    is ( $stateObj->waiting_date() , "" , "waiting_date was unset" );


    $tdi->line(" start;20140506T134456  done;20160606 " ) ;

    is ( $stateObj->start_date() , "20140506T134456" , "start_date was found correctly" );
    is ( $stateObj->end_date()   , "" , "end_date was unset" );
    is ( $stateObj->done()       , 1 , "done was set to 1 correctly" );
    is ( $stateObj->done_date()  , "20160606" , "done_date was found correctly" );
    is ( $stateObj->waiting()    , 0 , "waiting was set to 0 correctly" );
    is ( $stateObj->waiting_date() , "" , "waiting_date was unset" );

    $tdi->line(" done; " ) ;
    is ( $stateObj->done()       , 1 , "done was set to 1 correctly" );
    is ( $stateObj->done_date()  , "" , "done_date was found correctly" );
    diag("parse_error = ".$tdi->parse_error);

    $tdi->line(" done;bad-date " ) ;
    is ( $stateObj->done()       , 1 , "done was set to 1 correctly" );
    is ( $stateObj->done_date()  , "" , "done_date was found correctly" );
    diag("parse_error = ".$tdi->parse_error);


    $tdi->line(" waiting; " ) ;
    is ( $stateObj->waiting()       , 1 , "waiting was set to 1 correctly" );
    is ( $stateObj->waiting_date()  , "" , "waiting_date was found correctly" );
    diag("parse_error = ".$tdi->parse_error);

    $tdi->line(" waiting;bad-date " ) ;
    is ( $stateObj->waiting()       , 1 , "waiting was set to 1 correctly" );
    is ( $stateObj->waiting_date()  , "" , "waiting_date was found correctly" );
    diag("parse_error = ".$tdi->parse_error);
}

{
    my $dates = {
        '20140506T134456'       => 1, # 1 indicates its valid
        '2013-W45'              => 1,
        '2013-03-02T14:00:33Z'  => 1,
        '201-w-e-blah'          => 0, # 0 indicates is invalid
        ''                      => 0, # not actually bad for done/waiting. That is handled below
    };

    # sharing these over several subs , saves long parameter lists :-
    my ( $attrname, $attr_variant, $dte, $locOrGlob, $also_set_bool, $line, $tdi, $tdigs, $strtag );

    sub test_z_datetime_from_attr_config : Test(no_plan) {
        my ($self) = @_;

        my $ztdi = $self->{tdi};

        # my $iXXXXX . i = iterator variable !
        for my $ilocOrGlob ( qw/local global/ ){
            for my $iattrname( $ztdi->getAttributeNamesByType("Datetime")){
                for my $iattr_variant ( @{$ztdi->getAttributeWords($iattrname)} ) {
                    for my $idte ( keys %{$dates} ){
                        # to stop having to pass the same parameter list to helper subs :-
                        ( $attrname, $attr_variant, $dte, $locOrGlob )
                        = ($iattrname, $iattr_variant, $idte, $ilocOrGlob );

                        $self->__datetime_from_attr_config();
                    }
                }
            }
        }
    }

    sub __datetime_from_attr_config {
        my ($self) = @_;

        $strtag = $locOrGlob eq 'local' ? '' : ';' ;
        $line = " ${strtag}$attr_variant;$dte";

        $tdigs = KHTODO::State->new();
        $tdi   = KHTODO::Item->new( global_state=>$tdigs );
        $tdi->line($line);

        $also_set_bool = $tdi->attribute_also_set_bool($attrname);

        $self->__datetime_from_attr_config_localstate();
        $self->__datetime_from_attr_config_globalstate_global();
        $self->__datetime_from_attr_config_globalstate_local();
    }

    sub __datetime_from_attr_config_localstate {
        my ($self) = @_;
        #############################################
        #local state should be the same no matter what the version of the tag we used.
        # this will test the merging of the local and global times 
        # when only a global time has been set.
        if ( $dates->{$dte} ) {
            is( $tdi->getAttribute($attrname), $dte, 
                "test $locOrGlob : $attrname : $line (local has valid date) " 
            );

            is( ref ( $tdi->getAttribute("${attrname}_datetime")), 'DateTime', 
                "test $locOrGlob : $attrname : $line (local valid date) datetime part"
            );
            is ( $tdi->parse_error ,'', "no parse errors");
        } else {
            is( $tdi->getAttribute($attrname), '', 
                "test $locOrGlob : $attrname : $line (local invalid date)"
            );
            is( $tdi->getAttribute("${attrname}_datetime"), '', 
                "test $locOrGlob : $attrname : $line (local invalid date) datetime part "
            );

            # if the date was blank and the field could also set a boolean (done and waiting )
            # then that isn't really a parse error. (although the config of dates to this test infers that is a bad date ) 
            if ( $also_set_bool && ! $dte ) {
                is( $tdi->parse_error ,'', "no parse errors");
            } else {
                ok ( $tdi->parse_error ne '', "has parse errors");
            }

            # checkout the bool settings
            if ( $also_set_bool ){
                # whether "waiting" or "done" date was valid or invalid, 
                # the bool attribute for them should be set 
                is( $tdi->getAttribute($also_set_bool),1 , 
                    "$also_set_bool is set ($locOrGlob)"
                );
            }
        }
    }

    sub __datetime_from_attr_config_globalstate_global {
        return if ( $locOrGlob ne 'global' ); 
        my ($self) = @_;

        # checks of globalstate when we have a global tag test 
        # (should all be tdigs here) :-
        if ( $dates->{$dte} ) { # is it a "valid" date , if so these for validity
            is( $tdigs->getAttribute($attrname), $dte, 
                "test $locOrGlob : $attrname : $line (global has valid date) " );
            is( ref ( $tdigs->getAttribute("${attrname}_datetime")), 'DateTime', 
                "test $locOrGlob : $attrname : $line (global has valid date) datetime part ");

            if ( $also_set_bool ){
                # whether "waiting" or "done" date was valid or invalid, 
                # the bool attribute for them should be set 
                is( $tdigs->getAttribute($also_set_bool),1, 
                    "$also_set_bool is set ($locOrGlob)"
                );
            }

            ######################################################
            ## test the minus minus global date removal :- 

            my $lineminus = " ${strtag}$attr_variant;-- ";
            my $tdinew   = KHTODO::Item->new( global_state=>$tdigs );
            $tdinew->line($lineminus);

            is( $tdigs->getAttribute($attrname), '',
                "test $locOrGlob : $attrname : $lineminus (global date removed) " );
            is( ref ( $tdigs->getAttribute("${attrname}_datetime")), '', "test $locOrGlob : $attrname : $lineminus (global date removed) datetime part ");
            is( $tdinew->getAttribute($attrname), '', "test $locOrGlob : $attrname : $lineminus (local date nowt coz global was removed)");
            is( $tdinew->getAttribute("${attrname}_datetime"), '', "test $locOrGlob : $attrname : $lineminus (local date nowt coz global was removed) datetime part ");
            #######################################################

        } else { # is it an "invalid" date. if so test for invalidity...
            is( $tdigs->getAttribute($attrname), '', 
                "test $locOrGlob : $attrname : $line (global has invalid date)" );
            is( $tdigs->getAttribute("${attrname}_datetime"), '',
                "test $locOrGlob : $attrname : $line (global has invalid date) datetime part");
        }
    }

    sub __datetime_from_attr_config_globalstate_local {
        # checks of globalstate when we have a local tag test 
        return if ( $locOrGlob eq 'global' ); 
        my ($self) = @_;

        # should all be tdigs objects being tested here :-
        is( $tdigs->getAttribute($attrname), '', 
            "test $locOrGlob : $attrname : $line (global doesn't have date set )" );
        is( $tdigs->getAttribute("${attrname}_datetime"), '',
            "test $locOrGlob : $attrname : $line (global doesn't have date set ) datetime part");

        if ( $also_set_bool ){
            # whether "waiting" or "done" date was valid or invalid, 
            # the bool attribute for them should be set 
            is( $tdigs->getAttribute($also_set_bool),0, 
                "$also_set_bool is not set ($locOrGlob)"
            );
        }
    }
}
1;

