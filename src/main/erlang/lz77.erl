%%% The MIT License
%%% 
%%% Copyright (c) 2009 Olle Törnström studiomediatech.com
%%%
%%% Permission is hereby granted, free of charge, to any person obtaining a copy
%%% of this software and associated documentation files (the "Software"), to deal
%%% in the Software without restriction, including without limitation the rights
%%% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
%%% copies of the Software, and to permit persons to whom the Software is
%%% furnished to do so, subject to the following conditions:
%%%
%%% The above copyright notice and this permission notice shall be included in
%%% all copies or substantial portions of the Software.
%%% 
%%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
%%% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
%%% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
%%% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
%%% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
%%% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
%%% THE SOFTWARE.
%%%
%%% CREDITS: This implementation was inspired by an Erlang LZ77 contribution
%%%          from https://github.com/psawaya that I received a loooong time ago.
%%%          I decided to clean up the code "a little" and ended up writing the
%%%          compression implementation clean new with some bit matching syntax.
%%%          I'm leaving the author reference though, and a big thanks for the
%%%          inspiration!
%%% ----------------------------------------------------------------------------
-module(lz77).

-author('me@paulsawaya.com').
-author('olle@studiomediatech.com').

-export([decompress/1, compress/1]).

-define(CODE_MASK, 32).
-define(CODE_BASE, 96).
-define(MIN_STRING_LENGTH, 5).
-define(WINDOW_LENGTH, 144).

%% @doc
%% Decompresses an LZ77 encoded data string.
%% @end
decompress(String) ->
    decode(String, []).

%% @doc
%% Compresses string data using the LZ77 algorithm.
%% @end
compress(String) ->
    encode(String, []).

%% ----------------------------------------------------------------------------
%% INTERNAL FUNCTIONS
%% ----------------------------------------------------------------------------

decode([], Acc) ->
    lists:reverse(Acc);
decode([$` | Rest], Acc) ->
    decode_compression(list_to_binary(Rest), Acc);
decode([Char | Rest], Acc) ->    
    decode(Rest, [Char | Acc]).

decode_compression(<<$`, Rest/binary>>, Acc) ->
    decode(binary_to_list(Rest), [$` | Acc]);
decode_compression(<<B1:8/integer, B2:8/integer, B3:8/integer, Rest/binary>>, Acc) ->
    {Distance, Length} = decode_compression_bytes(B1, B2, B3),
    Source = lists:reverse(Acc),
    Start = length(Source) - Distance - Length,
    BackRef = lists:reverse(lists:sublist(Source, Start + 1, Length)),
    NextAcc = lists:flatten([BackRef | Acc]),
    NextRest = binary_to_list(Rest),
    decode(NextRest, NextAcc).

decode_compression_bytes(PMSB, PLSB, LB) ->
    Position = decode_position(PMSB, PLSB),
    Length = decode_length(LB),
    {Position, Length}.

decode_position(PositionMSByte, PositionLSByte) ->
    MSValue = (PositionMSByte bxor ?CODE_MASK) * ?CODE_BASE,
    LSValue = (PositionLSByte bxor ?CODE_MASK),
    MSValue + LSValue.

decode_length(LengthByte) ->
    (LengthByte bxor ?CODE_MASK) + ?MIN_STRING_LENGTH.


encode([], Acc) ->
    lists:reverse(Acc);
encode([Char | Rest], Acc) ->
    % TODO: Implement encoding :o
    encode(Rest, [Char | Acc]).

