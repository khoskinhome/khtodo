package KHTODO::State;
use strict;

use KHTODO::Config;

use Moose;
use Moose::Util::TypeConstraints;

use Data::Dumper; # TODO get rid of this when done with debugging.
use DateTime;

# only solitary bool :- 
has isMeeting      => ( is=>'rw', isa=>'Bool' );
has isInformation  => ( is=>'rw', isa=>'Bool' );

# all the dates :- ( + there bools ! ) 
has start_date             => ( is=>'rw', isa=>'Str'  ); # the original Str.
has start_date_datetime    => ( is=>'rw', isa=>'Item' ); #

has end_date               => ( is=>'rw', isa=>'Str'  ); # the original Str.
has end_date_datetime      => ( is=>'rw', isa=>'Item' ); # 

has done                   => ( is=>'rw', isa=>'Bool' ); 
has done_date              => ( is=>'rw', isa=>'Str'  ); # the original Str.
has done_date_datetime     => ( is=>'rw', isa=>'Item' ); #

has waiting                => ( is=>'rw', isa=>'Bool' );
has waiting_date           => ( is=>'rw', isa=>'Str'  ); # the original Str.
has waiting_date_datetime  => ( is=>'rw', isa=>'Item' ); #

# Int fields ( + the bools )  :-
has complexity     => ( is=>'rw', isa=>'Int'  ); # 1 hard, 5 easy
has complexity_set => ( is=>'rw', isa=>'Bool' );
 
has priority       => ( is=>'rw', isa=>'Int'  ); # 1 hard, 5 easy
has priority_set   => ( is=>'rw', isa=>'Bool' ); 

## all the nouns :-

#for the special nouns that represent people :-
has persons    => ( is=>'rw', isa=>'HashRef' );

# some todo items need grouping together, and some parts are dependent on others
# for this we use projects and their dependencies.
has projects   => ( is=>'rw', isa=>'HashRef' );
# to say what the current projects are dependendent on.
has project_dependencies => ( is=>'rw', isa=>'HashRef' ); 

# a catch all for all the other naming of things and concepts.
has names      => ( is=>'rw', isa=>'HashRef' ); # names, nouns, tags .. all essentially the same thing.

## for those special names that are a geographical location :-
has places     => ( is=>'rw', isa=>'HashRef' );

# contexts in GTD parlance are where you can do something.
# i.e. there are somethings that you can do @home, other things @work 
# and yet different things @shops , @train etc .... even @anywhere.
has contexts   => ( is=>'rw', isa=>'HashRef' );

__PACKAGE__->meta->make_immutable;

# TODO change over from "words" to "tags" in the attr_config definitions.

# TODO change over the "type"s to "isa"s in the $attr_config

# TODO there is a lot of duplicated information here, 
# it is in the moose "has XXXX ...." definitons above. 
# I guess this could do with a redesign :-

