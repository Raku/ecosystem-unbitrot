use v6.d;

unit module Unbitrot::Utils;

use Cro::HTTP::Client;

constant \url = ‘https://api.github.com/repos/perl6/ecosystem-unbitrot/issues?per_page=60&direction=asc&state=all’;

#| Returns all issues from the repo
sub get-issues(:$token, :$url = url) is export {
    my @issues;
    my $cur-url = url;
    loop {
        note $cur-url;
        my $resp = await Cro::HTTP::Client.get: $cur-url,
              headers => [
                  User-Agent => ‘perl6 ecosystem unbitrot’,
                  Authorization => “token $token”,
              ],
        ;
        @issues.append: @(await $resp.body);
        my $next = $resp.headers.first(*.name eq ‘Link’).?value;
        if $next && $next ~~ /‘<’ (<-[>]>*?) ‘>; rel="next"’/ {
            $cur-url = ~$0;
            next
        }
        last
    }
    @issues;
}

#| Close/Open an issue
sub close-single-issue($url, $token, :$state = 'closed') is export {
    patch( :$url, :$token, body => { :$state } ),
}

#| Patch an issue
sub patch(:$url, :$token, :$body ) {
    my $resp = await Cro::HTTP::Client.patch: $url,
          headers => [
              User-Agent => ‘perl6 ecosystem unbitrot’,
              Authorization => “token $token”,
                  ],
          content-type => ‘application/json’,
          body => $body,
    ;
    return await $resp.body;
}

#| Submit a new issue
sub submit-issue(:$token, :$title, :$body, :@labels, :$url = url) {
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
