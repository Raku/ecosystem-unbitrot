use Unbitrot::Utils;

unit main multi MAIN(
    ‘I know what I'm doing’,
    $token,
    IO() $blin-data = ‘data.json’,
);

my $data = from-json slurp $blin-data;

my @issues = get-issues;
