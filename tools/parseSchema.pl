#! /usr/bin/perl
#---------------------------------------------------------------------
# Parse the sample data for QBXML
#
# Copyright 2010 Christopher J. Madsen
#
# Run as: parseSchema.pl qbxmlops80.xml qbxmlso80.xml
#---------------------------------------------------------------------

use strict;
use warnings;
use 5.008;

my @inTag;
my @children;
my %childElements = ( QBXML => [qw( SignonMsgsRq QBXMLMsgsRq )]);
my %mayRepeat;

sub printChildren
{
  my ($tag, $childList) = @_;

  print "  $tag => [qw(\n";
  print "    $_\n" for @$childList;
  print "  )],\n";
} # end printChildren

while (<>) {
  next unless /\S/;
  next if /^\s*<!--.*-->\s*$/;
  next if /^<\?/;

  if (m"^\s*</(\w+)>") {
    my $tag = $1;
    die "Expected </$inTag[-1]>, found </$tag>" unless $tag eq $inTag[-1];
    if (@inTag > 1 and $inTag[1] =~ /Rq$/ and $tag ne 'QBXMLMsgsRq') {
      if ($childElements{$tag} and
          "@{ $childElements{$tag} }" ne "@{ $children[-1] }") {
        print "WARNING mismatch (@inTag):\n";
        printChildren($tag => $children[-1]);
      } else {
        $childElements{$tag} = $children[-1];
      }
    }
    pop @inTag;
    pop @children;
  } else {
    my $tag;

    my $repeats = /<!--.*\bmay rep.*-->/;
    my $childList = $children[-1];

    if (m"^\s*<(\w+)>.*</\1>") {
      $tag = $1;
    } elsif (m"^\s*<(\w+)\b[^>]*/>") { # Empty tag
      $tag = $1;
    } elsif (/^\s*<(\w+)/) {
      $tag = $1;

      push @inTag, $tag;
      push @children, [];
    } else {
      die "Unknown line $_";
    }

    push @$childList, $tag;
    $mayRepeat{$tag} = 1 if $repeats;
  }

} # end while <>

print "\n\nour %childElements = (\n";
printChildren($_ => $childElements{$_}) for sort keys %childElements;
print ");\n";

print "\nour %mayRepeat = map { \$_ => 1 } qw(\n";
print "  $_\n" for sort keys %mayRepeat;
print ");\n";
