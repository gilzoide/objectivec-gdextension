extends RefCounted

static var ObjectiveC = Engine.get_singleton("ObjectiveC")


func test_construct_and_read_data() -> bool:
	var text = "Hello world!"
	var bytes = text.to_utf8_buffer()
	var data = ObjectiveC.NSData.invoke("dataWithBytes:length:", bytes, bytes.size())
	assert(data != null, "NSData should not be null")
	assert(data.length == bytes.size(), "NSData size should match bytes.size()")

	var read_bytes = PackedByteArray()
	read_bytes.resize(data.length)
	data.invoke("getBytes:length:", read_bytes, read_bytes.size())
	assert(read_bytes == bytes)

	return true
