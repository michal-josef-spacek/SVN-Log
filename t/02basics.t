#!perl -w

# $Id: 02basics.t 147 2004-06-11 19:34:53Z rooneg $

use Test::More tests => 8;

use strict;

use File::Spec::Functions qw(catdir rel2abs);
use File::Temp qw(tempdir);
use SVN::Log;

my $tmpdir = tempdir (CLEANUP => 1);

my $repospath = rel2abs (catdir ($tmpdir, 'repos'));
my $indexpath = rel2abs (catdir ($tmpdir, 'index'));

{
  system ("svnadmin create $repospath");
  system ("svn mkdir -q file://$repospath/trunk -m 'a log message'");
  system ("svn mkdir -q file://$repospath/branches -m 'another log message'");
}

my $revs = SVN::Log::retrieve ("file://$repospath", 1);

is (scalar @$revs, 1, "got one revision");

like ($revs->[0]{message}, qr/a log message/, "looks like we got 1 okay");

$revs = SVN::Log::retrieve ($repospath, 2);

is (scalar @{ $revs }, 1, "and now the second");

is_deeply ($revs->[0]{paths}, { '/branches' => 1 }, "and the paths from 2");

$revs = SVN::Log::retrieve ($repospath, 1, 2);

is (scalar @{ $revs }, 2, "got both back");

like ($revs->[0]{message}, qr/a log message/, "1's log message is ok");

is_deeply ($revs->[1]{paths}, { '/branches' => 1 }, "paths in 2 look right");

my $count = 0;

SVN::Log::retrieve ({ repository => $repospath,
                      start => 1,
                      end => 2,
                      callback => sub { $count++; }});

is ($count, 2, "called callback twice");
chmod 0600, File::Spec->catfile ($repospath, "format");
