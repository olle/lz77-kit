require 'test/unit'
require 'temp/lz77'

class LZ77Test < Test::Unit::TestCase
	def setup
    	@encodedTextData = "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!"
		@textData = "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab"
		@compressor = Compressor.new
	end

	def testCompress
		assert_equal(@encodedTextData, @compressor.compress(@textData))
	end
	
	def testDecompress
		assert_equal(@textData, @compressor.decompress(@encodedTextData))
	end
end