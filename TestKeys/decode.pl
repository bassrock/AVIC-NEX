#!/usr/bin/perl
# usage perl decode.pl TEST.KEY

my $filename = (shift);

open(my $fh, $filename) or die $!;

binmode($fh);

my $cnt = 0;

my $encodeString = "";
my $otherString = "";

while (read($fh, my $byte, 1))
{
	if ($cnt % 2 == 1)
	{
		if (ord($byte) > 51)
		{
			$byte = ord($byte) - 20;
		}
		else
		{
			$byte = ord($byte) + 76;
		}
		$encodeString = $encodeString.chr($byte);
	} else {
		if (ord($byte) > 51)
		{
			$byte = ord($byte) - 20;
		}
		else
		{
			$byte = ord($byte) + 76;
		}
		$otherString = chr($byte).$otherString;
	}
	$cnt++;
}

print $encodeString.$otherString;
print "\n";

close $fh;