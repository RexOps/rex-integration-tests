# vim: set syn=perl:

use Rex -future;
use Test::More tests => 7;

use Data::Dumper;

use lib '../../lib';
use Helper;
require Rex::Commands::MD5;

my $mods_loaded = sub {
  my ($mod) = @_;
  my @out = run "lsmod";
  my ($loaded_mod) = grep { m/^\Q$mod\E\s+/ } @out;
  if($loaded_mod) {
    return 1;
  }
  return 0;
};

SKIP: {
  skip "Only for Linux", 3 unless is_linux();

  kmod "ntfs",
    ensure => "present";

  is($mods_loaded->("ntfs"), 1, "Kernel module loaded");

  eval {
    kmod "no-valid-module",
      ensure => "present",
      auto_die => 1;
  };
  if($@) {
    like($@, qr/Calling autodie/, "Catch autodie exception");
  }

  kmod "ntfs",
    ensure => "absent";

  is($mods_loaded->("ntfs"), 0, "Kernel module NOT loaded");

};

SKIP: {
  skip "Only for Debian Clones", 4 unless is_debian();
  kmod "ntfs",
    ensure => "enabled";

  is($mods_loaded->("ntfs"), 1, "Kernel module loaded");
  is(Rex::Commands::MD5::md5("/etc/modules-load.d/ntfs.conf"), "68e98b83f5bd746f1468dff89f529d1b", "Kernel module enabled");

  kmod "ntfs",
    ensure => "disabled";

  is($mods_loaded->("ntfs"), 0, "Kernel module NOT loaded");
  is(is_file("/etc/modules-load.d/ntfs.conf"), undef, "Kernel module disabled");
};

done_testing();
