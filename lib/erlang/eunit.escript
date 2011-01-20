#!/usr/bin/env escript
%% -*- erlang -*-
main([FileName]) ->
  {ok, File} = file:open(FileName, [write]),
  case eunit:test(lz77_test) of
    ok -> file:write(File, "All tests ok");
    {error, Other} -> file:write(File, Other)
  end,
  ok = file:close(File),
  ok.
