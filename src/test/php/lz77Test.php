<?php
require_once 'PHPUnit/Framework.php';
require_once 'main/php/lz77.php';

class LZ77Test extends PHPUnit_Framework_TestCase {

	protected $compressor;
	protected $textData = "ababassbabasbabbbaababassbababsbasbasbbabbbababababaaaaabbbab";
	protected $encodedTextData = "ababassbabasbabbba` '&bs` 1 sb` 4!` . abaaaa` *!";

	protected function setUp() {
		$this->compressor = new LZ77();
	}

	public function testCompress() {
		$this->assertNotNull($this->compressor);
		$result = $this->compressor->compress($this->textData);
		$this->assertNotNull($result);
		$this->assertEquals($this->encodedTextData, $result);
	}

	public function testDecompress() {
		$this->assertNotNull($this->compressor);
		$result = $this->compressor->decompress($this->encodedTextData);
		$this->assertNotNull($result);
		$this->assertEquals($this->textData, $result);
	}
}

?>
