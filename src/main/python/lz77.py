class Compressor:
	
	def __init__(self):
		self.referencePrefix = "`"
		self.referencePrefixCode = ord(self.referencePrefix)
		self.referenceIntBase = 96
		self.referenceIntFloorCode = ord(" ")
		self.referenceIntCeilCode = self.referenceIntFloorCode + self.referenceIntBase - 1
		self.maxStringDistance = self.referenceIntBase ** 2 - 1
		self.minStringLength = 5
		self.maxStringLength = self.referenceIntBase ** 1 - 1 + self.minStringLength
		self.maxWindowLength = self.maxStringDistance + self.minStringLength;		
		self.defaultWindowLength = 144
		
	def compress(self, data, windowLength = None):
		if windowLength == None:
			windowLength = self.defaultWindowLength
	
		compressed = ""
		pos = 0
		lastPos = len(data) - self.minStringLength
		
		while pos < lastPos:
			
			searchStart = max(pos - windowLength, 0);
			matchLength = self.minStringLength
			foundMatch = False
			bestMatchDistance = self.maxStringDistance
			bestMatchLength = 0
			newCompressed = None
			
			while (searchStart + matchLength) < pos:
				
				m1 = data[searchStart:searchStart + matchLength]
				m2 = data[pos:pos + matchLength]
				isValidMatch = (m1 == m2 and matchLength < self.maxStringLength)
				
				if isValidMatch:
					matchLength += 1
					foundMatch = True
				else:
					realMatchLength = matchLength - 1
					
					if foundMatch and realMatchLength > bestMatchLength:
						bestMatchDistance = pos - searchStart - realMatchLength
						bestMatchLength = realMatchLength
						
					matchLength = self.minStringLength
					searchStart += 1
					foundMatch = False
					
			if bestMatchLength:
				newCompressed = (self.referencePrefix + self.__encodeReferenceInt(bestMatchDistance, 2) + self.__encodeReferenceLength(bestMatchLength))
				pos += bestMatchLength
			else:
				if data[pos] != self.referencePrefix:
					newCompressed = data[pos]
				else:
					newCompressed = self.referencePrefix + self.referencePrefix
				pos += 1	
			
			compressed += newCompressed
		
		return compressed + data[pos:].replace("`", "``")
	
	def decompress(self, data):
		decompressed = ""
		pos = 0
		while pos < len(data):
			currentChar = data[pos]
			if currentChar != self.referencePrefix:
				decompressed += currentChar
				pos += 1
			else:
				nextChar = data[pos + 1]
				if nextChar != self.referencePrefix:
					distance = self.__decodeReferenceInt(data[pos + 1:pos + 3], 2)
					length = self.__decodeReferenceLength(data[pos + 3])
					start = len(decompressed) - distance - length
					end = start + length
					decompressed += decompressed[start:end]
					pos += self.minStringLength - 1
				else:
					decompressed += self.referencePrefix
					pos += 2
					
		return decompressed

	def __encodeReferenceInt(self, value, width):
		if value >= 0 and value < (self.referenceIntBase ** width - 1):
			encoded = ""
			while value > 0:
				encoded = chr((value % self.referenceIntBase) + self.referenceIntFloorCode) + encoded
				value = int(value / self.referenceIntBase)
			
			missingLength = width - len(encoded)
			for i in range(missingLength):
				encoded = chr(self.referenceIntFloorCode) + encoded
				
			return encoded
 		else:
			raise Exception("Reference value out of range: %d (width = %d)" % (value, width))
		
	def __encodeReferenceLength(self, length):
		return self.__encodeReferenceInt(length - self.minStringLength, 1)
	
	def __decodeReferenceInt(self, data, width):
		value = 0
		for i in range(width):
			value *= self.referenceIntBase
			charCode = ord(data[i])
			if charCode >= self.referenceIntFloorCode and charCode <= self.referenceIntCeilCode:
				value += charCode - self.referenceIntFloorCode
			else:
				raise Exception("Invalid char code: %d" % charCode)
			
		return value
	
	def __decodeReferenceLength(self, data):
		return self.__decodeReferenceInt(data, 1) + self.minStringLength
	
