<?php


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
 * CREDIT: From an initial implementation in Python by Diogo Kollross, made 
 *         publicly available on http://www.geocities.com/diogok_br/lz77.
 */

/**
 * This class provides simple LZ77 compression and decompression. 
 *
 * @author Olle Törnström olle[at]studiomediatech[dot]com
 * @created 2009-02-20
 */
class LZ77 {

	// MEMBER VARIABLES

	private $referencePrefix;
	private $referenceIntBase;
	private $referenceIntFloorCode;
	private $referenceIntCeilCode;
	private $maxStringDistance;
	private $minStringLength;
	private $maxStringLength;
	private $defaultWindowLength;
	private $maxWindowLength;

	// PUBLIC METHODS

	/**
	 * Constructor for an LZ77 compressor.
	 *
	 *<h4>Optional settings</h4>
	 *<ul>
	 *<li><code>referenceIntBase</code> default 96</li>
	 *<li><code>minStringLength</code> default 5</li>
	 *<li><code>defaultWindowLength</code> default 144</li>
	 *</ul>
	 * 
	 * @param $settings Optional settings array
	 */
	public function __construct($settings = null) {

		if ($settings == null)
			$settings = array ();

		extract($settings);

		$this->referencePrefix = '`';
		$this->referenceIntBase = isset ($referenceIntBase) ? $referenceIntBase : 96;
		$this->referenceIntFloorCode = ord(' ');
		print $this->referenceIntFloorCode;
		$this->referenceIntCeilCode = $this->referenceIntFloorCode + $this->referenceIntBase - 1;
		$this->maxStringDistance = pow($this->referenceIntBase, 2) - 1;
		$this->minStringLength = isset ($minStringLength) ? $minStringLength : 5;
		$this->maxStringLength = pow($this->referenceIntBase, 1) - 1 + $this->minStringLength;
		$this->defaultWindowLength = isset ($defaultWindowLength) ? $defaultWindowLength : 144;
		$this->maxWindowLength = $this->maxStringDistance + $this->minStringLength;
	}

	/**
	 * Compress some string data using the LZ77 algorithm.
	 * 
	 * @param $data String data to compress
	 * @param $windowLength Optional window length
	 */
	public function compress($data, $windowLength = null) {

		if ($windowLength == null)
			$windowLength = $this->defaultWindowLength;

		if ($windowLength > $this->maxWindowLength) {
			throw new Exception('Window length too large');
		}

		$compressed = '';

		$pos = 0;
		$lastPos = strlen($data) - $this->minStringLength;

		while ($pos < $lastPos) {

			$searchStart = max($pos - $windowLength, 0);

			$matchLength = $this->minStringLength;
			$foundMatch = false;
			$bestMatch = array (
				'distance' => $this->maxStringDistance,
				'length' => 0
			);
			$newCompressed = null;

			while (($searchStart + $matchLength) < $pos) {

				$isValidMatch = (substr($data, $searchStart, $matchLength) == substr($data, $pos, $matchLength)) && ($matchLength < $this->maxStringLength);

				if ($isValidMatch) {

					$matchLength++;
					$foundMatch = true;

				} else {

					$realMatchLength = $matchLength -1;

					if ($foundMatch && ($realMatchLength > $bestMatch['length'])) {

						$bestMatch['distance'] = $pos - $searchStart - $realMatchLength;
						$bestMatch['length'] = $realMatchLength;
					}

					$matchLength = $this->minStringLength;
					$searchStart++;
					$foundMatch = false;
				}
			}

			if ($bestMatch['length']) {

				$newCompressed = $this->referencePrefix . $this->encodeReferenceInt($bestMatch['distance'], 2) . $this->encodeReferenceLength($bestMatch['length']);
				$pos += $bestMatch['length'];

			} else {

				if (substr($data, $pos, 1) != $this->referencePrefix) {
					$newCompressed = substr($data, $pos, 1);
				} else {
					$newCompressed = $this->referencePrefix . $this->referencePrefix;
				}
				$pos++;
			}
			$compressed .= $newCompressed;
		}

		return ($compressed . str_replace('`', '``', substr($data, $pos)));
	}

	/**
	 * Decompresses an LZ77 compressed data string.
	 * 
	 * @param $data An LZ77 data string.
	 */
	public function decompress($data) {

		$decompressed = '';
		$pos = 0;

		while ($pos < strlen($data)) {

			$currentChar = substr($data, $pos, 1);

			if ($currentChar != $this->referencePrefix) {

				$decompressed .= $currentChar;
				$pos++;

			} else {

				$nextChar = substr($data, $pos +1, 1);

				if ($nextChar != $this->referencePrefix) {

					$distance = $this->decodeReferenceInt(substr($data, $pos +1, 2), 2);
					$length = $this->decodeReferenceLength(substr($data, $pos +3, 1));
					$decompressed .= substr($decompressed, strlen($decompressed) - $distance - $length, $length);
					$pos += $this->minStringLength - 1;

				} else {

					$decompressed .= $this->referencePrefix;
					$pos += 2;
				}
			}
		}

		return $decompressed;
	}

	// PRIVATE METHODS

	private function encodeReferenceInt($value, $width) {

		if (($value >= 0) && ($value < (pow($this->referenceIntBase, $width) - 1))) {

			$encoded = '';

			while ($value > 0) {
				$encoded = chr(($value % $this->referenceIntBase) + $this->referenceIntFloorCode) . $encoded;
				$value = floor($value / $this->referenceIntBase);
			}

			$missingLength = $width -strlen($encoded);

			for ($i = 0; $i < $missingLength; $i++) {
				$encoded = chr($this->referenceIntFloorCode) . $encoded;
			}

			return $encoded;

		} else {

			throw new Exception('Reference int out of range: ' + $value + ' (width = ' + $width + ')');
		}
	}

	private function encodeReferenceLength($length) {

		return $this->encodeReferenceInt($length - $this->minStringLength, 1);
	}

	private function decodeReferenceInt($data, $width) {

		$value = 0;

		for ($i = 0; $i < $width; $i++) {

			$value *= $this->referenceIntBase;
			$charCode = ord(substr($data, $i, 1));

			if (($charCode >= $this->referenceIntFloorCode) && ($charCode <= $this->referenceIntCeilCode)) {

				$value += $charCode - $this->referenceIntFloorCode;

			} else {

				throw new Exception('Invalid char code in reference int: ' + $charCode);
			}
		}

		return $value;
	}

	private function decodeReferenceLength($data) {

		return $this->decodeReferenceInt($data, 1) + $this->minStringLength;
	}
}
?>
