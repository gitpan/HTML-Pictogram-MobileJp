#line 1
package Test::MobileAgent;

use strict;
use warnings;
use base 'Exporter';

our $VERSION = '0.04';

our @EXPORT    = qw/test_mobile_agent/;
our @EXPORT_OK = qw/test_mobile_agent_env
                    test_mobile_agent_headers
                    test_mobile_agent_list/;
our %EXPORT_TAGS = (all => [@EXPORT, @EXPORT_OK]);

sub test_mobile_agent {
  my %env = test_mobile_agent_env(@_);

  $ENV{$_} = $env{$_} for keys %env;

  return %env if defined wantarray;
}

sub test_mobile_agent_env {
  my ($agent, %extra_headers) = @_;

  my ($vendor, $type) = _find_vendor($agent);
  my $class = _load_class($vendor);
  return $class->env($type, %extra_headers);
}

sub test_mobile_agent_headers {
  my %env = test_mobile_agent_env(@_);

  require HTTP::Headers::Fast;
  my $headers = HTTP::Headers::Fast->new;
  foreach my $name (keys %env) {
    (my $short_name = $name) =~ s/^HTTP[-_]//;
    $headers->header($short_name => $env{$name});
  }
  $headers;
}

sub test_mobile_agent_list {
  my ($vendor, $type) = _find_vendor(@_);
  my $class = _load_class($vendor);
  return $class->list($type);
}

sub _find_vendor {
  my $agent = shift;

  if ($agent =~ /^[a-z]+$/) {
    return (ucfirst($agent), '');
  }
  elsif ($agent =~ /^[a-z]+\./) {
    my ($vendor, $type) = split /\./, $agent;
    $vendor = ucfirst $vendor;
    return ($vendor, $type);
  }
  else {
    # do some guesswork
    my $vendor;
    if ($agent =~ /^DoCoMo/i) {
      return ('Docomo', $agent);
    }
    elsif ($agent =~ /^J\-PHONE/i) {
      return ('Jphone', $agent);
    }
    elsif ($agent =~ /^KDDI\-/i) {
      return ('Ezweb', $agent);
    }
    elsif ($agent =~ /^UP\.Browser/i) {
      return ('Ezweb', $agent);
    }
    elsif ($agent =~ /DDIPOCKET/i) {
      return ('Airh', $agent);
    }
    elsif ($agent =~ /WILLCOM/i) {
      return ('Airh', $agent);
    }
    elsif ($agent =~ /^Vodafone/i) {
      return ('Vodafone', $agent);
    }
    elsif ($agent =~ /^MOT/i) {
      return ('Vodafone', $agent);
    }
    elsif ($agent =~ /^Nokia/i) {
      return ('Vodafone', $agent);
    }
    elsif ($agent =~ /^SoftBank/i) {
      return ('Softbank', $agent);
    }
    else {
      return ('Nonmobile', $agent);
    }
  }
}

sub _load_class {
  my $vendor = shift;
  my $class = "Test::MobileAgent::$vendor";
  eval "require $class";
  if ($@) {
    $class = 'Test::MobileAgent::Nonmobile';
    require Test::MobileAgent::Nonmobile;
  }
  return $class;
}

1;

__END__

#line 220
