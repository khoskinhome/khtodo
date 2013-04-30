package KHTODO::Action;


use Getopt::Long;


use Moose;


#__PACKAGE__->meta->make_immutable;



my $cli_opts = {};

#sub parse_cli_options {
=pod

my $data   = "file.dat";
my $length = 24;
my $verbose;
GetOptions ("length=i" => \$length,    # numeric
            "file=s"   => \$data,      # string
            "verbose"  => \$verbose)   # flag
or die("Error in command line arguments\n");
=cut
#}




1;
