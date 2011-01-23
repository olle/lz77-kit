-module(lz77_test).

-include_lib("eunit/include/eunit.hrl").

-define(DECODED, "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab").
-define(ENCODED, "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!").

compress_test() ->
    ?assertEqual(?ENCODED, lz77:compress(?DECODED)).

decompress_test() ->
    ?assertEqual(?DECODED, lz77:decompress(?ENCODED)).
