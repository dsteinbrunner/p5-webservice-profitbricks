#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package WebService::ProfitBricks::Connection;

use strict;
use warnings;

use Data::Dumper;
use WebService::ProfitBricks::Class;

use WebService::ProfitBricks::Base;
use base qw(WebService::ProfitBricks::Base);

use SOAP::Lite; #qw(trace);

my $soap;
my %auth = ();

attr qw/user password/;

sub construct {
   my ($self) = @_;

   $auth{$self->user} = $self->password;
   sub SOAP::Transport::HTTP::Client::get_basic_credentials { 
      return %auth;
   }

   # don't create a new soap object if there is already one
   if(! $soap) {
      $soap = SOAP::Lite->service("https://api.profitbricks.com/1.2/wsdl")->proxy("https://api.profitbricks.com/1.2");
      $soap->ns("http://ws.api.profitbricks.com/", "tns");
   }

   return $self;
}

sub auth {
   my ($user, $pass) = @_;

}

sub call {
   my ($self, $call, %data) = @_;

   my @soap_params;

   if(exists $data{xml}) {
      push(@soap_params, SOAP::Data->type("xml", $data{xml}));
   }
   else {
      for my $key (keys %data) {
         push(@soap_params, SOAP::Data->name($key)->value($data{$key}));
      }
   }

   my $resp = $soap->call($call, @soap_params);

   if(wantarray) {
      my @ret = ($resp->result);
      push(@ret, $resp->paramsout);
      return @ret;
   }
   else {
      return $resp->result;
   }
}

1;