require 'test/unit'
require 'temp/lz77'

class LZ77Test < Test::Unit::TestCase
	def setup
    	@encodedTextData = "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!"
		@textData = "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab"
		@compressor = Compressor.new
	end

	def testCompress
		result = @compressor.compress(@textData)
		assert_equal(@encodedTextData, result)
	end
	
	def testDecompress
		result = @compressor.decompress(@encodedTextData)
		assert_equal(@textData, result)
	end
end