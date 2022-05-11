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

=begin pod

=head1 NAME

Netstring - A library for working with netstrings

=head1 SYNOPSIS

=begin code :lang<raku>

use Netstring;

say to-netstring("hello world!"); # 12:hello world!,

my $b = Buf.new(0x68,0x65,0x6c,0x6c,0x6f,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21);
say to-netstring($b);             # 12:hello world!,

to-netstring-buf("hello world!");
# returns Buf:0x<31 32 3a 68 65 6c 6c 6f 20 77 6f 72 6c 64 21 2c>

to-netstring-buf($b);
# returns Buf:0x<31 32 3a 68 65 6c 6c 6f 20 77 6f 72 6c 64 21 2c>

=end code

=head1 DESCRIPTION

Work with netstrings. This currently supports generating netstrings, and
parsing a netstring from an L<IO::Socket|https://docs.raku.org/type/IO::Socket>.

=head1 READING FROM A SOCKET

=begin code :lang<raku>

use Netstring;

my $daemon = IO::Socket::INET.new(
  :localhost<localhost>,
  :localport(42),
  :listen
);

while my $client = $daemon.accept() {
    # The client sends "12:hello world!," as a stream of bytes.
    my $rawcontent = read-netstring($client);
    my $strcontent = $rawcontent.decode;

    say "The client said: $strcontent";
    # prints "The client said: hello world!"

    $client.write($strcontent.flip);
    # sends "!dlrow olleh" back to the client.

    $client.close();
}

=end code

=head1 AUTHOR

Timothy Totten

=head1 COPYRIGHT AND LICENSE

Copyright 2012 - 2016 Timothy Totten

Copyright 2017 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
