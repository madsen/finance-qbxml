#---------------------------------------------------------------------
package tools::FQTemplate;
#
# Copyright 2009 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created:  16 Oct 2009
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# ABSTRACT: Pod::Loom template for Finance-QBXML
#---------------------------------------------------------------------

our $VERSION = '0.01';

use 5.008;
use Moose;
extends 'Pod::Loom::Template::Default';
with 'Pod::Loom::Role::Extender';

sub remap_sections { {
  AUTHOR => [qw[ AUTHOR ACKNOWLEDGMENTS ]],
} }

#---------------------------------------------------------------------
sub section_ACKNOWLEDGMENTS
{
  my ($self, $title) = @_;

  return <<"END ACKNOWLEDGMENTS";
\=head1 $title

I'd like to thank Micro Technology Services, Inc.
L<http://www.mitsi.com>, who sponsored development of
PostScript-Report, and fREW Schmidt, who recommended me for the job.
It wouldn't have happened without them.
END ACKNOWLEDGMENTS
} # end section_ACKNOWLEDGMENTS

#=====================================================================
# Package Return Value:

no Moose;
__PACKAGE__->meta->make_immutable;
1;
