#!perl
# vim: set syn=perl:

use Rex -future;
use Test::More tests => 2;
use Rex::Helper::Run;

use lib '../../lib';
use Helper;

SKIP: {
  skip "Only for Redhat", 2 unless is_redhat();

  pkg "vim-enhanced",
    ensure => "present";

  my ($present) = i_run "rpm -qa | grep vim-enhanced", fail_ok => 1;
  like($present, qr/vim\-enhanced/, "vim-enhanced is installed.");

  pkg "vim-enhanced",
    ensure => "absent";

  my ($present) = i_run "rpm -qa | grep vim-enhanced", fail_ok => 1;
  is($present, undef, "vim-enhanced is not installed.");
};


done_testing();
