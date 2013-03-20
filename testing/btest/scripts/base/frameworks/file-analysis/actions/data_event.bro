# @TEST-EXEC: bro -r $TRACES/http/get.trace %INPUT >out
# @TEST-EXEC: btest-diff out

event file_chunk(info: FileAnalysis::Info, data: string, off: count)
    {
    print "file_chunk", info$file_id, |data|, off, data;
    }

event file_stream(info: FileAnalysis::Info, data: string)
    {
    print "file_stream", info$file_id, |data|, data;
    }

hook FileAnalysis::policy(trig: FileAnalysis::Trigger, info: FileAnalysis::Info)
	{
	print trig;

	switch ( trig ) {
	case FileAnalysis::TRIGGER_NEW:
		print info$file_id, info$seen_bytes, info$missing_bytes;

		print FileAnalysis::add_action(info$file_id,
		                               [$act=FileAnalysis::ACTION_DATA_EVENT,
		                                $chunk_event=file_chunk,
		                                $stream_event=file_stream]);
		break;

	case FileAnalysis::TRIGGER_BOF_BUFFER:
		if ( info?$bof_buffer )
			print info$bof_buffer[0:10];
		break;

	case FileAnalysis::TRIGGER_TYPE:
		# not actually printing the values due to libmagic variances
		if ( info?$file_type )
			print "file type is set";
		if ( info?$mime_type )
			print "mime type is set";
		break;

	case FileAnalysis::TRIGGER_EOF:
		fallthrough;
	case FileAnalysis::TRIGGER_DONE:

		print info$file_id, info$seen_bytes, info$missing_bytes;
		print info$conn_uids;
		print info$conn_ids;

		if ( info?$total_bytes )
			print "total bytes: " + fmt("%s", info$total_bytes);
		if ( info?$source )
			print "source: " + info$source;
		break;
	}
	}
