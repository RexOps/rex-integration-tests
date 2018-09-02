# vim: set syn=perl:

use Rex -future;
use Test::More tests => 15;
use Rex::Commands::Fs;

use Data::Dumper;

use lib '../../lib';
use Helper;

my $basic = run 'uptime';
ok($basic =~ m/load average/, "OK: Basic invocation of run");

my $chain = run 'FOOV=blah ; echo $FOOV';
ok($chain =~ m/blah/, "OK: command chaining");

my $esc = run 'echo \$"FOO"';
ok($esc =~ m/\$FOO/, "OK: Shell escape");

my $path = run 'echo $PATH', path => '/tmp';
ok($path eq "/tmp", "used custom path");

my ($cmd) = can_run "ifconfig", "ip";
ok($cmd =~ m/ifconfig|ip/, "found ifconfig or ip command");

my $or = run 'touch /bla/foo/baz/file || touch /tmp/fafafafa';
ok(is_file("/tmp/fafafafa"), 'OK: OR chaining works');

my $and = run 'touch /tmp/fufufufu && touch /tmp/fofofofo';
ok(is_file("/tmp/fofofofo"), 'OK: AND chaining works');

my $check_0 = run 'grep -c sdfsdf /etc/passwd', valid_return_codes => [0, 1];
ok($check_0 eq "0", "got 0 as answer");

my @check_env = run "env", env => {
  key1 => "my val",
  key2 => 'my 2nd "val"',
};

my %t_env = ();
for my $line (@check_env) {
  my ($key, $val) = split(/=/, $line);
  $t_env{$key} = $val;
}

ok($t_env{key1} eq "my val", "got first env variable");
ok($t_env{key2} eq "my 2nd \"val\"", "got 2nd env variable");

# test failed command
my $expected_error_code = (is_freebsd() && ! Rex::is_sudo) ? 1 : 127;
run "no-command";
ok($? == $expected_error_code, "got proper error code for 'command not found'");

run "ls -l /not-there";
ok($? != 0, "got non-zero return code for ls on unavailable directory.");

my $to_1 = run "sleep 5; echo hi", timeout => 7;
is($to_1, 'hi', "Timeout higher than execution time got output.");

my $to_2 = run "sleep 10; echo hi", timeout => 5;
is($to_2, 'timeout', "Timeout lower than execution time got timeout out.");
is($?, -1, "Timeout lower than execution time got timeout \$?.");

done_testing();
