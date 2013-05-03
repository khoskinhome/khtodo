package KHTODO::Action::Add;
use strict;

=head1 NAME

KHTODO::Action::Add;

=head1 VERSION

Version 0.01

=cut
use Mouse;

use KHTODO::Action;

extends 'KHTODO::Action';


__PACKAGE__->meta->make_immutable;


=head1 SYNOPSIS

    my $obj = KHTODO::Action::Add->new();
    $obj->run();

=head1 EXPORT

nothing exported

=head1 SUBROUTINES/METHODS

=head2 run

called by the main action dispatcher.

=cut

sub run {
    my ($self) = @_;

    die "not yet implemented\n";


};

sub get_secondary_actions {


}


sub BUILD {
    

}

=head1 AUTHOR

Karl Hoskin, C<< <cpan at khoskin.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-khtodo at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=KHTODO>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc KHTODO::Action::Add


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=KHTODO>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/KHTODO>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/KHTODO>

=item * Search CPAN

L<http://search.cpan.org/dist/KHTODO/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Karl Hoskin.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1;
