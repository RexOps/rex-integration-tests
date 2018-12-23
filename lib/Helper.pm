#
# Some Helper functions
#
package Helper;

use Rex -future;
use Rex::Commands::Fs;
use Test::More;
use Rex::Group::Lookup::INI;

use Cwd 'getcwd';
use Data::Dumper;

require Rex::Commands::MD5;

sub import {
  
  if($ENV{REX_TEST_SUDO_PASSWORD}) {
    Rex::Config->set_sudo_password($ENV{REX_TEST_SUDO_PASSWORD});
  }

  Rex::connect(
    server    => $ENV{REX_TEST_HOST},
    user      => $ENV{REX_TEST_USER},
    password  => $ENV{REX_TEST_PASSWORD},
    sudo      => ($ENV{REX_TEST_SUDO} || 0),
  );
}

sub get_nobody_group {
  my $output = run "groups nobody";
  if($? != 0) {
    die "Error getting infos for nobody user.";
  }

  my ($user, $groups) = split(/\s*:\s*/);
  my @group_list = split(/ /, $groups);
  return $group_list[0];
}

sub remote_md5 {
  my ($file) = @_;
  return Rex::Commands::MD5::md5($file);
}

1;