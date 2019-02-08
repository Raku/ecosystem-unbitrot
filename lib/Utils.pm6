use v6;

unit module Utils;

constant \url = “https://api.github.com/repos/perl6/ecosystem-unbitrot/issues?state=all”;

#| gets the issues from the repo
sub get-issues($token) is export {
    my @tickets;
    my $cur-url = url;
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

#| Returns failing modules
sub modules-not-ok( $file = "data/blin-output.txt" ) is export {
    $file.IO.slurp.lines.grep(  / \– \s+ <!before OK>/ ).map( (*.words)[0] );
}

#! Issue per module
sub issue-per-module( @tickets, @modules --> Hash ) is export {
    my %issues-by-title = @tickets.map: { $_<title> => $_<url> };
    my %issue-per-module;
    for @modules -> $m {
        %issue-per-module{$m} = %issues-by-title{$m}:exists??%issues-by-title{$m}!!Nil;
    }
    return %issue-per-module;
    
}

#| Edit issue
