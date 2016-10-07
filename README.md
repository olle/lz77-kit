LZ77 Kit
========

The lz77-kit is aimed at being another tool in the web-mans tool belt, enabling
a simple and very pragmatic compression utility for various languages. It's
perhaps not the sharpest compression-knife for heavy-duty cutting, but may
suite some craft(wo)mens needs.

This could be a simple way for you to throttle down on some of that bandwidth
usage, at least a few bytes or so. And a byte saved is a byte earned!

Currently features [LZ77](http://en.wikipedia.org/wiki/LZ77_and_LZ78)
implementations for the following languages:

- JavaScript
- PHP
- Python
- Java
- Ruby
- Erlang

### Language wish-list

- Go
- OCaml
- Haskell
- Clojure
- Swift
- ObjectiveC

> Are you missing a language? Please get involved and contribute!

## Getting started

1. Get the project source code
2. Go to the project directory
3. Test and build using [Ant](http://ant.apache.org) on the comand line.

To build and test all the current LZ77 implementation use the default build target:

    shell$> ant
    
For more build information and project build targets, you may run:
    
    shell$> ant -p

Look in the `./output` folder for the built artifacts and copy/paste what you
need. Please keep the license and credits in any generated source code or scripts.

Thank you!

## A note on requirements

Being a project with such a broad programming language base, the requirements
are more or less dependent on your target build platform. It's of course
only possible to do a _complete build_ if **all** programming languages are
installed on that system.

I've lately had success building the project using the following:

- Ant 1.9.4
- PHP 5.4.30
- Java 1.8.0
- Python 2.7.5
- Ruby 2.0.0p481
- Erlang/OTP 17

Oh, and by the way, my shell have slashes that slant "the right way" (/).

## Contributing

The most source code have unit tests and the project is pretty independent, or
free from third party dependencies, so it should be easy for any developer,
with a decent environment, to clone and and start working with the code.

### Guidelines

- Try to keep the self-dependent structure, add libs and dependencies into
  the project but be _very_ sparse.

- Write tests and wire them to work with the Ant `build.xml` buildfile.

- Keep implementations simple and open to copy/paste (e.g. no packages or
  namespaces if possible).

- Code with joy, not in anger!

This is all done with the hope of being of use to someone out there.
