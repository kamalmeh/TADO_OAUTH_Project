#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: testGetAppUsersRelativePositions.pl
#
#        USAGE: ./testGetAppUsersRelativePositions.pl  
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
#      CREATED: 06/10/2019 03:13:01 PM
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
my $json = JSON->new->allow_nonref;

my $myTado = TadoREST->new();
$myTado->setConfig("$ENV{PWD}/tadoConnect.json");

$data = $myTado->getAppUsersRelativePositions();

print $json->pretty->encode($data);
