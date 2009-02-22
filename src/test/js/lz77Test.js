
/*
 * Copyright (c) 2008-2009 Olle Törnström studiomediatech.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// FIXTURES
var compressor = {};
var textData = "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab";
var encodedTextData = "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!";
// TESTS
var LZ77Test = {};
LZ77Test.setUp = function () {
	compressor = new LZ77();
};
LZ77Test.testCompressor = function () {
	assertTrue(compressor instanceof LZ77);
};
LZ77Test.testCompress = function () {
	var result = compressor.compress(textData);
	assertTrue(result.length > 0);
	assertNotEquals(textData, result);
	assertEquals(encodedTextData, result);
	var revert = compressor.decompress(result);
	assertEquals(textData, revert);
};
LZ77Test.testSneakyCompress = function () {
	var test = "ababasbbbbaaabsbsbaabbaabab`abababab`abababbbaa";
	var result = compressor.compress(test);
	assertNotEquals(test, result);
	var revert = compressor.decompress(result);
	assertEquals(test, revert);
};
TestCase.LZ77Test = LZ77Test;

