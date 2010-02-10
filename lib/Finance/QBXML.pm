#---------------------------------------------------------------------
package Finance::QBXML;
#
# Copyright 2010 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: February 2, 2010
# $Id: Module.pm 2035 2008-06-25 23:41:21Z cjm $
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# [Description]
#---------------------------------------------------------------------

use 5.008;
use warnings;
use strict;
use Carp;

use Scalar::Util 'reftype';
use XML::Writer;

#=====================================================================
# Package Global Variables:

our $VERSION = '0.01';

our %childElements = (
  QBXML => [qw(
    SignonMsgsRq
    QBXMLMsgsRq
  )],
  SignonMsgsRq => [qw(
    SignonAppCertRq
    SignonDesktopRq
    SignonTicketRq
  )],
 SignonAppCertRq => [qw(
    ClientDateTime
    ApplicationLogin
    ConnectionTicket
    InstallationID
    Language
    AppID
    AppVer
  )],
  SignonDesktopRq => [qw(
    ClientDateTime
    ApplicationLogin
    ConnectionTicket
    InstallationID
    Language
    AppID
    AppVer
  )],
  SignonTicketRq => [qw(
    ClientDateTime
    SessionTicket
    AuthID
    InstallationID
    Language
    AppID
    AppVer
  )],
);

our %multipleChildren = map { $_ => 1 } qw(
  QBXMLMsgsRq  QBXMLMsgsRs
);

#=====================================================================
# Package Finance::QBXML:

sub new
{
  my $class = shift;

  bless {}, $class;
} # end new

#---------------------------------------------------------------------
sub formatXML
{
  my ($self, $node) = @_;

  my $buffer;
  open(my $out, '>', \$buffer);

#  print $out qq'<?xml version="1.0" encoding="utf-8"?>\n<?qbxml version="6.0"?>\n';

  my $w = XML::Writer->new(OUTPUT => $out, DATA_MODE => 1, DATA_INDENT => 2,
                           ENCODING => 'utf-8');

  $w->xmlDecl;
  $w->pi(qbxml => 'version="6.0"');
  $self->formatNode($w, QBXML => $node);
  $w->end;
  close $out;

  $buffer;
} # end formatXML

#---------------------------------------------------------------------
sub formatNode
{
  my ($self, $w, $tag, $node) = @_;

  my $reftype = (reftype($node) || '');

  if ($reftype eq 'ARRAY') {
    if ($multipleChildren{$tag}) {
      # One element with multiple children in specified order (using _tag):
      $w->startTag($tag);

      foreach my $n (@$node) {
        my $childTag = $n->{_tag} or croak "No _tag in child of $tag";
        $self->formatNode($w, $childTag => $n);
      }
      $w->endTag($tag);
    } else {
      # Multiple occurences of this tag:
      foreach my $n (@$node) {
        $self->formatNode($w, $tag => $n);
      }
    } # end else not $multipleChildren{$tag}
  } # end if $node is ARRAY
  elsif ($reftype) {
    # An ordinary node formed from a hash reference:
    my (@attrs, $children);

    while (my ($k, $v) = each %$node) {
      if ($k =~ /^[[:lower:]]/) {
        push @attrs, $k, $v;
      } else {
        $children = 1;          # This is a node, not an attribute
        # FIXME check if valid element name?
      }
    } # end while my ($k, $v)

    if (not $children) {
      $w->emptyTag($tag, @attrs);
    } else {
      $w->startTag($tag, @attrs);

      # qbXML requires elements to appear in the correct order:
      foreach my $childTag (@{ $childElements{$tag} }) {
        $self->formatNode($w, $childTag => $node->{$childTag})
            if exists $node->{$childTag};
      } # end foreach $childTag

      $w->endTag($tag);
    } # end else node is not empty
  } # end elsif $node is a (hash) reference
  else {
    $w->dataElement($tag, $node);
  }
} # end formatNode

#---------------------------------------------------------------------
sub time2iso
{
  my ($self, $time) = @_;

  $time = time unless defined $time;

  my @date = gmtime($time);

  sprintf('%d-%02d-%02dT%02d:%02d:%02d',
          $date[5]+1900, $date[4]+1, @date[3,2,1,0]);
} # end time2iso

#=====================================================================
# Package Return Value:

1;

__END__

=head1 NAME

Finance::QBXML - [One line description of module's purpose here]

=head1 VERSION

This document describes $Id: Module.pm 2035 2008-06-25 23:41:21Z cjm $


=head1 SYNOPSIS

    use Finance::QBXML;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.


=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.

Finance::QBXML requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.


=head1 AUTHOR

Christopher J. Madsen  S<< C<< <perl AT cjmweb.net> >> >>

Please report any bugs or feature requests to
S<< C<< <bug-Finance-QBXML AT rt.cpan.org> >> >>,
or through the web interface at
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=Finance-QBXML>


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Christopher J. Madsen

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENSE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
