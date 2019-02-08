#!/usr/bin/env perl6

use JSON::Fast;
use Unbitrot::Utils;

unit sub MAIN(
    ‘I know what I'm doing’,
    $token,
    IO() :$blin-data = ‘data.json’,
    IO() :$template  = ‘template.md’,
    :$delay = 5,
);


my %modules = from-json slurp $blin-data;
my @issues = get-issues :$token;
my $template-text = slurp $template;
my $module-metadata = fetch ‘https://modules.perl6.org/search.json’;


for @issues -> $issue {
    .<ticket> = $issue with %modules{$issue<title>};
}

for @($module-metadata<dists>) -> $metadata {
    my $module = %modules{$metadata<name>};
    next unless $module;
    $module<metadata> = $metadata;
    my $author = Nil;
    if $metadata<repo_url> ~~ /‘github.com/’(<[\w-]>+)‘/’/ {
        $author = ~$0;
    }
    $module<author> = $author;
}

for %modules.keys.sort -> $name {
    my $module = %modules{$name};
    my $ticket = $module<ticket>;
    if $module<status> eq ‘OK’ {
        if $ticket and $ticket<state> ne ‘closed’ {
            note “Closing issue {$ticket<number>} for $name”;
            close-single-issue $ticket<url>, :$token;
            sleep $delay;
        }
    } else {
        if not $ticket or $ticket<state> eq ‘closed’ {
            note “Creating new issue for $name”;

            my $title = $name;
            my @labels;
            my $body = $template-text;
            my $ping-author = $module<author> ?? ‘Ping @’ ~ $module<author> !! ‘’;
            my $previous-ticket = $ticket ?? ‘Previous ticket: #’ ~ $ticket<number> !! ‘’;

            $body .= subst: ‘｢MODULE｣’, $name;
            $body .= subst: ‘｢MODULE-URL｣’, “https://modules.perl6.org/dist/$name”;
            $body .= subst: ‘｢BLIN-STATUS｣’, $module<status>;
            $body .= subst: ‘｢OUTPUT｣’, $module<output> || ‘No output’;
            $body .= subst: ‘｢PING-AUTHOR｣’, $ping-author;
            $body .= subst: ‘｢PREVIOUS-TICKET｣’, $previous-ticket;

            submit-issue :$token, :$title, :$body, :@labels;
            sleep $delay;
        }
    }
}
