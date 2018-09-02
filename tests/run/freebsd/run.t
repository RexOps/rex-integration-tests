#!perl
# vim: set syn=perl:

use Rex -future;
use Test::More tests => 4;
use Rex::Commands::Fs;

use lib '../../lib';
use Helper;

SKIP: {
  skip "Only for FreeBSD", 4 unless is_freebsd();

  my $desc1 = run 'set FOOV=blub ; echo "\'$FOOV\'"';
  ok($desc1 =~ m/'blub'/, "OK: Escape");

  my $desc2 = run 'set FOOV=foobarbaz ; echo \'"$FOOV"\'';
  ok($desc2 =~ m/"\$FOOV"/, 'OK: Escape 2');

  my $okcwd = run "pwd", cwd => "/etc";
  ok($okcwd eq "/etc", "OK: executed in /etc directory via cwd");

  my $badcwd = run "pwd", cwd => "/dfdfjhdfj";
  ok($badcwd =~ m/No such file/ && $? != 0, "OK: error changing directory, \$? != 0");
}


done_testing();
