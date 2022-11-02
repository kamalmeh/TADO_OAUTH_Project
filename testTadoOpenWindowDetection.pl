#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: testTadoOpenwindowDetection
#
#        USAGE: ./testTadoOpenwindowDetection.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 06/10/2019 01:33:44 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use lib (".");
use Data::Dumper;
use JSON;
use TadoREST;

my $data;
my $homeId;
my $deviceId;
my $json = JSON->new->allow_nonref;

my $myTado = TadoREST->new();
$myTado->setConfig("$ENV{PWD}/tadoConnect.json");

$data = $myTado->me();
$homeId = $data->{homes}->[0]->{id};
print "Home ID: $homeId\n";

$data = $myTado->getHomeZones($homeId);   #returns the Reference to and Array of zones for home.
#print $json->pretty->encode($data)."\n";
my $zoneId = $data->[0]->{id};
print "Zone ID: $zoneId\n";

print "Setting OpenWindowDetection...\n";
$data = $myTado->getOpenWindowDetection($homeId,$zoneId);
print $json->pretty->encode($data)."\n";

my $settings={
   "enabled" => "true",
   "timeoutInSeconds" => 900
};
$data = $myTado->setOpenWindowDetection($homeId,$zoneId,$settings);
print $json->pretty->encode($data)."\n";
