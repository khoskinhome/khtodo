package KHTODO::Item;
use strict;
use Data::Dumper; ## TODO get rid of this when done debugging.

use Mouse;
use Mouse::Util::TypeConstraints;

use KHTODO::State;
use KHTODO::Config;

use DateTime;
use DateTime::Format::ISO8601;
use DateTime::Locale;
use DateTime::TimeZone;
use TryCatch;

# a KH TODO item is essentially 1 line in a file.

#TODO rename Datetime DateTime in several files. 

# I sometimes mix up "global" and "multiline" in reference to the tags in this file.
# they are sort of synonomous for the context of KHTODO::Item and KHTODO::State

has line => ( is=>'rw' , isa=>'Str', default=>'' , trigger=>\&parseline);  # the line the todo item is worked out from

extends 'KHTODO::State';

# yes it inherits from state , but there is also a global state that works on different tags formatting.
has global_state => ( is=>'rw' , isa=>'KHTODO::State' );

# isParsingGlobal is used by the internal _parseXXXXX methods to know when the switch from 
# parsing for the tags that just apply to the line to the tags that affect the $self->global_state object.
has isParsingGlobal => ( is=>'rw', isa=>'Bool', trigger=>\&_setCurrState );

# so currState is going to contain either $self or $self->global_state :- 
has currState        => ( is=>'rw', isa=> 'Item' ); 
has curr_start_regex => ( is=>'rw', isa=> 'Str' );

# defs for the following 3 variables :-
# tokens = line split up on spaces.
#   The definiton of token I am using is the the following is 1 token :-
#      thisIsOne;token:with:a:semicolon:and_colons_in_it
#   The following is 2 tokens :-
#       this;is two;different:tokens
#
# tag = one of the special identifiers that uses semi-colons to detect things
has line_tokens          => ( is=>'rw', isa=>'Int' );
has found_tags_in_tokens => ( is=>'rw', isa=>'Int' );

# found_tags_in_tokens is a count of the tokens that have at least ONE semicolon in.
# it is NOT a literal count of semi-colons

# what this is trying to achieve here is to see :-
#   how many line_tokens
#   how many of those tokens had a detected tag in.
#
# What this allows us to do is 
#   1 ) work out if a line token has a tag in it.
#   2 ) know how many tokens there are in a line
#   3 ) detect whether the line has any non-tag tokens. 
#           This makes it a todo-item.
#           lines with just tag-tokens in them are NOT todo items.

####################################
## parse errors are essentially :-
#   a semicolon was detected , but a tag wasn't detected.
#   something wrong with the date-time
#   something else I have thought of yet !! 
#
has parse_error => ( is=>'rw', isa=>'Str');

# need to keep track of where todo-items came from and this is :-
has filename   => ( is=>'rw', isa=>'Str');
has filelineno => ( is=>'rw', isa=> 'Int');


__PACKAGE__->meta->make_immutable;

=item parse_error_concat

adds stuff onto the end of parse_error.

=cut 

sub parse_error_concat {
    my ($self, $str) = @_;
    my $pstr = $self->parse_error || "";
    $self->parse_error($pstr.$str);
}

=item isTodo

=cut 

sub isTodo {
    my ($self) = @_;

    # it isn't a Todo item if all the tokens in the line 
    # are recognised as the "semi;colon-tags"
    # And it isn't a todo item if it is "information" as specified by an
    # info; tag.
    if ( $self->found_tags_in_tokens == $self->line_tokens
        || $self->isInformation 
    ) {
        return 0;
    }
    return 1;
}

=item parseline

=cut 

