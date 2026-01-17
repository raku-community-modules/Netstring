proto to-netstring ($) is export {*}

multi to-netstring(Str:D $str --> Str:D) {
    $str.encode.bytes ~ ':' ~ $str ~ ','
}

multi to-netstring(Blob:D $buf --> Str:D) {
    $buf.bytes ~ ':' ~ $buf.decode ~ ','
}

proto to-netstring-buf ($) is export {*}
multi to-netstring-buf(Str:D $str --> Buf:D) {
    to-netstring-buf $str.encode
}

my constant $colon = ':'.encode;
my constant $comma = ','.encode;
multi to-netstring-buf(Blob:D $buf --> Buf:D) {
    Buf.new(
      $buf.bytes.Str.encode ~ $colon ~ $buf ~ $comma
    )
}

sub read-netstring (IO::Socket:D $in --> Buf:D) is export {
    my int $length;
    my int $byte;
    until ($byte = $in.read(1)[0]) == 58 {       # :
        48 <= $byte <= 57                        # 0 .. 9
          ?? ($length = $length * 10 + ($byte - 48))
          !! (die "Invalid netstring stream data.");
    }
    my $content := $in.read($length);

    (my int $terminator = $in.read(1)[0]) == 44  # ,
      ?? $content
      !! (die "Missing or invalid netstring terminator: &chr($terminator)")
}

# vim: expandtab shiftwidth=4
