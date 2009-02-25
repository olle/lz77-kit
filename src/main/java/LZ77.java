/*
 * The MIT License
 * 
 * Copyright (c) 2009 Olle Törnström studiomediatech.com
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
 *
 * CREDIT: Initially implemented by Diogo Kollross and made publicly available
 *         on the website http://www.geocities.com/diogok_br/lz77. Edited here
 *         to provide two flavours for JavaScript usage, either as standalone
 *         compressor/decompressor or as class for copy/paste use.
 */

/**
 * This class provides simple LZ77 compression and decompression.
 * 
 * USAGE: Place in your own project package of choice adding preferred package
 *        setting.
 * 
 * @author Olle Törnström olle[at]studiomediatech[dot]com
 * @created 2009-02-18
 */
public class LZ77 {

	private char referencePrefix;
	private int referenceIntBase;
	private int referenceIntFloorCode;
	private int referenceIntCeilCode;
	private int maxStringDistance;
	private int minStringLength;
	private int maxStringLength;
	private int defaultWindowLength;
	private int maxWindowLength;

	// CONSTRUCTOR

	public LZ77() {

		referencePrefix = '`';
		referenceIntBase = 96;
		referenceIntFloorCode = (int) ' ';
		referenceIntCeilCode = referenceIntFloorCode + referenceIntBase;
		maxStringDistance = (int) Math.pow(referenceIntBase, 2) - 1;
		minStringLength = 5;
		maxStringLength = (int) Math.pow(referenceIntBase, 1) - 1
				+ minStringLength;
		defaultWindowLength = 144;
		maxWindowLength = maxStringDistance + minStringLength;
	}

	// PUBLIC METHODS

	/**
	 * Compress string data using the LZ77 algorithm.
	 * 
	 * @param data
	 *            String data to compress
	 * @return LZ77 compressed string
	 */
	public String compress(String data) {

		return compress(data, null);
	}

	/**
	 * Compress string data using the LZ77 algorithm.
	 * 
	 * @param data
	 *            String data to compress
	 * @param windowLength
	 *            Optional window length
	 * @return LZ77 compressed string
	 */
	public String compress(String data, Integer windowLength) {

		if (windowLength == null)
			windowLength = defaultWindowLength;

		if (windowLength > maxWindowLength)
			throw new IllegalArgumentException("Window length too large");

		String compressed = "";

		int pos = 0;
		int lastPos = data.length() - minStringLength;

		while (pos < lastPos) {

			int searchStart = Math.max(pos - windowLength, 0);
			int matchLength = minStringLength;
			boolean foundMatch = false;
			int bestMatchDistance = maxStringDistance;
			int bestMatchLength = 0;
			String newCompressed = null;

			while ((searchStart + matchLength) < pos) {

				int sourceWindowEnd = Math.min(searchStart + matchLength, data
						.length());

				int targetWindowEnd = Math
						.min(pos + matchLength, data.length());

				String m1 = data.substring(searchStart, sourceWindowEnd);
				String m2 = data.substring(pos, targetWindowEnd);

				boolean isValidMatch = m1.equals(m2)
						&& matchLength < maxStringLength;

				if (isValidMatch) {

					matchLength++;
					foundMatch = true;

				} else {

					int realMatchLength = matchLength - 1;

					if (foundMatch && (realMatchLength > bestMatchLength)) {
						bestMatchDistance = pos - searchStart - realMatchLength;
						bestMatchLength = realMatchLength;
					}

					matchLength = minStringLength;
					searchStart++;
					foundMatch = false;
				}
			}

			if (bestMatchLength != 0) {

				newCompressed = referencePrefix
						+ encodeReferenceInt(bestMatchDistance, 2)
						+ encodeReferenceLength(bestMatchLength);

				pos += bestMatchLength;

			} else {

				if (data.charAt(pos) != referencePrefix) {
					newCompressed = "" + data.charAt(pos);
				} else {
					newCompressed = "" + referencePrefix + referencePrefix;
				}

				pos++;
			}
			compressed += newCompressed;
		}

		return compressed + data.substring(pos).replaceAll("/`/g", "``");
	}

	public String decompress(String data) {

		String decompressed = "";
		int pos = 0;

		while (pos < data.length()) {

			char currentChar = data.charAt(pos);

			if (currentChar != referencePrefix) {

				decompressed += currentChar;
				pos++;

			} else {

				char nextChar = data.charAt(pos + 1);

				if (nextChar != referencePrefix) {

					int distance = decodeReferenceInt(data.substring(pos + 1,
							pos + 3), 2);

					int length = decodeReferenceLength(data.substring(pos + 3,
							pos + 4));

					int start = decompressed.length() - distance - length;
					int end = start + length;
					decompressed += decompressed.substring(start, end);
					pos += minStringLength - 1;

				} else {

					decompressed += referencePrefix;
					pos += 2;
				}
			}
		}

		return decompressed;
	}

	// PRIVATE METHODS

	private String encodeReferenceInt(int value, int width) {

		if ((value >= 0) && (value < (Math.pow(referenceIntBase, width) - 1))) {

			String encoded = "";

			while (value > 0) {
				char c = (char) ((value % referenceIntBase) + referenceIntFloorCode);
				encoded = "" + c + encoded;
				value = (int) Math.floor(value / referenceIntBase);
			}

			int missingLength = width - encoded.length();

			for (int i = 0; i < missingLength; i++) {
				char c = (char) referenceIntFloorCode;
				encoded = "" + c + encoded;
			}

			return encoded;

		} else {

			throw new IllegalArgumentException("Reference int out of range: "
					+ value + " (width = " + width + ")");
		}
	}

	private String encodeReferenceLength(int length) {

		return encodeReferenceInt(length - minStringLength, 1);
	}

	private int decodeReferenceInt(String data, int width) {

		int value = 0;

		for (int i = 0; i < width; i++) {

			value *= referenceIntBase;

			int charCode = (int) data.charAt(i);

			if ((charCode >= referenceIntFloorCode)
					&& (charCode <= referenceIntCeilCode)) {

				value += charCode - referenceIntFloorCode;

			} else {

				throw new RuntimeException(
						"Invalid char code in reference int: " + charCode);
			}
		}

		return value;
	}

	private int decodeReferenceLength(String data) {

		return decodeReferenceInt(data, 1) + minStringLength;
	}
}