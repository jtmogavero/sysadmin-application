#!/usr/bin/perl
# Molar Volume Calculator
# by Jason Mogavero
# Perl CGI Library Copyright © 1998 Steven E. Brenner / cgi-lib@pobox.com
# Web page front end for this perl script is located at the URL:
# http://clem.mscd.edu/~mogavero/mvol.html
#


require "cgi-lib.pl";
print "\n\n";


MAIN: {
&ReadParse(*input);
print &HtmlTop;
if (&ProcessForm) {
	&FindVol;
	&PrintResults;
} else {
&EndScript;
print &HtmlBot;
}
}


sub ProcessForm {


# This first  if statement checks to see if the user selected a pre-formatted gas or
# entered their own gas...since we're disabling the text box with the pre-
# formatted gases, we need to use the hidden values or else we get divide
# by zero errors because the diabled box values won't pass even though they
# are displayed  (flaw in HTML standards =P)


if ($input{'usehidden'}) {
	$tc = $input{'tchidden'};
	$pc = $input{'pchidden'};
	$gasname = $input{'gnhidden'};
	}
	else {
	$tc = $input{'tcbox'};
	$pc = $input{'pcbox'};
	$gasname = $input{'gasname'};
	}
	


# Now we check the validity of form data.  We're looking for zero, negatives, or
# non-alpha entries and if we find them, we bomb out with an error

@vars = ($tc, $pc, $input{'temp'}, $input{'pressure'});
for $j (0..3) {
	if ($vars[$j] <= 0) {
		$bleep = $j;
		return 0;
		last;
	} 
}
	return 1;
}



sub EndScript {

# This routine ends the script with an error message due to invalid data

	print "You have entered an inappropriate value for a temperature or pressure.  These must be numbers only and cannot be negative, nor can they be zero. \n <br>";
	print "The inappropriate value you entered was $vars[$bleep] \n <br><br>";
	print "<a href=\"http://clem.mscd.edu/~mogavero/mvol.html\">Return to molar volume calculator</a> and try again";
}



sub FindVol {


# This routine calculates the molar volume by first estimating the
# molar volume using ideal gas equation (PVm = RT) and recalculating
# the real molar volume using the ideal molar volume as "V" in the Van
# der Waals equation.  It then resubstitutes the new "real" molar volume
# and calculates again, repeating until the difference between Vcalc and
# Videal is insignificant.  (in this case 10E-6 difference)


# First things first, set the gas constant to the value we need to use
# and calculate the Van der Waals A nd B constants

use constant GASCONSTANT_R => 0.0820575;
$vdwa = (27 * $tc * $tc * GASCONSTANT_R * GASCONSTANT_R)   / (64 * $pc);
$vdwb = (GASCONSTANT_R * $tc) / (8 * $pc);


# Now we estimate the molar volume by using the  ideal gas equation 

$mvol = (GASCONSTANT_R * $input{'temp'}) / $input{'pressure'};



# Now I assign the ideal volume to the temporary volume place holder for use
# in the Van der Waals equation and initialize the loop counter

$oldvol = $mvol;
$i = 0;


# This is the main calculation...it takes the temporary volume variable and
# runs it through the van der waals equation to find a better molar volume, 
# then compares the two to see how much of a difference it made.  
# If the difference is less than 10E-6, it drops out and accepts the volume
# as the real molar volume, otherwise it reassigns the real volume to be the 
# new temporary volume and reiterates.  I've set a max numbner of iterations
# to be 100, though it will never reach that, this equation converges
# rapidly.

while ($i <= 100) {
	$i++;
	$newvol = (GASCONSTANT_R * $input{'temp'}) / ($input{'pressure'} + ($vdwa / ($oldvol * $oldvol))) + $vdwb;
	$accuracy = abs ($newvol - $oldvol);
	if ($accuracy <= 0.000001) {
		last;
	}	
	else {
		$oldvol = $newvol;
	}
}
}




sub PrintResults {

#Pretty obvious....this prints out the results of the calculation.

print "The gas you chose was $gasname \n <br>";
print "The Tc value used was $tc K \n <br>";
print "The Pc value used was $pc atm. \n <br>";
print "The temperature you entered was $input{'temp'} K \n <br>";
print "The pressure you entered was $input{'pressure'} atm. \n <br>";
print "<br>";
print "The value for Van der Waals A is $vdwa L<sup>2</sup> atm / mol<sup>2</sup> \n <br>";
print "The value for Van der Waals B is $vdwb L / mol \n <br>";
print "<br><br>";
if ($i >= 100) {
	print "<h1>NOT CONVERGED in $i iterations</h1><br> \n";
	} else {	
	print "The molar volume of the gas is $newvol L / mol<br>";
	print "The calculation completed in $i iterations \n <br>";
	}

print "<br><br><hr><br>";
print "<a href=\"http://clem.mscd.edu/~mogavero/mvol.html\">Return to molar volume calculator</a>";
}

