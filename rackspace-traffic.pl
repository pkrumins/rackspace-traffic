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
use constant {
    ACCOUNT_NO => 0,
    BILL_NO => 1,
    BILL_START_DATE => 2,
    BILL_END_DATE => 3,
    SERVICE_TYPE => 4,
    EVENT_TYPE => 5,
    EVENT_START_DATE => 6,
    EVENT_END_DATE => 7,
    IMPACT_TYPE => 8,
    QUANTITY => 9,
    UOM => 10,
    RATE => 11,
    AMOUNT => 12,
    USAGE_RECORD_ID => 13,
    DC_ID => 14,
    REGION_ID => 15,
    RES_ID => 16,
    RES_NAME => 17,
    ATTRIBUTE_1 => 18,
    ATTRIBUTE_2 => 19,
    ATTRIBUTE_3 => 20
};

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

