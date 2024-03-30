extends Node

signal connection_closed
signal connection_established
signal connection_error
signal data_received

#var _client = WebSocketClient.new()
var _client = WebSocketPeer.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT

func _encode_data(data):
	return data.to_utf8_buffer()

func _decode_data(data):
	return data.get_string_from_utf8()

func _init():
	self.connection_closed.connect(_connection_closed)
#	self.connection_established.connect(_connection_established)
	self.connection_error.connect(_connection_error)
#	self.data_received.connect(_data_received)

func _connection_error():
	if get_parent().debugPrint :
		print('GYMGODOT : Connection error \n')

func _connection_closed(_was_clean_close):
	if get_parent().debugPrint :
		print('GYMGODOT : Connection closed \n')

func _process(_delta):
	# print("polling...")
	_client.poll()
	var state = _client.get_ready_state()
	
	if state == WebSocketPeer.STATE_CONNECTING:
		print("GYMGODOT : Connecting...")
	elif state == WebSocketPeer.STATE_OPEN:
		while _client.get_available_packet_count():
			var packet = _client.get_packet()
			var msg = _decode_data(packet)
			print('GYMGODOT : Msg : ' + msg)

			var json = JSON.new()
			var parseError = json.parse(msg)
			var parsedMsg = json.data
			#print('GYMGODOT : parsedMsg : ' + parsedMsg)

			if get_parent().debugPrint :
				print('GYMGODOT : Received & Parsed data : %s \n' % [str(parsedMsg)])

			# Read the received command and call the corresponding function
			if parsedMsg['cmd'] == 'reset' :
				get_parent().reset()
			elif parsedMsg['cmd'] == 'step' :
				get_parent().step(parsedMsg['action'])
			elif parsedMsg['cmd'] == 'close' :
				get_parent().close()
			elif parsedMsg['cmd'] == 'render' :
				get_parent().render()
			else :
				if get_parent().debugPrint :
					print('GYMGODOT : Unrecognized message')
	elif state == WebSocketPeer.STATE_CLOSED:
		print('GYMGODOT : Server connection lost, exit \n')
		get_tree().quit()
		return
	

func _exit_tree():
	_client.close()

func connect_to_server(host, port):
	var url = 'ws://' + host + ':' + str(port)
	if get_parent().debugPrint :
		print('GYMGODOT : Connecting to ' + str(url))
	_client.connect_to_url(url)

func send_to_server(data):
	if get_parent().debugPrint :
		print('GYMGODOT : Sending : ' + str(data) + '\n')
	_client.put_packet(_encode_data(data))
	
func close():
	_client.close()
