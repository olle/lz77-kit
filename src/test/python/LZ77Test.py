import unittest
from lz77 import Compressor

class LZ77Test(unittest.TestCase):
    def setUp(self):
        self.textData = "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab"
        self.encodedTextData = "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!"
        self.compressor = Compressor();
    def testCorrectCompressedOutput(self):
        print "testCorrectCompressedOutput:"
        result = self.compressor.compress(self.textData)
        print self.encodedTextData
        print result
        assert result == self.encodedTextData, "must match" 
    def testCorrectDecompressedOutput(self):
        print "testCorrectDecompressedOutput:"
        result = self.compressor.decompress(self.encodedTextData)
        print self.textData
        print result
        assert result == self.textData, "must match" 

if __name__ == "__main__":
    unittest.main()
