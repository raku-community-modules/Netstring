[![Actions Status](https://github.com/raku-community-modules/Netstring/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/Netstring/actions)

NAME
====

Netstring - blah blah blah

SYNOPSIS
========

```raku
use Netstring;

say to-netstring("hello world!"); # 12:hello world!,

my $b = Buf.new(0x68,0x65,0x6c,0x6c,0x6f,0x20,0x77,0x6f,0x72,0x6c,0x64,0x21);
say to-netstring($b);             # 12:hello world!,

to-netstring-buf("hello world!");
# returns Buf:0x<31 32 3a 68 65 6c 6c 6f 20 77 6f 72 6c 64 21 2c>

to-netstring-buf($b);
# returns Buf:0x<31 32 3a 68 65 6c 6c 6f 20 77 6f 72 6c 64 21 2c>
```

DESCRIPTION
===========

Work with netstrings. This currently supports generating netstrings, and parsing a netstring from an [IO::Socket](https://docs.raku.org/type/IO::Socket).

READING FROM A SOCKET
=====================

```raku
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
```

AUTHOR
======

Timothy Totten

COPYRIGHT AND LICENSE
=====================

Copyright 2012 - 2016 Timothy Totten

Copyright 2017 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

