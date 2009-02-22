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
		assertEquals(encodedTextData, result);
	}

	@Test
	public void ensureRightOutputWhenDecompressing() {
		String result = compressor.decompress(encodedTextData);
		assertEquals(textData, result);
	}
}
