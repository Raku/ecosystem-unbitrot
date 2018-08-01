#!/usr/bin/env perl6

# ⚠ TODO ↓ change before the final run
my $repo = ‘AlexDaniel/my-test-repo’;
my $url  = “https://api.github.com/repos/$repo/issues”;

sub body-template($module) {
    qq:to/TEMPLATE/
    Module [$module](https://modules.perl6.org/dist/$module) is failing its tests and/or does not install.

    * You can close the issue only if the module passes its tests and is installable.
    * If you can install it without any issues, label this ticket with `works for me` and close the issue.
    * If it needs a native library, put `native dependency` label, describe what you did to install it and ensure that same instructions are present in the README file of the module (otherwise submit a pull request). If everything is green you can close the issue.

    If you can't attach a label or close the ticket, please let us know on #perl6 channel on freenode, or just leave a comment here. We will try to give you priveleges as fast as possible.
    TEMPLATE
}

multi MAIN(‘I know what I'm doing’, $token, *@dbs) {
    for red-modules(@dbs).keys.sort[^20] {
        submit-issue :$token,
                     title => $_,
                     body  => body-template $_,;
    }
}

multi MAIN(*@) {
    note ‘Exiting… Please confirm your intentions.’;
}

sub red-modules(@dbs) {
    my $red = ∅;

    use DBIish;
    for @dbs {
        my $dbh = DBIish.connect: ‘SQLite’, database => $_;
        my $sth = $dbh.prepare(q:to/STATEMENT/);
        SELECT module, status FROM toast
        STATEMENT

        $sth.execute();
        my @rows = $sth.allrows();
        $sth.finish;
        $dbh.dispose;

        my %c = @rows.classify: { .[1] eq ‘Succ’ ?? ‘good’ !! ‘bad’ };
        $red ∪= %c<bad>».[0];
        $red ∖= %c<good>».[0];
    }
    $red
}

sub submit-issue(:$token, :$title, :$body, :@labels) {
    my %body = %(:$title, :$body, :@labels,);

    use Cro::HTTP::Client;
    my $resp = await Cro::HTTP::Client.post: $url,
          headers => [
              User-Agent => ‘perl6 ecosystem unbitrot’,
              Authorization => “token $token”,
          ],
          content-type => ‘application/json’,
          body => %body,
          ;

    say await $resp.body;
}