sub parseline {
    my ($self) = @_;

    ## TODO are there more newline chars than just \n and \r ? 
    die "This is meant to parse a single line. Not multilines ! \n" if $self->line =~ /(\n|\r)/; 

    ########################################################
    # Preparing the line. 
    ########################################################

    # strip off the comments section of the line :-
    my ( $line ) = $self->line =~ m/(.*?)(#|$)/;

    # split line into tokens ( "split" gets an empty string to start ) 
    my @tokens = $line =~ /([^\s+]+)/g;

    $self->line_tokens(scalar @tokens);
    $self->found_tags_in_tokens(0);

    $self->parse_error(""); # because we have a fresh line.

    $self->setDefaults();

    ########################################################
    # Parsing the tags for thisline and global :-
    ########################################################
    # tags_detect is used for detecting which tokens were recognised as tags
    # it needs to be populated when detecting Global (multiline) tags
    # as well as single line tags.
    my @tags_detect;  

    # parse for the "tag;sumin" tags that just apply to this line 
    $self->isParsingGlobal(0);
    $self->_parse_token_array(\@tokens, \@tags_detect);
    
    # parse for the ";tag;sumin" tags that just apply to this and all following lines
    $self->isParsingGlobal(1);
    $self->_parse_token_array(\@tokens, \@tags_detect);

    # now after parsing both thisline and global we can see if a tag wasn't detected
    # when there were semicolons or @'s in the token.

    for ( my $i=0; $i < @tags_detect; $i++ ){
        if ($tokens[$i] =~ /(\;|\@)/ && !$tags_detect[$i] ) {
            $self->parse_error_concat("Token '$tokens[$i]' has a semicolon or @, but a tag wasn't detected.\n");
        }
    }
    
    $self->_parseAddGlobalState();
}

sub _parseAddGlobalState { 
    my ($self) = @_ ;
    # This is the last stage of parsing. 
    #
    # now get the global tags and add them to the "state" for this item.
    # we need to record it NOW , because the global state object will change 
    # and so we have to record it in this-state NOW. 

    # do the DateTimes and the isMeeting and isInformation :-    

    for my $attrname( 
        $self->getAttributeNamesByType("Bool"),
        $self->getAttributeNamesByType("Datetime"),
    ){

        if ( ! $self->getAttribute($attrname) 
            && $self->global_state->getAttribute($attrname)
        ){
            $self->setAttribute(
                $attrname,
                $self->global_state->getAttribute($attrname)
            );

            if ( $self->getAttributeType($attrname) eq 'Datetime' ){ 
                # need to make a whole new DateTime object :-
                _set_attribute_datetime_on_iso8601_string(
                    $self, 
                    $attrname, 
                    $self->global_state->getAttribute($attrname)
                );
            }
        } 
    } 
   
    # these aren't easily returned by getAttributeNamesByType() so :-
    $self->done(    $self->done    || $self->global_state->done );
    $self->waiting( $self->waiting || $self->global_state->waiting );

    # These require looking at a XXXX_set bool to decide which one to use.
    # a locally set priority or complexity should always override the global setting.
    $self->complexity( 
        $self->complexity_set ? $self->complexity : $self->global_state->complexity
    );

    $self->priority( 
        $self->priority_set ? $self->priority : $self->global_state->priority
    );

    for my $attrname( $self->getAttributeNamesByType("HashRef")){
        $self->setAttributeHashConcat(
            $attrname,
            $self->global_state->getAttribute($attrname)
        );
    }
}

=item _setCurrState

_setCurrState is triggered by a set on isParsingGlobal

=cut 

sub _setCurrState {
    my ($self) =@_; 

    if ( $self->isParsingGlobal ) {
        # ;tag;blah:<blah matches (multi line tags) . "global" tags.
        $self->curr_start_regex('^;');
        $self->currState($self->global_state);

    } else {
        #tag;blah:blah matches (single line tags) "this" token tags
        $self->curr_start_regex('^');
        $self->currState($self);
    }
}

=item _parse_token_array

the $tags_detect gets modified by _parse_token_array. 
this is to pass share the tags detected between local-line and global based tags.

=cut

sub _parse_token_array {
    my ($self, $tokens, $tags_detect ) = @_;

    for (my $i=0; $i < @$tokens; $i++ ){
        my $tag_detected = $self->parse_token( $tokens->[$i] );

        $tags_detect->[$i] = $tag_detected || $tags_detect->[$i] || 0 ;
        if ( $tag_detected ) {
            $self->found_tags_in_tokens($self->found_tags_in_tokens+1);
        }
    }
}

=item parse_token

The entry point for parsing a token.

All other different types of token parsing are called from this sub.

returns 1 if a tag was detected in the token
returns 0 if a tag wasn't detected in the token.

quits out on the first match , since there isn't    
any point looking for other matches. That would 
slow it all down !

We can only have 1 tag per token . 

=cut 

sub parse_token { 
    my ( $self , $token ) = @_ ;

    # the definition for this context of token is a set of characters without any
    # whitespace in it. Hence :-
    die "the token has whitespace in it. ERROR !\n" if $token =~ /\s/; 

    return 1 if $self->_parse_token_bool_n_int( $token );
    return 1 if $self->_parse_token_datetime( $token );
    return 1 if $self->_parse_token_HashRef_start_tags( $token );
    return 1 if $self->_parse_token_HashRef_end_tags( $token );

    return 0 ; # no tag_detected !! ;
}

=item _parse_token_bool_n_int

=cut 

sub _parse_token_bool_n_int {
    my ( $self, $token ) = @_;

    my $start_regex = $self->curr_start_regex();
    my $stateObj    = $self->currState;

    # find the first priority . TODO should we warn if more than 1 priority was set in one line ?
    # type "Int" should do 'complexity' and 'priority'
    # type "Bool" should do 'meeting' and 'information'
    for my $attrname(  
        $self->getAttributeNamesByType("Int"),  #should do complexity and priority
        $self->getAttributeNamesByType("Bool"), #should do meeting and information
    ){
        my $pattern = $self->getAttributeRegexStart($attrname);
        if ( my ($val, $minusminus ) = $token =~ m/${start_regex}${pattern};(--|$)/i ){

            if ($self->isParsingGlobal && $minusminus eq '--') {
                $stateObj->setAttributeDefault($attrname);
            } else {
                $val = 1 if ( $self->getAttributeType($attrname) eq 'Bool' ); 
                $stateObj->setAttribute($attrname, $val);
            }

            # also setting bool . needed for priority and complexity, 
            # it will do it on both the global and local tags, but we only need it on 
            # the local state.
            my $also_set = $self->attribute_also_set_bool($attrname) ;
            if ( $also_set ) {
                $stateObj->setAttribute($also_set,1);
            }
            return 1;
        }
    } 
    return 0; # because we haven't found a tag. 
}

=item _parse_token_datetime

parsing the ISO8601 datetime fields.

=cut 

sub _parse_token_datetime {
    my ( $self, $token ) = @_;
    my $stateObj = $self->currState;
    my $start_regex = $self->curr_start_regex();
    for my $attrname( 
        $self->getAttributeNamesByType("Datetime"),
    ){
        my $pattern = $self->getAttributeRegexStart($attrname);
        if ( my (undef, $tv) = $token =~ m/${start_regex}${pattern};([\w\-\:]*)$/i ){
            try {
                $self->_parse_token_datetime_meat($attrname, $tv);
            } catch {
                $self->parse_error_concat ("token '$token' has a bad datetime format. Not ISO8601\n");
            }
            return 1; # because tag_detected
        }
    } 
    return 0; # no tags detected.
}


=item _parse_token_datetime_meat

=cut 

sub _parse_token_datetime_meat { # the "MEAT" of the processing ;) 

    my ($self, $attrname, $tv ) = @_;
    my $stateObj = $self->currState;

    # first handle the -- syntax for global multiline tags.
    if ( $self->isParsingGlobal && $tv eq '--') {
       $stateObj->setAttributeDefault(${attrname});
       return;
    } 

    # The logic here is for "waiting" and "done" fields can not have a date set.
    # They should work, but just set the "waiting" and "done" , they shouldn't raise 
    # a "datetime parsing error" . These fields have a "also_set_bool" attr_config.
    #
    # the start_date and end_date fields should always have a valid date
    # hence they should always try and run the _set_attribute_datetime_on_iso8601_string 

    # bool state must be set even if the date isn't valid.
    my $also_set_bool = $self->attribute_also_set_bool($attrname); # attribute name to set.
    if (  $also_set_bool ) { # the "done" and "waiting" attributes here.
        # I guess it will always be '1' here.
        $stateObj->setAttribute($also_set_bool, 1 ) ;
        # for boole fields only bother trying to set the datetime if 
        # we have a non-blank/empty $tv 
        #if (! $tv || $tv eq '' || $tv eq ' ') {
        if ( ! $tv ) {
            $stateObj->setAttributeDefault( ${attrname} );
            # frickin' setting the above resets the also_set_bool, so we've got to do it again.
            $stateObj->setAttribute($also_set_bool, 1 ) ;
            return;
        }
    } 

    # so to get here, we have either a datetime field that doesn't have an associated
    # boole attribute ( start_date and end_date) or the datetime field that has a boole attribute and has what should be a valid datetime to set ( waiting and done ) 

    _set_attribute_datetime_on_iso8601_string($stateObj, $attrname, $tv) ;

}

=item _set_attribute_datetime_on_iso8601_string

takes the currState object as a parameter.
it cannot use the main global attribute currState for this, since
this sub is used in 2 different contexts, and the currState could be wrong.

one context this is used in is when parsing the local and global tags, 
the other context it is used in is when copy the global tags to the local tags at the end of parsing.

takes a Datetime attribute name , and a timevalue (tv) (more precisely it taks an iso8601-formatted string)

tries to parse the timevalue string with DateTime::Format::ISO8601->parse_datetime

if DateTime::Format::ISO8601->parse_datetime fails then 
DateTime::Format::ISO8601->parse_datetime will raise an exception, which isn't caught by this 
sub , but should be be caught by the users of this sub.

if it succeeds it sets the attribute_datetime field with the DateTime object.

=cut 


sub _set_attribute_datetime_on_iso8601_string {
    my ($stateObj, $attrname, $tv ) = @_;

    # now check the date :-
    my $dt = DateTime::Format::ISO8601->parse_datetime( $tv );
    $stateObj->setAttribute($attrname,$tv);

    #TODO do we want timezone in the following :-
    my $formatter = new DateTime::Format::Strptime(
        pattern => KHTODO::Config::DateTime_Format(),
    );
    $dt->set_formatter($formatter);

    $stateObj->setAttribute("${attrname}_datetime",$dt);
}

=item _parse_token_HashRef_start_tags

=cut 

sub _parse_token_HashRef_start_tags { 
    # start_tags can be line-or-global level 

    my ( $self, $token ) = @_;
    my $stateObj = $self->currState;
    my $start_regex = $self->curr_start_regex();
    my $tag_detected = 0; 

    ## The noun-y things ( yeah I know dates and complexities are nouns .. but well , you know ;) )

    # so iterate over all the "HashRef" type attributes
    for my $attrname ( $self->getAttributeNamesByType("HashRef")){

        my $parseNew = $self->_parseHashRef(
            $token,
            $self->getAttributeRegexStart($attrname), # the start tag
            \$tag_detected
        );

        # check the -- syntax
        if ( $self->isParsingGlobal 
            && exists $parseNew->{'--'} 
            && scalar keys %$parseNew == 1
        ) {
            $stateObj->setAttributeDefault(${attrname})
        } else {
            # concat the new hashref with the existing hashref :-
            my $hr = { 
                %{$stateObj->getAttribute($attrname)}, # existing hashref
                %{$parseNew} , # the new hashref 
            };
            $stateObj->setAttribute($attrname,$hr); 
        }
        return 1 if $tag_detected;
    };
    return 0; # no tag_detected.
}

=item _parse_token_HashRef_end_tags

=cut 

sub _parse_token_HashRef_end_tags {
    my ( $self, $token ) = @_;

    # only the global tags have any use for "-end"
    return if ! $self->isParsingGlobal;

    my $tag_detected = 0 ; 
    my $start_regex = $self->curr_start_regex();
    my $stateObj = $self->currState;

    # so iterate over all the "HashRef" type attributes
    for my $attrname ( $self->getAttributeNamesByType("HashRef")){
        # so we want to keep all what is in the attribute when we start
        my $keep_rh = $stateObj->getAttribute($attrname);

        # and we want to delete the tags we parsed in.
        my $delete_rh = $self->_parseHashRef(
            $token, 
            $self->getAttributeRegexEnd($attrname), ## the tag-end; 
            \$tag_detected
        );

        # check the -- syntax 
        if ( $self->isParsingGlobal
            && exists $delete_rh->{'--'}
            && scalar keys %$delete_rh == 1
        ) {
            $stateObj->setAttributeDefault(${attrname})
        } else {
            # set the hashref :-
            $stateObj->setAttribute(
                $attrname,
                _rm_items_from_hash( $keep_rh, $delete_rh )
            );
        }

        return 1 if $tag_detected;
    };
    return 0 ; # no tag_detected
}

=item _rm_items_from_hash 

deletes the items in the keep_rh, and 
returns the keep_rh.

the items being deleted from keep_rh are in delete_rh.

=cut

sub _rm_items_from_hash {
    my ($keep_rh, $delete_rh) = @_;

    # TODO maybe turn this into a nice map function

    for my $delit ( keys %{$delete_rh} ){
        if ( exists $keep_rh->{$delit}){
            delete $keep_rh->{$delit};

        }
    }
    return $keep_rh;
}

=item _parseHashRef

This sub parse for all the noun type tags, that populate the hashref attributes.
i.e. this is the parse for 
    persons
    projects
    project_dependencies
    contexts
    places
    names

this sub does 2 things :-
    it returns a hashref.
    it also modifies a  tag_detected_ref variable that indicates what it says.

Now maybe this should have returned the tag_detection
and modified a hashref supplied to it. 

I might change it to that. This is the way it currently evolved.

=cut 
sub _parseHashRef {
    my ( $self, $token , $pattern, $tag_detected_ref ) = @_;

    my $start_regex = $self->curr_start_regex();
    # This is currently made for the HashRef fields, since they are filled up with
    # tag names that have been separated by colons

    if ( my ( @items ) = $token =~ m/${start_regex}${pattern};(\s|[\w\-\:]+)$/i ) {
        my @it;
        for ( my $i=0;$i<@items;$i+=2){
            push @it, split /\:/ , $items[$i+1];
        }
        $$tag_detected_ref = 1;
        my %items  = map { $_ => 1 } @it;
        return \%items;
    }
    return {} ;
}

sub BUILD {
    my ($self) = @_;

    $self->setDefaults();
}

1;
