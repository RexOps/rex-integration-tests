#!perl
# vim: set syn=perl:
use Rex::Commands::Fs;

use Rex -future;
use Test::More tests => 25;

use lib '../../lib';
use Helper;

my $nobody_group = Helper::get_nobody_group;

ok(is_file("/etc/passwd"), "is_file: /etc/passwd is a file");
ok(is_dir("/etc"), "is_dir: /etc is a directory");
ok(is_readable("/etc"), "is_readable: /etc is_readable");
ok(is_writable("/tmp"), "is_writable: /tmp is_writable");

my @etc = grep { /^passwd$/ } list_files("/etc");
ok(scalar(@etc) == 1, "list_files: found passwd");

symlink("/etc/passwd", "/tmp/passwd");
ok(is_symlink("/tmp/passwd"), "is_symlink: /tmp/passwd is a symlink");
ok(readlink("/tmp/passwd") eq "/etc/passwd", "readlink, symlink: ok");

unlink("/tmp/passwd");
ok(!is_file("/tmp/passwd"), "unlink: /tmp/passwd is removed");
ok(!is_symlink("/tmp/passwd"), "unlink: /tmp/passwd is removed and is not a symlink");

eval {
  readlink "/tmp/passwd";
  print "failed\n";
};
ok($@, "readlink on no link");

mkdir "/tmp/t";
ok(is_dir("/tmp/t"), "mkdir: dir created");

mkdir "/tmp/t/bla/blub/ha/do/jo/mo/klo";
ok(is_dir("/tmp/t/bla/blub/ha/do/jo/mo/klo"), "mkdir: recursive ok");

rmdir "/tmp/t";
ok(!is_dir("/tmp/t"), "rmdir: dir removed");

mkdir "/tmp/ug",
      owner => "nobody",
      group => $nobody_group,
      mode  => "0700";

ok(is_dir("/tmp/ug"), "mkdir w/ options created dir");
my %stat = stat("/tmp/ug");
ok($stat{"mode"} == 700, "mkdir w/ options: mode 700");

file "/tmp/chmod.test", content => "foo";
chmod 701, "/tmp/chmod.test";
my %stat2 = stat("/tmp/chmod.test");
ok($stat2{"mode"} == 701, "chmod: testfile has chmod 701");

eval {
  mkdir "/tmp/l/u/o/p",
    not_recursive => 1;
};

ok(!is_dir("/tmp/l/u/o/p"), "mkdir: non-recursive");

run "rm -rf /tmp/l";

eval {
  mkdir "tmp";
};

ok(is_dir("tmp"), "mkdir: relative dir");

rename "/tmp/chmod.test", "/tmp/rename.test";
is(is_file("/tmp/rename.test"), 1, "rename: chmod.test to rename.test");

is(is_file("/tmp/copy.test"), undef, "copy.test not there yet");
cp "/tmp/rename.test", "/tmp/copy.test";
is(is_file("/tmp/copy.test"), 1, "cp: copy.test exists");

file "/a/b/c/d", ensure => "directory";
is(is_dir("/a/b/c/d"), 1, "created /a/b/c/d directory with file resource.");
is(is_file("/a/b/c/d"), undef, "/a/b/c/d is not a file.");

file "/a/b/c/d", ensure => "absent";
is(is_dir("/a/b/c/d"), undef, "removed /a/b/c/d directory with file resource.");
is(is_file("/a/b/c/d"), undef, "/a/b/c/d is not a file.");

### cleanup
run "rm -rf /tmp/ug; rm -f /tmp/copy.test; rm -f /tmp/rename.test";

done_testing();