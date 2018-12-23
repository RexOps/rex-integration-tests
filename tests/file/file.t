#!perl
# vim: set syn=perl:

use Rex -future;
use Test::More tests => 5;
use Rex::Commands::Fs;

use lib '../../lib';
use Helper;


my $file_changed = 0;
file "/tmp/foo.txt",
  content => "foo",
  on_change => sub { $file_changed=1; };

my $remote_md5 = Helper::remote_md5("/tmp/foo.txt");
is($remote_md5, 'acbd18db4cc2f85cedef654fccc4a4d8', "remote file has defined content");
is($file_changed, 1, "File was changed.");


my $remove_changed = 0;
file "/tmp/foo.txt",
  ensure => "absent",
  on_change => sub { $remove_changed = 1; };

is(is_file("/tmp/foo.txt"), undef, "File was removed.");
is($remove_changed, 1, "Removed the file.");

file "/tmp/foo.txt",
  ensure => "absent",
  on_change => sub { $remove_changed = 2; };
is($remove_changed, 1, "File was already removed.");


done_testing();
