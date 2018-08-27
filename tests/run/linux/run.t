#!perl
# vim: set syn=perl:

use Rex -future;
use Test::More;
use Rex::Commands::Fs;

use lib '../../lib';
use Helper;

my $desc1 = run 'FOOV=blub ; echo "\'$FOOV\'"';
ok($desc1 =~ m/'blub'/, "OK: Escape");

my $desc2 = run 'FOOV=foobarbaz ; echo \'"$FOOV"\'';
ok($desc2 =~ m/"\$FOOV"/, 'OK: Escape 2');

my $okcwd = run "pwd", cwd => "/etc";
ok($okcwd eq "/etc", "OK: executed in /etc directory via cwd");

my $badcwd = run "pwd", cwd => "/dfdfjhdfj";
ok($badcwd !~ m/^\// && $? != 0, "OK: error changing directory, \$? != 0");


