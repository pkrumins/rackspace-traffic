#!/usr/bin/perl
#
# Parse the Rackspace invoice CSV file and report the outgoing bandwidth
# usage for the cloud servers. More info at:
#
# http://www.catonmat.net/blog/rackspace-cloud-traffic-summary/
#

use warnings;
use strict;

use Text::CSV;

# Rackspace Invoice CSV columns
use constant ACCOUNT_NO => 0;
use constant BILL_NO => 1;
use constant BILL_START_DATE => 2;
use constant BILL_END_DATE => 3;
use constant SERVICE_TYPE => 4;
use constant EVENT_TYPE => 5;
use constant EVENT_START_DATE => 6;
use constant EVENT_END_DATE => 7;
use constant IMPACT_TYPE => 8;
use constant QUANTITY => 9;
use constant UOM => 10;
use constant RATE => 11;
use constant AMOUNT => 12;
use constant USAGE_RECORD_ID => 13;
use constant DC_ID => 14;
use constant REGION_ID => 15;
use constant RES_ID => 16;
use constant RES_NAME => 17;
use constant ATTRIBUTE_1 => 18;
use constant ATTRIBUTE_2 => 19;
use constant ATTRIBUTE_3 => 20;

my $csvFile = shift or die "usage: $0 <csv file>";
my $csv = Text::CSV->new;

open my $file, '<', $csvFile or die "unable to open $csvFile: $!";

my %bandwidth;
while (my $row = $csv->getline($file)) {
    if ($row->[EVENT_TYPE] =~ /Server BWOUT/) {
        $bandwidth{$row->[RES_NAME]} += $row->[QUANTITY];
    }
}

for my $server (sort {$bandwidth{$b} <=> $bandwidth{$a} } keys %bandwidth) {
    printf "%s: %.02f\n", $server, $bandwidth{$server}
}

