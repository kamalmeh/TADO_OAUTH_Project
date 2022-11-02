#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: testTadoREST.pl
#
#        USAGE: ./testTadoREST.pl  
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
#      CREATED: 06/05/2019 09:53:16 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;

use lib (".");

use TadoREST;

my $data;
my $homeId;
my $mobileDeviceId;

my $tadoObject = new TadoREST();
$tadoObject->setConfig(${ENV}{PWD}."/tadoConnect.json");

$tadoObject->generateToken();
$data = $tadoObject->me();
print Dumper($data);
$homeId=$data->{homes}->[0]->{id};
print "Home ID: ".$homeId."\n";

#$data = $tadoObject->getHome($homeId);
#print Dumper($data);
#$data = $tadoObject->getHomeDevices($homeId);
#print Dumper($data);
#$data = $tadoObject->getHomeWeather($homeId);
#print Dumper($data);
$data = $tadoObject->getHomeMobileDevices($homeId);
$mobileDeviceId = $data->[0]->{id};
print Dumper($data);

$data = $tadoObject->getHomeMobileDevices($homeId);
$mobileDeviceId = $data->[0]->{id};
print Dumper($data);

$data = $tadoObject->getHomeMobileDeviceSettings($homeId,$mobileDeviceId);
print Dumper($data);

my $settings = {"geoTrackingEnabled"=>"true"};
if($data->{geoTrackingEnabled}==1){
   print "Geo Tracking is Enabled. Disabling...\n";
   $settings = {"geoTrackingEnabled"=>"false"};
}else{
   print "Geo Tracking is Disabled. Enabling...\n";
}
$tadoObject->setHomeMobileDeviceSettings($homeId,$mobileDeviceId,$settings);
$data = $tadoObject->getHomeMobileDeviceSettings($homeId,$mobileDeviceId);
print "Geo Tracking: $data->{geoTrackingEnabled}\n";
print Dumper($data);

