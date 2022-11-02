#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: test_zone.pl
#
#        USAGE: ./test_zone.pl  
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
#      CREATED: 06/08/2019 03:09:53 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use lib (".");

use TadoREST;
use Data::Dumper;
use JSON;

my $data;
my $json = JSON->new->allow_nonref;

my $tadoObject = TadoREST->new();
$tadoObject->setConfig(${ENV}{PWD}."/tadoConnect.json");

$tadoObject->generateToken();
$data = $tadoObject->me();
my $homeId = $data->{homes}->[0]->{id};

$data = $tadoObject->getHomeZones($homeId);
my $zoneId = $data->[0]->{id};
print "Zone ID: $zoneId\n";

#$data = $tadoObject->getHomeZoneState($homeId,$zoneId);
#$data = $tadoObject->getHomeZoneCapabilities($homeId, $zoneId);
$data = $tadoObject->getHomeZoneOverlay($homeId,$zoneId);
print $json->pretty->encode($data);
#my $settings = {"geoTrackingEnabled"=>"true"};
#if($data->{enabled}==1){
#   print "Early Start is Enabled. Disabling...\n";
#   $settings = {"enabled"=>"false"};
#}else{
#   print "Early Start is Disabled. Enabling...\n";
#}
#$data = $tadoObject->setHomeZoneEarlyStart($homeId,$zoneId,$settings);
#print "Early Start: $data";

my $settings = {
   "setting" => {
      "type" => "HEATING",
      "temperature" => undef,
      "power" => "OFF"
   },
   "termination" => {
      "type" => "MANUAL",
      "typeSkillBasedApp" => "MANUAL",
      "projectedExpiry" => undef
   },
   "type" => "MANUAL"
};
#if($data->{enabled}==1){
#print "Early Start is Enabled. Disabling...\n";
#   $settings = {"enabled"=>"false"};
#}else{
#   print "Early Start is Disabled. Enabling...\n";
#}
$data = $tadoObject->setHomeZoneOverlay($homeId,$zoneId,$settings);


print $json->pretty->encode($data);
