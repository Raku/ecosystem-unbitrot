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
my @issues = get-issues $token;
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
            # close-single-issue $ticket<url>, $token
        }
    } else {
        if not $ticket or $ticket<state> eq ‘closed’ {
            note “Creating new issue for $name”;

            my $text = $template-text;
            $text .= subst: ‘｢MODULE｣’, 42;
            $text .= subst: ‘｢MODULE-URL｣’, 42; # https://modules.perl6.org/dist/$module
            $text .= subst: ‘｢OUTPUT｣’, 42;
            $text .= subst: ‘｢PING-AUTHOR｣’, 42;
            $text .= subst: ‘｢PREVIOUS-TICKET｣’, 42;

            # submit-issue $token, $text
        }
    }
}
