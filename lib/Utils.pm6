unit module Utils;


sub get-issues($url,$token) is export {
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