my $attr_config = {

    isMeeting => {
        words   => [ qw/ m mtg meeting / ],
        has_end => 0,
        type    => 'Bool', 
        default => 0,
        cli     => {
            input=>'Bool',
        },
    },
    isInformation => {
        words   => [ qw/ info information / ],
        has_end => 0,
        type    => 'Bool', 
        default => 0,
#        cli     => 'None', ## no cli options for info at present.
    },
    start_date => {
        words   => [ qw/ start start-by sby start-date / ],
        has_end => 0,
        type    => 'Datetime',
        default => '',
        cli     => {
            input=>'Str',
            format=>'iso8601-before-n-after',
        },
    },
    end_date => {
        words   => [ qw/ end end-by eby end-date / ],
        has_end => 0,
        type    => 'Datetime',
        default => '',
        cli     => {
            input=>'Str',
            format=>'iso8601-before-n-after',
        },
    },
    done_date => {
        words   => [ qw/ done / ],
        has_end => 0,
        type    => 'Datetime',
        default => '',
        also_set_bool => 'done',
        also_set_bool_default_value => 0, 
        cli     => {
            input=>'Str',
            format=>'iso8601-before-n-after-n-bool',
        },
    },
    waiting_date => {
        words   => [ qw/ waiting wait / ],
        has_end => 0,
        type    => 'Datetime',
        default => '',
        also_set_bool => 'waiting', 
        also_set_bool_default_value => 0, 
        cli     => {
            input=>'Str',
            format=>'iso8601-before-n-after-n-bool',
        },
    },
    complexity => {
        words   => [ qw/ ([1-5])c / ],
        has_end => 0,
        type    => 'Int', 
        default => 4,
        also_set_bool => 'complexity_set', 
        also_set_bool_default_value => 0, 
        dont_add_brackets_to_regex => 1,
        cli     => {
            input=>'Int',
            format=>'higher-n-lower',
        },
    },
    priority => {
        words   => [ qw/ ([1-5])p / ],
        has_end => 0,
        type    => 'Int', 
        default => 4,
        also_set_bool => 'priority_set', 
        also_set_bool_default_value => 0, 
        dont_add_brackets_to_regex => 1,
        cli     => {
            input=>'Int',
            format=>'higher-n-lower',
        },
    },
    persons  => { 
        words   => [ qw/ & p per pers person peop people / ],
        has_end => 1, # this can be implied from the type being a hashref...I'm not sure whats the best thing to do . have a has_end conf or rely on the type==hashref..hmmm.
        type    => 'HashRef',
        default => 'empty-hashref', # have to delegate to code to make a new empty one.
    },
    projects => { 
        words   => [ qw/ proj pj project projs pjs projects / ],
        has_end => 1,
        type    => 'HashRef',
        default => 'empty-hashref', # have to delegate to code to make a new empty one.
        cli     => {
            input=>'Str',
            format=>'colon-separated-list',
        },
    },
    project_dependencies => {
        words => [ qw/ projdep pjdp pjd dep deps depends dependencies / ],
        has_end => 1,
        type    => 'HashRef',
        default => 'empty-hashref', # have to delegate to code to make a new empty one.
        cli     => {
            input=>'Str',
            format=>'colon-separated-list',
        },
    },
    names => {
        words => [ qw/ n nm name noun nms names nouns/ ],
        has_end => 1,
        type    => 'HashRef',
        default => 'empty-hashref', # have to delegate to code to make a new empty one.
        cli     => {
            input=>'Str',
            format=>'colon-separated-list',
        },
    },
    places => {
        words => [ qw/ plc place places loc location locs locations / ],
        has_end => 1,
        type    => 'HashRef',
        default => 'empty-hashref', # have to delegate to code to make a new empty one.
        cli     => {
            input=>'Str',
            format=>'colon-separated-list',
        },
    },
    contexts => {
        words => [ qw/ @ cont context contexts / ],
        has_end => 1,
        type    => 'HashRef',
        default => 'empty-hashref', # have to delegate to code to make a new empty one.
        cli     => {
            input=>'Str',
            format=>'colon-separated-list',
        },
    },
};

# TODO someway of making the @ and & work with the trailing semicolon , at least on line-level-local tagging.

# build the regex for the start and end tags.
for my $attrname ( keys %{$attr_config} ) {
    my $pck = $attr_config->{$attrname};

    # glue the words together to make the regex
    $pck->{regex_start} = join ( "|" , @{$pck->{words}});


    $pck->{regex_start} = "(".$pck->{regex_start}.")" if ! $pck->{dont_add_brackets_to_regex};

    if ($pck->{has_end}){ 
        # glue the words together to make the regex
        $pck->{regex_end} = join ( "-end|" , @{$pck->{words}});
        $pck->{regex_end} .= '-end';
        $pck->{regex_end} = "(".$pck->{regex_end}.")" if ! $pck->{dont_add_brackets_to_regex};
    }
}

=item getAttributeNamesByType

this is needed when parsing the tokens for the various regexes.
The type of parsing and what it does with the results depends on the "type".

=cut 

sub getAttributeNamesByType {
    my ($self, $type) = @_;
    my @ret;

    for my $attrname (keys %{$attr_config}){
        push @ret, $attrname if $attr_config->{$attrname}{type} eq $type;
    }
    return @ret;
}

=item getAttributeNames

=cut 

sub getAttributeNames {
    my ($self, $type) = @_;

    return keys %{$attr_config};
}


=item getAttributeRegexStart

=cut

sub getAttributeRegexStart {
    my ($self, $attrname) = @_;
    return $attr_config->{$attrname}{regex_start};
}

