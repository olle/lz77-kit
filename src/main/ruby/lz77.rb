# The MIT License
# 
# Copyright (c) 2010 Olle Törnström studiomediatech.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# @author Olle Törnström olle[at]studiomediatech[dot]com
# @created 2010-02-07
#
class Compressor

	def initialize
		@referencePrefix = "`"
	    @referencePrefixCode = @referencePrefix[0]
		@referenceIntBase = 96
		@referenceIntFloorCode = " "[0]
		@referenceIntCeilCode = @referenceIntFloorCode + @referenceIntBase - 1
		@maxStringDistance = @referenceIntBase ** 2 - 1
		@minStringLength = 5
		@maxStringLength = @referenceIntBase ** 1 - 1 + @minStringLength
		@maxWindowLength = @maxStringDistance + @minStringLength;
		@defaultWindowLength = 144
	end

	def compress(data, windowLength = @defaultWindowLength)
		compressed = ""
		pos = 0
		lastPos = data.length - @minStringLength
		while pos < lastPos do
			searchStart = [pos - windowLength, 0].max
			matchLength = @minStringLength
			foundMatch = false
			bestMatchDistance = @maxStringDistance
			bestMatchLength = 0
			newCompressed = nil
			while (searchStart + matchLength) < pos do
				m1 = data[searchStart, matchLength]
				m2 = data[pos, matchLength]
				isValidMatch = (m1 == m2 and matchLength < @maxStringLength)
				if isValidMatch then
					matchLength += 1
					foundMatch = true
				else
					realMatchLength = matchLength - 1
					if foundMatch and realMatchLength > bestMatchLength then
						bestMatchDistance = pos - searchStart - realMatchLength
						bestMatchLength = realMatchLength
					end
					matchLength = @minStringLength
					searchStart += 1
					foundMatch = false
				end
			end
			if bestMatchLength > 0 then
				head = "" << @referencePrefix
				head << encodeReferenceInt(bestMatchDistance, 2)
				tail = encodeReferenceLength(bestMatchLength)
				newCompressed = ""
				newCompressed = head << tail
				pos += bestMatchLength
			else
				if data[pos, 1] != @referencePrefix then
					newCompressed = data[pos, 1]
				else
					newCompressed = @referencePrefix << @referencePrefix
				end
				pos += 1
			end
			compressed << newCompressed
		end
		return compressed + data[pos..-1].gsub(/`/, "``")
	end
	
	def decompress(data)
		decompressed = ""
		pos = 0
		while pos < data.length do
			currentChar = data[pos, 1]
			if currentChar != @referencePrefix then
				decompressed << currentChar				
				pos += 1
			else
				nextChar = data[pos + 1, 1]
				if nextChar != @referencePrefix then
					distance = decodeReferenceInt(data[pos + 1, 2], 2)
					length = decodeReferenceLength(data[pos + 3, 1])
					start = decompressed.length - distance - length
					stop = start + length
					decompressed << decompressed[start..stop-1]
					pos += @minStringLength - 1
				else
					decompressed << @referencePrefix
					pos += 2
				end
			end
		end
		return decompressed
	end
	
	private # PRIVATE METHODS **************************************************

	def encodeReferenceInt(value, width)
		encoded = ""
		if value >= 0 and value < ((@referenceIntBase ** width) - 1) then
			while value > 0 do
				encoded = ((value % @referenceIntBase) + @referenceIntFloorCode).chr << encoded
				value = value / @referenceIntBase
			end
			missingLength = width - encoded.length
			(0..missingLength-1).each do
				encoded = (@referenceIntFloorCode).chr << encoded
			end
			return encoded
		else
			raise "Reference value out of range"
		end
	end

	def encodeReferenceLength(length)
		return encodeReferenceInt(length - @minStringLength, 1)
	end
	
	def decodeReferenceInt(data, width)
		value = 0
		(0..width-1).each do |i|
			value *= @referenceIntBase			
			charCode = data[i]
			if charCode >= @referenceIntFloorCode and charCode <= @referenceIntCeilCode then
				value += (charCode - @referenceIntFloorCode)
			else
				raise "Invalid char code"
			end
		end
		return value
	end

	def decodeReferenceLength(data)
		return decodeReferenceInt(data, 1) + @minStringLength
	end
	
end