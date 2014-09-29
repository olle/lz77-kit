-module(lz77_test).

-include_lib("eunit/include/eunit.hrl").

-define(DECODED, "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab").
-define(ENCODED, "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!").

compress_test() ->
    ActualEncoded = lz77:compress(?DECODED),
    io:fwrite(ActualEncoded ++ "\n"),
    ?assertEqual(?ENCODED, ActualEncoded).

decompress_test() ->
    ActualDecoded = lz77:decompress(?ENCODED),
    io:fwrite(ActualDecoded ++ "\n"),
    ?assertEqual(?DECODED, ActualDecoded).
