#!/usr/bin/perl
# Usage perl encode.pl 008Recovery003ALL00833333333009AllUpdate0082013010100820201230000 OUT.KEY
my $string = shift;
my $outfile = shift;
open(my $ofh, ">", $outfile) or die $!;
binmode($ofh);

my $stringLength = length($string);

$stringHalfLength = ($stringLength/2);

$string1 = substr($string, 0,  $stringHalfLength);
$string2 = substr($string,  $stringHalfLength,  $stringHalfLength+1);

$string2 = reverse $string2;

for (my $i=0; $i < length($string2); $i++) {
   my $string1Byte = ord(substr($string1, $i, 1)) + 0x14;
   my $string2Byte = ord(substr($string2, $i, 1)) + 0x14;
   
   if($i > length($string1)-1) {
      print $ofh chr($string2Byte);
   } else {
      print $ofh chr($string2Byte), chr($string1Byte);
   }
   
}
 
print "\n";

close $ofh;
