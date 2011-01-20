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
-module(lz77).

-author('me@paulsawaya.com').
-author('olle@studiomediatech.com').

-export([decompress/1, compress/1]).

%% @doc
%% Decompresses an LZ77 encoded data string.
%% @end
decompress(String) ->
    decode(String, [], 256).
    %Dico = dict:new(),
    %decompress(String, Dico, 256, [], [], []).

decode([], Acc, _WindowLength) ->
    lists:reverse(Acc);
decode([$` | Rest], Acc, WindowLength) ->
    decode_rest(Rest, Acc, WindowLength);
decode([Char | Rest], Acc, WindowLength) ->
    NextAcc = [Char | Acc],
    decode(Rest, NextAcc, WindowLength).

decode_rest([$` | Rest], Acc, WindowLength) ->
    decode(Rest, [$` | Acc], WindowLength);
decode_rest([Code | Rest], Acc, WindowLength) ->
    decode(Rest, [Code | Acc], WindowLength).

%% decompress([], _, _, _, _, Result) ->
%%     lists:flatten(Result);
%% decompress([Code | String], Dico, NbChar, Buffer, Chain, Result) ->
%%     Current = is_ascii_or_in_dict(Dico, Code),
%%     case Buffer of
%%         [] ->
%%             NewBuffer = listify(Current), 
%%             NewResult = Result ++ listify(Current),
%%             decompress(String, Dico, NbChar, NewBuffer, Chain, NewResult);
%%         _ ->
%%             if
%%                 Code =< 255 ->
%%                     NewResult = Result ++ listify(Current),
%%                     NewChain = Buffer ++ listify(Current),

%%                     NewDico = dict:append(NbChar, NewChain, Dico),
%%                     NewBuffer = listify(Current),
%%                     decompress(String, NewDico, NbChar+1, NewBuffer, NewChain, NewResult);

%%                 true ->
%%                     if 
%%                         Current == [] ->
%%                             NewChain = Buffer ++ listify(nth_or_empty_list(1, Buffer));

%%                         true ->
%%                             NewChain = listify(Current)
%%                     end,

%%                     NewResult = Result ++ listify(NewChain),

%%                     NewDico = dict:append(NbChar, Buffer ++ listify(nth_or_empty_list(1, NewChain)),  Dico),
%%                     NewBuffer = NewChain,

%%                     decompress(String, NewDico, NbChar+1, NewBuffer, NewChain, NewResult)
%% 	    end
%%     end.

compress(String) ->
    Dico = dict:new(),
    compress(String ++ [0], Dico, [], 256, []).
    
compress([], _, _, _, Result) ->
    Result;

compress([Current|String], Dico, Buffer, NbChar, Result) ->
    case is_ascii_or_in_dict(Dico, Buffer ++ [Current]) of
        [] ->
            AddToRes = is_ascii_or_in_dict(Dico, Buffer),
            
            if 
                AddToRes == [] -> 
                    throw(notFoundInBuffer);
                true ->
                    NewResult = Result ++ listify(AddToRes),
                    NewDico = dict:append(Buffer ++ [Current], NbChar, Dico),
                    NewNbChar = NbChar + 1,
                    NewBuffer = [Current],
                    compress(String, NewDico, NewBuffer, NewNbChar, NewResult)
            
            end;
        
        _ ->
            compress(String, Dico, Buffer ++ [Current], NbChar, Result)
    end.
          
nth_or_empty_list(N, List) ->
    if
        length(List) >= N ->
            lists:nth(N, List);
            
        true ->
            []
    end.

listify(Thing) when is_list(Thing) ->
    Thing;

listify(Thing) ->
    [Thing].
    
is_ascii_or_in_dict(Dico, [Lookup]) ->
    is_ascii_or_in_dict(Dico, Lookup);

is_ascii_or_in_dict(Dico, Lookup) ->
    case dict:find(Lookup, Dico) of
        error ->
            if
                ((Lookup >= 0) and (Lookup =< 256)) ->
						%If lookup is an ASCII char, just return it without storing them in the Dico
                    Lookup;
                true ->
                    []
            end;

        {ok, [Value]} ->
	    Value
    end.
