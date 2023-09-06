#!perl -w

my $limit_formats = shift || "";
my %limit_formats;
map {$limit_formats{$_} = 1} split/,/,$limit_formats;

my %format_dir;
$_ = qx{pandoc --list-input-formats}; chomp;
map {
  $limit_formats && !$limit_formats{$_} or
    $format_dir{$_} = "i";
} split/\n/;
my @formats = sort keys %format_dir;

$_ = qx{pandoc --list-output-formats}; chomp;
map {
  $limit_formats && !$limit_formats{$_} or
    $format_dir{$_} = $format_dir{$_} ? "io" : "o";
} split/\n/;

my $ext_len;
$_ = qx{pandoc --list-extensions}; chomp;
my @extensions = map {
  my $ext = substr($_,1) ; # drop first char +/-
  !$ext_len || $ext_len < length($ext) and $ext_len = length($ext);
  $ext
} split/\n/;

my %format_ext;
for my $f (@formats) {
  $_ = qx{pandoc --list-extensions=$f}; chomp;
  map {
    my ($char,$ext) = m{(.)(.*)};
    $format_ext{$f}{$ext} = $char;
  } split/\n/;
};

my $fmt = "| %-${ext_len}s | ".(join" | ", map "%-".length($_)."s", @formats)." |\n";
my $dashes = "|-".("-"x$ext_len)."-|-".(join"-|-", map "-" x length($_), @formats)."-|\n";
printf $fmt, "<format>",@formats;
print $dashes;
printf $fmt, "<direction>",(map $format_dir{$_}, @formats);

for my $ext (@extensions) {
  printf $fmt, $ext, (map $format_ext{$_}{$ext} || "n", @formats)
};
