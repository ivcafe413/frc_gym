extends Node

signal connection_closed
signal connection_established
signal connection_error
signal data_received

#var _client = WebSocketClient.new()
var _client = WebSocketPeer.new()
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT

func _encode_data(data):
	return data.to_utf8()

func _decode_data(data):
	return data.get_string_from_utf8()

func _init():
	self.connect('connection_closed', Callable(self, '_connection_closed'))
	self.connect('connection_established', Callable(self, '_connection_established'))
	self.connect('connection_error', Callable(self, '_connection_error'))
	self.connect('data_received', Callable(self, '_data_received'))

func _connection_established(_protocol):
	if get_parent().debugPrint :
		print('GYMGODOT : Connection established \n')
	_client.get_peer(1).set_write_mode(_write_mode)

func _connection_error():
	if get_parent().debugPrint :
		print('GYMGODOT : Connection error \n')

func _connection_closed(_was_clean_close):
	if get_parent().debugPrint :
		print('GYMGODOT : Connection closed \n')

func _peer_connected(id):
	if get_parent().debugPrint :
		print('GYMGODOT : %s: Peer just connected \n' % id)

func _data_received():
	var packet = _client.get_peer(1).get_packet()
	var msg = _decode_data(packet)
	var json = JSON.new()
	var parsedMsg = json.parse(msg)
	
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

func _process(_delta):
	if _client.get_connection_status() == WebSocketPeer.STATE_CLOSED:
		print('GYMGODOT : Server connection lost, exit \n')
		get_tree().quit()
		return
	_client.poll()

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
	_client.get_peer(1).put_packet(_encode_data(data))
	
func close():
	_client.close()
