#!perl
# vim: set syn=perl:

use Rex -future;
use Test::More tests => 4;
use Rex::Commands::Fs;

use lib '../../lib';
use Helper;

SKIP: {
  skip "Only for Linux", 4 unless is_linux();

  my $desc1 = run 'FOOV=blub ; echo "\'$FOOV\'"';
  ok($desc1 =~ m/'blub'/, "OK: Escape");

  my $desc2 = run 'FOOV=foobarbaz ; echo \'"$FOOV"\'';
  ok($desc2 =~ m/"\$FOOV"/, 'OK: Escape 2');

  my $okcwd = run "pwd", cwd => "/etc";
  ok($okcwd eq "/etc", "OK: executed in /etc directory via cwd");

  my $badcwd = run "pwd", cwd => "/dfdfjhdfj";
  ok($badcwd !~ m/^\// && $? != 0, "OK: error changing directory, \$? != 0");

};


done_testing();
