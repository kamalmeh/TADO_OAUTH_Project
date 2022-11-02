# TADO REST APIs
This was developed for one of my [trulancer.com](https://www.truelancer.com/) client lived in Austria. 

Below was the description of the project https://www.truelancer.com/freelance-service/api-implementation-in-perl-over-oauth2-130046
## Project Description on [truelancer.com](https://www.truelancer.com/)
I will create a perl program accepting parameters for below inputs. Client ID - Optional. Default "tado-web-app" Client Secret - Optional. Default will be from "https://my.tado.com/webapp/env.js" Username - Required. Password - Optional. If not provided it will go into interactive mode Scope - optional. Default will be home.user token file path - Optional. Only if you want to store the token for other program to use. Function: Perl program should query the TADO OAuth URL to retrieve the token and use it to fetch the devices.

## Synopsis

```
use TadoREST;

my $data;
my $json = JSON->new->allow_nonref;

my $myTado = TadoREST->new();
$myTado->setConfig("$ENV{PWD}/tadoConnect.json");

$data = $myTado->getAppUsersRelativePositions();

print $json->pretty->encode($data);
```