=item getAttributeRegexEnd

=cut

sub getAttributeRegexEnd {
    my ($self, $attrname) = @_;

    die "no end regex for attribute $attrname\n" 
        if ! $attr_config->{$attrname}{has_end};

    return $attr_config->{$attrname}{regex_end};
}

=item setAttributeHashConcat

get the old contents of an hashref field,
and add all the new contents to.

this is usually used for adding the global-state to the line state

=cut 

sub setAttributeHashConcat {
    my ($self, $attrname,$value) = @_;
    my $existing_rh = $self->getAttribute($attrname);
    $self->setAttribute( $attrname, { %{$existing_rh} , %{$value} });
}

=item setAttribute

=cut

sub setAttribute {
    my ($self, $attrname,$value) = @_;

    my $ret;
    do {
        no strict 'refs';
        my %call = ( call => __PACKAGE__."::$attrname" );
        $ret = $call{call}($self,$value);
    };
    return $ret;
}

=item getAttribute

=cut 

sub getAttribute {
    my ($self, $attrname) = @_;

    my $ret;
    do {
        no strict 'refs';
        my %call = ( call => __PACKAGE__."::$attrname" );
        $ret = $call{call}($self);
    };
    return $ret;
}

sub BUILD {
    my ($self) = @_;

    # TODO could build all the attributes from the attr_config
    # although that maybe slower . 
    # because I'm guessing we wouldn't be able to "__PACKAGE__->meta->make_immutable;"
    #
    # so for the time being the attr info is duplicated in 2 places above 
    # I'll ask it building them here would be slow.
    #
    # for the time being this is a very low priority TODO item.

    $self->setDefaults;
}

=item setDefaults

=cut 

sub setDefaults {
    my ($self) = @_;
    for my $attr ( keys %$attr_config ) {
        $self->setAttributeDefault($attr); 
    }
}

=item setAttributeDefault

=cut 

sub setAttributeDefault {
    # also resets some associated "bool" and "datetime" values to certain attributes.

    my ($self, $attr ) = @_;
    my $pck = $attr_config->{$attr};

    my $value;

    $value = $pck->{default} eq "empty-hashref" ? {} : $pck->{default} ; 

    $self->setAttribute($attr,$value);

    if ( $pck->{also_set_bool} ) {
        $self->setAttribute( $pck->{also_set_bool}, $pck->{also_set_bool_default_value});
    }

    # The Datetime object fields aren't in the attribute config
    # they need resetting too. 
    if ( $pck->{type} eq "Datetime" ) {
        $self->setAttribute("${attr}_datetime", '');
    }
}

=item getAttributeType

=cut 

sub getAttributeType {
    my ($self, $attr ) = @_;
    my $pck = $attr_config->{$attr};
    return $pck->{type};
}

=item getAttributeWords

=cut 

sub getAttributeWords {
    my ($self, $attr ) = @_;
    my $pck = $attr_config->{$attr};
    return $pck->{words};
}

=item attribute_also_set_bool

=cut 

sub attribute_also_set_bool {
    my ($self, $attr ) = @_;
    my $pck = $attr_config->{$attr};

    return $pck->{also_set_bool} || 0 ;

}

#TODO . Think about this !! attrs and associated bool attrs.
=pod 

4 fields have associated bools with them :- 
    waiting_date
    done_date
    complexity
    priority

Now these fields get set at the sametime as say a date might
get set for waiting_date , or a complexity is found. 

This means in the attr_config we only need one definition,
plus an indication that another field gets sets on detection.

This seems possibly like a clunky design, and maybe it is.

It does also work.

And when something needs to iterate over the attr_config's 
all the attr-key names are the ones that have a regex, 

and when the regex matches , it can't set the bool field , if it has one. 

##################

If I put all the 4 bool fields ( waiting, done, complexity_set and priority_set ) in the attr_config, I'd then need to identify that they don't have a regex match. 

The code for the regex detection gets more complicated. Setting the defaults gets a little more complicated.

I think it is easier to have them as associated field in the attr_config, and also get reset to the default when the parent field gets set to default.

This seems to work to me. And I have thought about it !
( even if you think I'm wrong ) 

=cut 
1;
