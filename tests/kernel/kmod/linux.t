# vim: set syn=perl:

use Rex -future;
use Test::More tests => 23;

use Data::Dumper;

use lib '../../lib';
use Helper;
require Rex::Commands::MD5;

use Rex::Helper::Run;

my $mods_loaded = sub {
  my ($mod) = @_;
  my @out = run "lsmod";
  my ($loaded_mod) = grep { m/^\Q$mod\E\s+/ } @out;
  if($loaded_mod) {
    return 1;
  }
  return 0;
};

my $mod_to_test = "cifs";

SKIP: {
  skip "Only for Linux", 3 unless is_linux();

  kmod $mod_to_test,
    ensure => "present";

  is($mods_loaded->($mod_to_test), 1, "Kernel module loaded");

  eval {
    kmod "no-valid-module",
      ensure => "present",
      auto_die => 1;
  };
  if($@) {
    like($@, qr/Calling autodie/, "Catch autodie exception");
  }

  kmod $mod_to_test,
    ensure => "absent";

  is($mods_loaded->($mod_to_test), 0, "Kernel module NOT loaded");

};

SKIP: {
  skip "Only for Redhat Clones", 12 unless is_redhat();

  kmod "cifs",
    ensure => "enabled";

  is($mods_loaded->("cifs"), 1, "Kernel module loaded");
  is(Rex::Commands::MD5::md5("/etc/modules-load.d/cifs.conf"), "2a56eb5b4be2d5634983c3d2f33e44eb", "Kernel module enabled");

  kmod "cifs",
    ensure => "disabled";

  is($mods_loaded->("cifs"), 0, "Kernel module NOT loaded");
  is(is_file("/etc/modules-load.d/cifs.conf"), undef, "Kernel module disabled");


  kmod "cifs",
    ensure => "enabled",
    provider => "::linux::redhat_5";

  my ($enabled) = grep { m/^cifs$/ } i_run "cat /etc/rc.modules";

  is($mods_loaded->("cifs"), 1, "Kernel module loaded");
  is($enabled, "cifs", "Kernel module enabled");

  kmod "cifs",
    ensure => "disabled",
    provider => "::linux::redhat_5";

  my ($disabled) = grep { m/^cifs$/ } i_run "cat /etc/rc.modules";

  is($mods_loaded->("cifs"), 0, "Kernel module NOT loaded");
  is($disabled, undef, "Kernel module disabled");


  kmod "cifs",
    ensure => "enabled",
    provider => "::linux::redhat_6";

  is($mods_loaded->("cifs"), 1, "Kernel module loaded");
  is(is_file("/etc/sysconfig/modules/cifs.modules"), 1, "Kernel module disabled");

  kmod "cifs",
    ensure => "disabled",
    provider => "::linux::redhat_6";

  is($mods_loaded->("cifs"), 0, "Kernel module NOT loaded");
  is(is_file("/etc/sysconfig/modules/cifs.modules"), undef, "Kernel module disabled");
};

SKIP: {
  skip "Only for Debian Clones", 8 unless is_debian();
  kmod "ntfs",
    ensure => "enabled";

  is($mods_loaded->("ntfs"), 1, "Kernel module loaded");
  is(Rex::Commands::MD5::md5("/etc/modules-load.d/ntfs.conf"), "68e98b83f5bd746f1468dff89f529d1b", "Kernel module enabled");

  kmod "ntfs",
    ensure => "disabled";

  is($mods_loaded->("ntfs"), 0, "Kernel module NOT loaded");
  is(is_file("/etc/modules-load.d/ntfs.conf"), undef, "Kernel module disabled");


  kmod "ntfs",
    ensure => "enabled",
    provider => "::linux::debian_legacy";

  my ($enabled) = grep { m/^ntfs$/ } i_run "cat /etc/modules";

  is($mods_loaded->("ntfs"), 1, "Kernel module loaded");
  is($enabled, "ntfs", "Kernel module enabled");

  kmod "ntfs",
    ensure => "disabled",
    provider => "::linux::debian_legacy";

  my ($disabled) = grep { m/^ntfs$/ } i_run "cat /etc/modules";

  is($mods_loaded->("ntfs"), 0, "Kernel module NOT loaded");
  is($disabled, undef, "Kernel module disabled");
};

done_testing();
