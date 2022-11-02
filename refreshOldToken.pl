#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: refreshOldToken.pl
#
#        USAGE: ./refreshOldToken.pl  
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
#      CREATED: 06/10/2019 10:49:36 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use lib (".");
use JSON;
use TadoREST;

my $data;
my $json = JSON->new->allow_nonref;

my $myTado = TadoREST->new();

$myTado->setConfig("tadoConnect.json");

$data = $myTado->getHomeDevices(236761);

print $json->pretty->encode($data);
