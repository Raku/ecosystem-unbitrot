#!/usr/bin/env perl6

use JSON::Fast;
use Unbitrot::Utils;

unit sub MAIN(
    ‘I know what I'm doing’,
    $token,
    IO() :$blin-data = ‘data.json’,
    IO() :$template  = ‘template.md’,
);


my %modules = from-json slurp $blin-data;
my @issues = get-issues :$token;
my $template-text = slurp $template;

for @issues -> $issue {
    .<ticket> = $issue with %modules{$issue<title>};
}

for %modules.keys.sort -> $name {
    my $module = %modules{$name};
    my $ticket = $module<ticket>;
    if $module<status> eq ‘OK’ {
        if $ticket and $ticket<state> ne ‘closed’ {
            note “Closing issue {$ticket<number>} for $name”;
            # close-single-issue $ticket<url>, :$token
        }
    } else {
        if not $ticket or $ticket<state> eq ‘closed’ {
            note “Creating new issue for $name”;

            my $title = $name;
            my @labels;
            my $body = $template-text;
            my $ping-author = False ?? ‘Ping @AlexDaniel.’ !! ‘’;
            my $previous-ticket = $ticket ?? ‘Preivous ticket: #’ ~ $ticket<number> !! ‘’;

            $body .= subst: ‘｢MODULE｣’, $name;
            $body .= subst: ‘｢MODULE-URL｣’, “https://modules.perl6.org/dist/$module”;
            $body .= subst: ‘｢BLIN-MESSAGE｣’, $module<status>;
            $body .= subst: ‘｢OUTPUT｣’, $module<output>;
            $body .= subst: ‘｢PING-AUTHOR｣’, $ping-author;
            $body .= subst: ‘｢PREVIOUS-TICKET｣’, $previous-ticket;

            # submit-issue(:$token, :$title, :$body, :@labels);

        }
    }
}
