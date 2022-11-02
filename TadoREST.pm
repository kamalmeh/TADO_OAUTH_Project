package TadoREST;
#===============================================================================
#
#         FILE: TadoREST
#
#  DESCRIPTION: This program is a utility program to use tado authentication API
#  				Service. The program first requests the authentication token and
#  				using the token data, it can retrive devices.
#
# REQUIREMENTS: Below modules should be pre-installed.
# 				HTTP::Request::Common
# 				HTTP::Headers
# 				LWP::UserAgent
# 				JSON
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Kamal Mehta,
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 06/06/2019
#     REVISION: 06/06/2019
#===============================================================================

use strict;
use warnings;
use utf8;

use HTTP::Request::Common qw (POST GET PUT HEAD PATCH DELETE);
use HTTP::Headers;
use LWP::UserAgent;
use JSON;
use Getopt::Long;
use Data::Dumper;

#Request data for HTTP Request & Response
our $Request=undef;	
our $Response=undef;

#Empty variable for LWP User Agent for sending HTTP Request
my $UserAgent = undef;

#------------------------------------------------------------------------------
#  FUNCTION NAME: new
#      ARGUMENTS: Accepts Hash Reference containing below parameters	
#      				|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | client_id		|scalar value			|
#      				|Argument-02 | client_secret	|scalar value			|
#      				|Argument-03 | username			|scalar value			|
#      				|Argument-04 | password			|scalar value			|
#      				|Argument-05 | scope			|scalar value 			|
#      				|Argument-06 | tokenFile		|scalar value			|
#      				|Argument-07 | auth_url			|scalar value			|
#      				|Argument-08 | me_url			|scalar value			|
#      				|Argument-09 | query_url		|scalar value			|
#					|=======================================================|
#      PROTOTYPE: TadoREST->new({})
#   RETURN VALUE: Reference to TadoREST API object
#    DESCRIPTION: Instantiate the TadoREST API Class
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/07/2019
#------------------------------------------------------------------------------
sub new{
	my ($class,$args) = @_;
	my $self = bless {
		client_id		=> $args->{client_id} || "",
		client_secret	=> $args->{client_secret} || "",
		username		=> $args->{username} || "",
		password		=> $args->{password} || "",
		scope			=> $args->{scope} || "",
		tokenFile		=> $args->{tokenFile} || "",
		agent			=> LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 },protocols_allowed => ['https','http'],),
		auth_url		=> $args->{auth_url} || "",
		me_url			=> $args->{me_url} || "",
		query_url		=> $args->{query_url} || ""
	}, $class;
	return $self;
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setConfig
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | configPath		|scalar value			|
#					|=======================================================|
#      PROTOTYPE: setConfig(configPath)
#   RETURN VALUE: None
#    DESCRIPTION: This function sets defaults from the configuration file
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/07/2019
#------------------------------------------------------------------------------
sub setConfig{
	my ($self, $config) = @_;
	my $content;

	open(my $cfgFile,"<",$config) or die ("ERROR: $!");

	while(<$cfgFile>){
		$content.=$_;
	}

	close($cfgFile);
	my (undef,undef,undef,undef,undef,undef,undef,undef,
            undef,undef,$ctime,undef,undef)
               = stat($config);

	my $args = decode_json($content);
	$self->{client_id}       = $args->{client_id};
	$self->{client_secret}   = $args->{client_secret};
	$self->{username}        = $args->{username};
	$self->{password}        = $args->{password};
	$self->{scope}           = $args->{scope};
	$self->{tokenFile}       = $args->{tokenFile};
    $self->{agent}           = $self->{agent} || LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 },protocols_allowed => ['https','http'],);
    $self->{auth_url}        = $args->{auth_url},
    $self->{me_url}          = $args->{me_url},
    $self->{timestamp}		 = $ctime,
    $self->{expires_in}	 	 = int($args->{expires_in}),
    $self->{query_url}       = $args->{query_url}
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: dumpSelf
#      ARGUMENTS: None
#      PROTOTYPE: dumpSelf()
#   RETURN VALUE: None
#    DESCRIPTION: This funtion prints useful information
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub dumpSelf{
	my ($self) = @_;
	printf("%-50s\n","Parameter Values");
	print("-"x50);
	printf("\n");
	printf("%20s = %-50s\n","Auth_Url",$self->{auth_url});
	printf("%20s = %-50s\n","Query_Url",$self->{query_url});
	printf("%20s = %-50s\n","Client_Id",$self->{client_id});
	printf("%20s = %-50s\n","Username",$self->{username});
	printf("%20s = %-50s\n","Scope",$self->{scope});
	printf("%20s = %-50s\n","Token File",$self->{tokenFile});
	printf("-"x50);
	printf("\n");
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: requestResponse
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | HTTP_Request		|scalar value			|
#					|=======================================================|
#      PROTOTYPE: requestResponse(HTTP_Request)
#   RETURN VALUE: Hash Reference to HTTP Response object
#    DESCRIPTION: This funtion sends HTTP Request and receives the response
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub requestResponse{
	my ($self, $Request) = @_;

	$self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);

    #Decode the received content into Hash
	if($Response->content =~ /^$/ ){
		return {};
	}else{
		return decode_json($Response->content);
	}
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: generateToken
#      ARGUMENTS: None
#      PROTOTYPE: generateToken()
#   RETURN VALUE: None
#    DESCRIPTION: This funtion retrieves the access token
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub generateToken{
	my ($self) = @_;
	my $data = {};
	my $TOKENFILE;

	if(open($TOKENFILE,"<",$self->{tokenFile})){
		my $content;
		while(<$TOKENFILE>){
        	$content.=$_;
    	}
    	close($TOKENFILE);
		my $previousToken = decode_json($content);
		$self->setToken($previousToken);
		my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
            $atime,$mtime,$ctime,$blksize,$blocks)
               = stat($self->{tokenFile});
		$self->{timestamp}=$ctime;
		
	}

	#if(defined($self->{'access_token'})){
	if($self->validateToken()==1){
		print "Generating Fresh Token\n";
		$data = {
			client_id => $self->{client_id},
			client_secret => $self->{client_secret},
            username => $self->{username},
            password => $self->{password},
            scope => $self->{scope},
            grant_type=>'password'
        };
		$Request = POST($self->{auth_url},$data);
		$Response = $self->{agent}->request($Request);
    	$data = decode_json($Response->content);

#write token data in the file, it can be read by another program
		open($TOKENFILE,">",$self->{tokenFile}) or die("ERROR: $!");
		print $TOKENFILE $Response->content."\n";
		close($TOKENFILE);

		$self->setToken($data);
	}
	$self->setHeaders();
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: refreshToken
#      ARGUMENTS: None
#      PROTOTYPE: refreshToken()
#   RETURN VALUE: None
#    DESCRIPTION: This funtion refreshes the access token and write to file
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/07/2019
#------------------------------------------------------------------------------
sub refreshToken{
	my ($self) = @_;
	my $TOKENFILE;

	if(open($TOKENFILE,"<",$self->{tokenFile})){
        my $content;
        while(<$TOKENFILE>){
            $content.=$_;
        }
        close($TOKENFILE);
        my $previousToken = decode_json($content);
        $self->setToken($previousToken);
        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
            $atime,$mtime,$ctime,$blksize,$blocks)
               = stat($self->{tokenFile});
        $self->{timestamp}=$ctime;

    }

	my $data = {
		'refresh_token'=>$self->{'refresh_token'},
		'grant_type'=>'refresh_token',
    };
	$data->{'client_id'}=$self->{client_id};
	$data->{'client_secret'}=$self->{client_secret};

	$Request = POST($self->{auth_url},$data);
	$Response = $self->{agent}->request($Request);
    $data = decode_json($Response->content);

#write token data in the file, it can be read by another program
	open($TOKENFILE,">",$self->{tokenFile}) or die("ERROR: $!");
	print $TOKENFILE $Response->content."\n";
	close($TOKENFILE);

	$self->setToken($data);
	$self->setHeaders();
}
#------------------------------------------------------------------------------
#  FUNCTION NAME: setToken
#      ARGUMENTS:   |=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | tokenData		|Hash Reference			|
#					|=======================================================|
#      PROTOTYPE: setToken(tokenData)
#   RETURN VALUE: None
#    DESCRIPTION: This funtion sets the token info in TadoREST object
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub setToken{
	my ($self, $tokenData) = @_;
	$self->{access_token}	= $tokenData->{access_token};
	$self->{token_type}		= $tokenData->{token_type};
	$self->{refresh_token}	= $tokenData->{refresh_token};
	$self->{expires_in}		= int($tokenData->{expires_in});
	$self->{timestamp}		= time();
	$self->{jti}			= $tokenData->{jti};
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getToken
#      ARGUMENTS: None
#      PROTOTYPE: getToken()
#   RETURN VALUE: token
#    DESCRIPTION: This funtion returns current token
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getToken{
	my ($self) = @_;
	return $self->{access_token};
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeMobileDevices
#      ARGUMENTS: None 	
#      PROTOTYPE: setHeaders()
#   RETURN VALUE: None
#    DESCRIPTION: This funtion sets headers for HTTP requests
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub setHeaders{
	my ($self) = @_;
	$self->{headers} = HTTP::Headers->new();
	$self->{headers}->header("Content-Type"=>"application/json");
	$self->{headers}->header("charset"=>"UTF-8");
	$self->{headers}->header("Authorization" => "$self->{'token_type'} $self->{'access_token'}");
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: validateToken
#      ARGUMENTS: None
#      PROTOTYPE: validateToken()
#   RETURN VALUE:
#                   0 if Valid
#                   1 if expired
#    DESCRIPTION: This function validates the existing token
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/07/2019
#------------------------------------------------------------------------------
sub validateToken{
    my ($self) = @_;

    my $diff = int(time() - $self->{timestamp});
    if($diff >= $self->{expires_in}){
        #print "Token expired - $diff\n";
        return 1;
        #$self->generateToken();
    }else{
        #print "token is still valied - $diff\n";
        return 0;
    }
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: me
#      ARGUMENTS: None
#      PROTOTYPE: me()
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION: This funtion retrieves info for current client's access data
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub me{
	my ($self) = @_;

	if($self->validateToken == 1){
		$self->refreshToken();
	}

	$Request = GET($self->{me_url});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHome
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#					|=======================================================|
#      PROTOTYPE: getHome(homeId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION: This function retrives the home details
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHome {
	my ($self,$homeId) = @_;
	if($self->validateToken == 1){
		$self->refreshToken();
	}
	$Request = GET(qq{$self->{query_url}/$homeId});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZones
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZones(homeId)
#   RETURN VALUE: ARRAY Reference to Json Response
#    DESCRIPTION: This function retrives the home Zones details
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHomeZones {
    my ($self,$homeId) = @_;
    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request = GET(qq{$self->{query_url}/$homeId/zones});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeWeather
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#					|=======================================================|
#      PROTOTYPE: getHomeWeather(homeId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION: This funtion retrieves the home weather
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHomeWeather{
	my ($self,$homeId) = @_;
	if($self->validateToken == 1){
		$self->refreshToken();
	}
	$Request = GET(qq{$self->{query_url}/$homeId/weather});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeDevices
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#					|=======================================================|
#      PROTOTYPE: getHomeDevices(homeId)
#   RETURN VALUE: ARRAY reference to Json Response
#    DESCRIPTION: This funtion retrieves the home devices 
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHomeDevices {
	my ($self,$homeId) = @_;

	if($self->validateToken == 1){
		$self->refreshToken();
	}

	$Request = GET(qq{$self->{query_url}/$homeId/devices});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeInstallations
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#					|=======================================================|
#      PROTOTYPE: getHomeInstallations(homeId)
#   RETURN VALUE: ARRAY reference to Json Response
#    DESCRIPTION: Retrieves devices installations
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHomeInstallations{
	my ($self,$homeId) = @_;

	if($self->validateToken == 1){
		$self->refreshToken();
	}

	$Request = GET(qq{$self->{query_url}/$homeId/installations});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeUsers
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#					|=======================================================|
#      PROTOTYPE: getHomeUsers(homeId)
#   RETURN VALUE: ARRAY Reference to Json Response
#    DESCRIPTION: This funtion retrieves the home users for home id
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHomeUsers {
	my ($self,$homeId) = @_;

	if($self->validateToken == 1){
		$self->refreshToken();
	}

	$Request = GET(qq{$self->{query_url}/$homeId/users});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeMobileDevices
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#      				|Argument-02 | mobileDeviceId	|scalar value			|
#      				|Argument-03 | settings			|Hash Reference			|
#					|=======================================================|
#      PROTOTYPE: getHomeMobileDevices(homeId)
#   RETURN VALUE: ARRAY Reference to Json Response
#    DESCRIPTION: This funtion retrieves the mobile devices for home id
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHomeMobileDevices {
	my ($self,$homeId) = @_;

	if(not defined($homeId)){
		return [];  #Return empty array reference
	}

	if($self->validateToken == 1){
		$self->refreshToken();
	}

	$Request = GET(qq{$self->{query_url}/$homeId/mobileDevices});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeMobileDevicesSettings
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#      				|Argument-02 | mobileDeviceId	|scalar value			|
#					|=======================================================|
#      PROTOTYPE: getHomeMobileDevicesSettings(homeId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION: This funtion retrieves the mobile device settings for home id
#         AUTHOR: Kamal Mehta
#        VERSION: 0.1
#        CREATED: 06/06/2019
#       REVISION: 06/06/2019
#------------------------------------------------------------------------------
sub getHomeMobileDeviceSettings {
    my ($self,$homeId,$mobileDeviceId) = @_;

	if(not defined($homeId)){
		return [];  #Return empty array reference
	}

	if(not defined($mobileDeviceId)){
		return [];  #Return empty array reference
	}

	if($self->validateToken == 1){
		$self->refreshToken();
	}

	$Request = GET(qq{$self->{query_url}/$homeId/mobileDevices/$mobileDeviceId/settings});
	return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setHomeMobileDeviceSettings
#      ARGUMENTS: 	|=======================================================|
#      				|No		 	 | Name				|Type					|
#					|=======================================================|
#      				|Argument-01 | homeId			|scalar value			|
#      				|Argument-02 | mobileDeviceId	|scalar value			|
#      				|Argument-03 | settings			|Hash Reference			|
#					|=======================================================|
#      PROTOTYPE: setHomeMobileDevices(homeId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION: This funtion modifies the mobile device settings for home id
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setHomeMobileDeviceSettings {
    my ($self,$homeId,$mobileDeviceId,$settings) = @_;

	if(not defined($homeId)){
		return [];  #Return empty array reference
	}

	if(not defined($mobileDeviceId)){
		return [];  #Return empty array reference
	}

	if($self->validateToken == 1){
		$self->refreshToken();
	}
	my $URL=qq{$self->{query_url}/$homeId/mobileDevices/$mobileDeviceId/settings};

	$Request = HTTP::Request->new('PUT',$URL);

	$Request->content_type('application/json');
	my $json=JSON->new->allow_nonref;
	$Request->content($json->encode($settings));
	$self->{agent}->default_headers($self->{headers});
	$Response = $self->{agent}->request($Request);
	print $Response->content."\n";
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneState
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId			|scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneState(homeId,zoneId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION: This funtion modifies the mobile device settings for home id
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneState {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/state});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneCapabilities
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneCapabilities(homeId,zoneId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneCapabilities {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/capabilities});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneEarlyStart
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneEarlyStart(homeId,zoneId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneEarlyStart {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/earlyStart});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setHomeZoneEarlyStart
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |Argument-03 | settings         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setHomeZoneEarlyStart(homeId,zoneId,settings)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setHomeZoneEarlyStart {
    my ($self,$homeId,$zoneId,$settings) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    my $URL=qq{$self->{query_url}/$homeId/zones/$zoneId/earlyStart};
	$Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneOverlay
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneOverlay(homeId,zoneId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneOverlay {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/overlay});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setHomeZoneOverlay
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |Argument-03 | settings         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setHomeZoneOverlay(homeId,zoneId,settings)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setHomeZoneOverlay {
    my ($self,$homeId,$zoneId,$settings) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    my $URL=qq{$self->{query_url}/$homeId/zones/$zoneId/overlay};
    $Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneScheduleActiveTimetable
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneScheduleActiveTimetable(homeId,zoneId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneScheduleActiveTimetable {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/schedule/activeTimetable});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setHomeZoneScheduleActiveTimetable
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |Argument-03 | settings         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setHomeZoneScheduleActiveTimetable(homeId,zoneId,settings)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setHomeZoneScheduleActiveTimetable {
    my ($self,$homeId,$zoneId,$settings) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    my $URL=qq{$self->{query_url}/$homeId/zones/$zoneId/schedule/activeTimetable};
    $Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneScheduleAway
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneScheduleAway(homeId,zoneId)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneScheduleAway {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/schedule/awayConfiguration});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setHomeZoneScheduleAway
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |Argument-03 | settings         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setHomeZoneScheduleAway(homeId,zoneId,settings)
#   RETURN VALUE: HASH Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setHomeZoneScheduleAway {
    my ($self,$homeId,$zoneId,$settings) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    my $URL=qq{$self->{query_url}/$homeId/zones/$zoneId/schedule/awayConfiguration};
    $Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneScheduleTimetables
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneScheduleTimetables(homeId,zoneId)
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneScheduleTimetables {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/schedule/timetables});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneScheduleTimetableBlocks
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |Argument-03 | timetableId      |scalar value           |
#                   |Argument-04 | pattern          |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneScheduleTimetableBlocks(homeId,zoneId,timetableId,pattern)
#   RETURN VALUE: ARRAY of HASH References to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneScheduleTimetableBlocks {
    my ($self,$homeId,$zoneId,$timetableId,$pattern) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if(not defined($timetableId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{$self->{query_url}/$homeId/zones/$zoneId/schedule/timetables/$timetableId/blocks});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setHomeZoneScheduleTimetableBlocks
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | zoneId           |scalar value           |
#                   |Argument-03 | timetableId      |scalar value           |
#                   |Argument-04 | pattern          |scalar value           |
#                   |Argument-05 | settings         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setHomeZoneScheduleTimetableBlocks(homeId,zoneId,timetableId,pattern,settings)
#   RETURN VALUE: ARRAY Reference to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setHomeZoneScheduleTimetableBlocks {
    my ($self,$homeId,$zoneId,$timetableId,$pattern,$settings) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if(not defined($timetableId)){
        return [];  #Return empty array reference
    }

    if(not defined($pattern)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    my $URL=qq{$self->{query_url}/$homeId/zones/$zoneId/schedule/timetables/$timetableId/blocks};
    $Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: identifyDevice
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | homeId           |scalar value           |
#                   |Argument-02 | deviceID         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: identifyDevice(homeId,deviceId)
#   RETURN VALUE: None
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub identifyDevice {
    my ($self,$homeId,$deviceId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($deviceId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=POST(qq{https://my.tado.com/api/v2/devices/$deviceId/identify});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getTemperatureOffset
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | deviceID         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getTemperatureOffset(deviceId)
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getTemperatureOffset {
    my ($self,$deviceId) = @_;

    if(not defined($deviceId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{https://my.tado.com/api/v2/devices/$deviceId/temperatureOffset});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setTemperatureOffset
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | deviceID         |scalar value           |
#                   |Argument-02 | settings         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setTemperatureOffset(deviceId)
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setTemperatureOffset {
    my ($self,$deviceId,$settings) = @_;

    if(not defined($deviceId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }

	my $URL=qq{https://my.tado.com/api/v2/devices/$deviceId/temperatureOffset};
    $Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getDazzle
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | HomeId         |scalar value           |
#                   |Argument-02 | zoneId         |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getDazzle(homeId,zoneId,settings)
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getDazzle {
    my ($self,$homeId,$zoneId) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }

    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request=GET(qq{https://my.tado.com/api/v2/homes/$homeId/zones/$zoneId/dazzle});
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setDazzle
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | HomeId         |scalar value           |
#                   |Argument-02 | zoneId         |scalar value           |
#                   |Argument-03 | settings       |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setDazzle(homeId,zoneId,settings)
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setDazzle {
    my ($self,$homeId,$zoneId,$settings) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }
    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
	my $URL=qq{https://my.tado.com/api/v2/homes/$homeId/zones/$zoneId/dazzle};
    $Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: getHomeZoneDayReport
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | HomeId         |scalar value           |
#                   |Argument-02 | zoneId         |scalar value           |
#                   |Argument-03 | date	          |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: getHomeZoneDayReport(homeId,zoneId,date)
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getHomeZoneDayReport {
    my ($self,$homeId,$zoneId, $date) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }
    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if(not defined($date)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }

    $Request = GET(qq{https://my.tado.com/api/v2/homes/$homeId/zones/$zoneId/dayReport?date=$date});

    return $self->requestResponse($Request);
}

#------------------------------------------------------------------------------
#  FUNCTION NAME: setOpenWindowDetection
#      ARGUMENTS:   |=======================================================|
#                   |No          | Name             |Type                   |
#                   |=======================================================|
#                   |Argument-01 | HomeId         |scalar value           |
#                   |Argument-02 | zoneId         |scalar value           |
#                   |Argument-03 | settings       |scalar value           |
#                   |=======================================================|
#      PROTOTYPE: setOpenWindowDetection(homeId,zoneId,settings)
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION:
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub setOpenWindowDetection {
    my ($self,$homeId,$zoneId,$settings) = @_;

    if(not defined($homeId)){
        return [];  #Return empty array reference
    }
    if(not defined($zoneId)){
        return [];  #Return empty array reference
    }

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    my $URL=qq{https://my.tado.com/api/v2/homes/$homeId/zones/$zoneId/openWindowDetection};
    $Request = HTTP::Request->new('PUT',$URL);

    $Request->content_type('application/json;;charset=UTF-8');
    my $json=JSON->new->allow_nonref;
    $Request->content($json->encode($settings));
    $self->{agent}->default_headers($self->{headers});
    $Response = $self->{agent}->request($Request);
    return $self->requestResponse($Request);
}

#https://my.tado.com/mobile/1.9/getAppUsersRelativePositions
#------------------------------------------------------------------------------
#  FUNCTION NAME: getAppUsersRelativePositions
#      ARGUMENTS: None
#      PROTOTYPE: getAppUsersRelativePositions()
#   RETURN VALUE: ARRAY Reference of HASH(s)to Json Response
#    DESCRIPTION: https://my.tado.com/mobile/1.9/getAppUsersRelativePositions is important
#         AUTHOR:
#        VERSION:
#        CREATED:
#       REVISION:
#------------------------------------------------------------------------------
sub getAppUsersRelativePositions {
    my ($self) = @_;

    if($self->validateToken == 1){
        $self->refreshToken();
    }
    $Request = GET(qq{https://my.tado.com/mobile/1.9/getAppUsersRelativePositions});

    return $self->requestResponse($Request);
}

1;
