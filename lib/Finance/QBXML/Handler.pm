#---------------------------------------------------------------------
package Finance::QBXML::Handler;
#
# Copyright 2010 Christopher J. Madsen
#
# Author: Christopher J. Madsen <perl@cjmweb.net>
# Created: February 2, 2010
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either the
# GNU General Public License or the Artistic License for more details.
#
# ABSTRACT: SAX handler for parsing qbXML files
#---------------------------------------------------------------------

use 5.008;
use warnings;
use strict;
use Carp;
use Finance::QBXML ();
use Scalar::Util 'reftype';
#use Smart::Comments '###';

#=====================================================================
# Package Global Variables:

our $VERSION = '0.01';

#=====================================================================
# Package Finance::QBXML::Handler:

sub new
{
  my $class = shift;

  bless {}, $class;
} # end new

#---------------------------------------------------------------------
sub start_document
{
  my ($self) = @_;

  $self->{elts} = [ $self->{doc} = {} ];
} # end start_document

#---------------------------------------------------------------------
sub processing_instruction
{
  my ($self, $v) = @_;

  if ($v->{Target} eq 'qbxml') {
    if ($v->{Data} =~ /version="([\d.]+)"/) {
      $self->{doc}{_version} = $1;
    } else {
      carp "Unable to parse version from '$v->{Data}'";
    }
  }
} # end processing_instruction

#---------------------------------------------------------------------
sub start_element
{
  my ($self, $v) = @_;

  return if $v->{LocalName} eq 'QBXML'; # Ignore root

  my $elts = $self->{elts};
  my $attrs = $v->{Attributes};

  ### start: $v->{LocalName}

  my $newNode;

  $newNode = { map { @$_{qw(LocalName Value)} } values %$attrs }
      if %$attrs;

  $newNode->{_} = []
      if $Finance::QBXML::multipleChildren{$v->{LocalName}};

  croak "No elts" unless @$elts;

  my $e = $elts->[-1];
  my $reftype = reftype($e);

  if ($reftype eq 'SCALAR') {
    croak "Mixed data" if defined $$e and $$e =~ /\S/;
    $e = $elts->[-1] = $$e = {};
  }

  if ($reftype eq 'ARRAY') {
    $newNode ||= {};
    $newNode->{_tag} = $v->{LocalName};
    push @$e, $newNode;
  } elsif ($Finance::QBXML::mayRepeat{$v->{LocalName}}) {
    push @{ $e->{ $v->{LocalName} } }, $newNode;
    $newNode ||= \$e->{ $v->{LocalName} }[-1];
  } else {
    croak "Unexpected repeat of <$v->{LocalName}>"
        if exists $e->{ $v->{LocalName} };
    $e->{ $v->{LocalName} } = $newNode;
    $newNode ||= \$e->{ $v->{LocalName} };
  }

  $newNode = $newNode->{_} if reftype($newNode) eq 'HASH' and $newNode->{_};

  push @$elts, $newNode;
} # end start_element

#---------------------------------------------------------------------
sub characters
{
  my ($self, $v) = @_;

  my $elt = $self->{elts}[-1];

  if (reftype($elt) eq 'SCALAR') {
    $$elt .= $v->{Data};
  } elsif ($v->{Data} =~ /\S/) {
    croak "Mixed data";
  }

  ### characters: $v->{Data}
} # end characters

#---------------------------------------------------------------------
sub end_element
{
  my ($self, $v) = @_;

  return if $v->{LocalName} eq 'QBXML'; # Ignore root

  ### end: $v->{LocalName}

  pop @{ $self->{elts} };
} # end end_element

#---------------------------------------------------------------------
sub end_document
{
  my ($self) = @_;

  delete $self->{elts};
  # This value will be returned by the parser:
  return delete $self->{doc};
} # end end_document

#=====================================================================
# Package Return Value:

1;

__END__

=head1 SYNOPSIS

    use Finance::QBXML;

    my $qb = Finance::QBXML->new;

    $hashRef = $qb->get_parser->parse_string($xml_string);


=head1 DESCRIPTION

Finance::QBXML::Handler is a SAX2.1 ContentHandler for qbXML
documents.  You don't use it directly; see L<Finance::QBXML> for
documentation.

=for Pod::Coverage
.
