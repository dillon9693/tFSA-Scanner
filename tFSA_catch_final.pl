#!/usr/bin/perl
#Dillon Kerr
# tFSA Scanner
# Reads inputted signal data and determines how many blockades
# are present and where their start indices are located

use strict;
use FileHandle;
my $input_fh = new FileHandle "gendata2";

my @data;
my $data_index=-1;
#Read in data
while (<$input_fh>) {
    $data_index++;
    chop;
    $data[$data_index]=$_;
}

my $data_length = scalar(@data);
my $sig_count;
my $index; my $inner_index;
my $past_count=0;
my $last_index=0;

#Iterate through each data entry in input file
for $index (0..$data_length-1) {
    my $value = $data[$index];
    my $past_avg=0;
	#Calculate average of previous five data points
    if ($index>4) {
        $past_avg += $data[$index-5];
        $past_avg += $data[$index-4];
        $past_avg += $data[$index-3];
        $past_avg += $data[$index-2];
        $past_avg += $data[$index-1];
    }
    $past_avg=$past_avg/5;
	
    my $start_drop_percentage=0.6;
	#Check if value is less than 0.6 * previous avg.
    if ($value<$start_drop_percentage*$past_avg) {
        if ($index>$last_index+20) {
			#Check if next five values are also dropped below 0.8 * past avg.
			for $inner_index ($index+1..$index+5) {
				if($data[$inner_index] < ($start_drop_percentage+.2)*$past_avg) {
					$past_count++;
				}
				#If so, output start index and increment signal counter
				if($past_count >= 5) {
					print "possible start region at index=$index\n";
					$sig_count++;
					$past_count = 0;
				}
			}
        }
        $last_index=$index;
    }
}
print "signal count = $sig_count\n";