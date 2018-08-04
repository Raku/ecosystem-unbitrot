#!/usr/bin/env perl6

# example usage:
#   ./populate-issues.p6 "I know what I'm doing" YOUR-ACCESS-TOKEN 6lang.sqlite.db party.sqlite.db > issue-mapping

my $repo = ‘perl6/ecosystem-unbitrot’;
my $url  = “https://api.github.com/repos/$repo/issues”;

sub body-template($module) {
    qq:to/TEMPLATE/
    Module [$module](https://modules.perl6.org/dist/$module) is failing its tests and/or does not install.

    * Please close this issue only if the module **passes its tests and is installable**. One way to test it is to run `zef install MODULENAME`.
    * If you can **install the module without any problems**, label this ticket with `works for me` and close the issue.
    * If it **needs a native library**, put `native dependency` label, describe what you did to install it and ensure that same instructions are present in the README file of the module (otherwise submit a pull request). If everything is green you can close the issue.
    * If the **module is broken**, try to fix it and send a PR. Add `PR sent` label and close the issue.
    * If there is a **problem in one of the dependencies**, add `failing dependency` label and write a comment explaining the situation. Leave this ticket open and feel free to work on the corresponding ticket for the failing dependency.
    * It is a good idea to **assign yourself** to this ticket if you're working on it (to make sure two or more people are not working on the same ticket at the same time).

    If you can't self-assign, attach a label, or close the ticket, please let us know on [#perl6 channel on freenode](https://perl6.org/irc) or just leave a comment here. We will try to give you priveleges as fast as possible.
    TEMPLATE
}

multi MAIN(‘I know what I'm doing’, $token, *@dbs) {
    for red-modules(@dbs).keys.sort.reverse {
        my $number = submit-issue :$token,
                     title => $_,
                     body  => body-template $_,;
        put “$number, $_”;
        sleep 5;
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
        # ↓ ⚠ TODO possibly buggy, see
        # ↓ http://colabti.org/irclogger/irclogger_log/perl6?date=2018-08-03#l1048
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

    return (await $resp.body)<number> # issue number
}
