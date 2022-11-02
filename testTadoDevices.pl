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

####DEFAULTS############
my $client_id='public-api-preview';
my $client_secret='4HJGRffVR8xb3XdEUQpjgZ1VplJi6Xgw';
my $username='tadoapi@nurfuerspam.de';
my $password='true2019';
my $scope='home.user';
my $AuthURL = qq{https://auth.tado.com/oauth/token};
my $DataURL = qq{https://my.tado.com/api/v2/me};
my $meURL = qq{https://my.tado.com/api/v2/me};
my $QueryURL = qq{https://my.tado.com/api/v2/homes};
my $tokenFile = "/tmp/tadotoken";

my $data;
my $tadoObject = new TadoREST({
		client_id => $client_id,
		client_secret => $client_secret,
		username => $username,
		password => $password,
		scope => $scope,
		auth_url => $AuthURL,
		me_url => $meURL,
		query_url => $QueryURL,
		tokenFile => $tokenFile,
		timestamp => time()+15
	});

$data = $tadoObject->generateToken();
$tadoObject->dumpSelf();
#my $data = $tadoObject->me();
#my $homeId = $data->{homes}[0]->{id};
print Dumper($data);
#$data = $tadoObject->getHome($homeId);
#print Dumper($data);
#$tadoObject->getHomeWeather();
#$tadoObject->getHomeDevices();
#$tadoObject->getHomeInstallations();
#$tadoObject->getHomeUsers();
#$data = $tadoObject->getHomeMobileDevices($homeId);
#print Dumper($data);
#my $mobileDeviceId=$data->[0]->{id};
#print Dumper($data);
#$data = $tadoObject->getHomeMobileDeviceSettings($homeId,$mobileDeviceId);
#print "Geo Tracking: $data->{geoTrackingEnabled}\n";
#my $settings = {"geoTrackingEnabled"=>"true"};
#if($data->{geoTrackingEnabled}==1){
#	print "Geo Tracking is Enabled. Disabling...\n";
#	$settings = {"geoTrackingEnabled"=>"false"};
#}else{
#	print "Geo Tracking is Disabled. Enabling...\n";
#}
#$tadoObject->setHomeMobileDeviceSettings($homeId,$mobileDeviceId,$settings);
#$data = $tadoObject->getHomeMobileDeviceSettings($homeId,$mobileDeviceId);
#print "Geo Tracking: $data->{geoTrackingEnabled}\n";
#print Dumper($data);
