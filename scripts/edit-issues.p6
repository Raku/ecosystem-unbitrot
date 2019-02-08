#!/usr/bin/env perl6

# example usage:
#   ./edit-issues.p6 "I know what I'm doing" YOUR-ACCESS-TOKEN '$body ~= ‘a’'

my $repo = ‘perl6/ecosystem-unbitrot’;
my $url  = “https://api.github.com/repos/$repo/issues?state=all”;

multi MAIN(‘I know what I'm doing’, $token, $evaled-code) {
    for get-issues(:$token).sort(+*<number>) {
        my $url    = .<url>;
        my $title  = .<title>;
        my $body   = .<body>;
        my @labels = .<labels>»<name>;

        use MONKEY-SEE-NO-EVAL;
        EVAL $evaled-code;

        my %named;
        %named ,= :$title  if $title   ne  .<title>;
        %named ,= :$body   if $body    ne  .<body>;
        %named ,= :@labels if (@labels cmp .<labels>»<name>) ≠ Same;

        next unless %named;

        note ‘Editing issue #’, .<number>;
        edit-issue :$url, :$token, |%named;
        sleep 1;
    }
}

multi MAIN(*@) {
    note ‘Exiting… Please confirm your intentions.’;
}

sub get-issues(:$token) {
    my @tickets;
    my $cur-url = $url;
    loop {
        note $cur-url;
        use Cro::HTTP::Client;
        my $resp = await Cro::HTTP::Client.get: $cur-url,
              headers => [
                  User-Agent => ‘perl6 ecosystem unbitrot’,
                  Authorization => “token $token”,
              ],
        ;
        @tickets.append: @(await $resp.body);
        my $next = $resp.headers.first(*.name eq ‘Link’).?value;
        if $next && $next ~~ /‘<’ (<-[>]>*?) ‘>; rel="next"’/ {
            $cur-url = ~$0;
            next
        }
        last
    }
    @tickets
}

sub edit-issue(:$url, :$token, :$title, :$body, :@labels) {
    my %body;
    %body ,= :$title  with $title;
    %body ,= :$body   with $body;
    %body ,= :@labels   if @labels;

    use Cro::HTTP::Client;
    my $resp = await Cro::HTTP::Client.patch: $url,
          headers => [
              User-Agent => ‘perl6 ecosystem unbitrot’,
              Authorization => “token $token”,
          ],
          content-type => ‘application/json’,
          body => %body,
    ;

    return await $resp.body
}
