#!/usr/bin/env escript
%% -*- erlang -*-
main(_) ->
  compile:file(lz77),
  compile:file(lz77_test),
  ok.

