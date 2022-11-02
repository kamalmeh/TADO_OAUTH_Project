#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: testTadoDevice.pl
#
#        USAGE: ./testTadoDevice.pl  
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
#      CREATED: 06/09/2019 12:44:56 PM
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

$data = $myTado->getHomeDevices($homeId);   #returns the Reference to and Array of devices for home.
$deviceId = $data->[1]->{shortSerialNo};
print "Device ID: $deviceId\n";

$data = $myTado->identifyDevice($homeId,$deviceId);
print "Getting Temperature Offset...\n";
$data = $myTado->getTemperatureOffset($deviceId);

my $settings={
   "celsius" => -1.5
};
$data = $myTado->setTemperatureOffset($deviceId,$settings);
print $json->pretty->encode($data)."\n";

