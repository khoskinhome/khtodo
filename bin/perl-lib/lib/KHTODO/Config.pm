package KHTODO::Config;

sub DateTime_Local { 
    return "Europe/London";
    #return "UTC";
};


sub DateTime_Format {
    return '%Y-%m-%dT%T';
}

1;
