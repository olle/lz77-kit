import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

public class LZ77Test {

	LZ77 compressor;
	String textData = "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab";
	String encodedTextData = "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!";

	@Before
	public void constructCompressor() {
		compressor = new LZ77();
	}

	@Test
	public void ensureThatCompressorIsNotNull() {
		assertNotNull(compressor);
	}

	@Test
	public void ensureRightOutputWhenCompressing() {
		String result = compressor.compress(textData);
		System.out.println("COMPRESSED: " + result);
		assertEquals(encodedTextData, result);
	}

	@Test
	public void ensureRightOutputWhenDecompressing() {
		String result = compressor.decompress(encodedTextData);
		System.out.println("DECOMPRESSED: " + result);
		assertEquals(textData, result);
	}
	
	@Test
	public void ensureStaticHelpersEncodeCorrectly() {
		String result = LZ77.compressStr(textData);
		assertEquals(encodedTextData, result);
	}
	
	@Test
	public void ensureStaticHelperDecodesCorrectly() {
		String result = LZ77.decompressStr(encodedTextData);
		assertEquals(textData, result);
	}
	
	@Test
	public void ensureShowsUsageThreeTimes() {
				
		LZ77.main(null);
		LZ77.main(new String[] {"foo", "bar", "baz"});
		LZ77.main(new String[] { "-q", encodedTextData });
	}
	
	@Test
	public void ensureCompressAndDecompress() {
		
		LZ77.main(new String[] { textData });
		LZ77.main(new String[] { "-d", encodedTextData });
	}
}
