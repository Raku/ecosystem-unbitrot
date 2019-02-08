use v6.d;

unit module Unbitrot::Utils;

use Cro::HTTP::Client;

constant \url = ‘https://api.github.com/repos/perl6/ecosystem-unbitrot/issues?per_page=60&direction=asc&state=all’;

#| gets the issues from the repo
sub get-issues($token) is export {
    my @tickets;
    my $cur-url = url;
    loop {
        note $cur-url;
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
    my %tickets = @tickets.map: { $_<url> => $_ };
    %tickets;
}

#| Issue per module
sub issue-per-module( %tickets, @modules --> Hash ) is export {
    my %issues-by-title = %tickets.keys.map: { %tickets{$_}<title> => $_ };
    my %issue-per-module;
    for @modules -> $m {
        %issue-per-module{$m} = %issues-by-title{$m}:exists??%issues-by-title{$m}!!Nil;
    }
    return %issue-per-module;
}

#| Edit issue
sub close-single-issue($url, $token, :$state = 'closed') is export {
    patch( :$url, :$token, body => { :$state } ),
}

#| patch with cro
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
