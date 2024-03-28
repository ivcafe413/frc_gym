GDPC                 P                                                                         X   res://.godot/exported/133200997/export-08d1e3c2b6ce474532775eb2c79c840a-environment.scn        �      �yv��[,t6qu�ɂ    T   res://.godot/exported/133200997/export-3edaff0b57156128f734968cd24902c3-GymGodot.scn�      �      �^N�<�)��0�72.�    T   res://.godot/exported/133200997/export-a8a6c2d17c22928b6c4c68c746089ba7-robot.scn   p/      �      �M+�tY0����i��1    ,   res://.godot/global_script_class_cache.cfg  �>             ��Р�8���8~$}P�    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex�      �      �̛�*$q�*�́        res://.godot/uid_cache.bin  �B      {       F����w+�9��a� ��       res://Environment.gd        �      ��
���jt	Pr:��       res://GymGodot.gd   �            �jC�@Kd�I�,�,kRJ       res://GymGodot.tscn.remap   �=      e       �Z�XUM¹�'����:       res://WebSocketClient.gd 4      v	      �P�`~[?�,����-K       res://environment.tscn.remap�=      h       �P�\�v-�Z���ku        res://icon.svg  �>      �      C��=U���^Qu��U3       res://icon.svg.import   �*      �       =!p^�؏��\���6�h       res://project.binary0C      �      5e[hT�ҕ���S �C�       res://robot.gd  P+            ڊ�_��`
#9�X*Y%       res://robot.tscn.remap  `>      b       �w7��������        extends Node

func apply_action(action: Array) -> void:
	$Robot.drive_direction = Vector2(action[0], action[1])
	$Robot.rotation_direction = action[2]
	
func get_observation() -> Array:
	return [$Robot.position.x, $Robot.position.y, $Robot.rotation, $Robot.angular_velocity,
		$Robot.linear_velocity.x, $Robot.linear_velocity.y, 0, 0]
	
func get_reward() -> float:
	return 0.0
	
func reset() -> void:
	$Robot.position = Vector2(256, 256)
	$Robot.linear_velocity *= 0
	$Robot.angular_velocity *= 0
	
func is_done() -> bool:
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
        RSRC                    PackedScene            ��������                                                  ..    Environment    resource_local_to_scene    resource_name    custom_solver_bias    size    script 	   friction    rough    bounce 
   absorbent    normal 	   distance 	   _bundled       PackedScene    res://GymGodot.tscn ,]�y�2   Script    res://Environment.gd ��������   PackedScene    res://robot.tscn 'e�teHnX      local://RectangleShape2D_7spo1 l         local://PhysicsMaterial_jek30 �      #   local://WorldBoundaryShape2D_1jiw8 �         local://PackedScene_ak4ru �         RectangleShape2D       
      D   D         PhysicsMaterial            @?	        �?         WorldBoundaryShape2D             PackedScene          	         names "         Field    collision_layer    collision_mask    Area2D 	   GodotGym    enabled    stepLength    environmentNode    Environment    script    Node    FieldShape 	   position    shape    CollisionShape2D    Robot    RightSideBody 	   rotation    physics_material_override    StaticBody2D 
   RightSide    TopSideBody    TopSide    BottomSideBody    BottomSide    LeftSideBody 	   LeftSide    	   variants                                                           
     �C  �C                   
      D  �C   �ɿ                  
     �C       �I@
     �C   D
         �C   ��?      node_count             nodes     �   ��������       ����                             ���                                       
      ����   	                        ����                           ���                                 ����      	      
                          ����                           ����                                      ����                           ����                   	             ����                           ����                                      ����                   conn_count              conns               node_paths              editable_instances              version             RSRC          extends Node

# Enable / disable this node
@export var enabled: bool = true

# Amount of frames simulated per step. 
# During each of these frames, the current action will be applied. 
# Once these frames are elapsed, the reward is computed and returned.
@export var stepLength: int = 2

# Reference to the Environment node which must implement the methods :
# get_observation(), get_reward(), reset(), is_done()
@export var environmentNode: NodePath

# Default url of the server (if not provided through cmdline arguments)
var serverIP : String = '127.0.0.1'
# Default port of the server (if not provided through cmdline arguments)
var serverPort : int = 8888

# Default path to store render frames (if not provided through cmdline arguments)
var renderPath : String = './render_frames/'
# Counter for the rendered frames
var renderFrameCounter : int = 0

# Print debug logs
@export var debugPrint: bool = false

var currentAction : Array
var environment : Node
var frameCounter : int

func _parse_arguments() -> Dictionary :
	var arguments = {}
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find('=') > -1:
			var key_value = argument.split('=')
			arguments[key_value[0].lstrip('--')] = key_value[1]
	return arguments

func _ready() -> void :
	currentAction = []
	environment = get_node(environmentNode)
	frameCounter = 0
	
	if not enabled :
		$WebSocketClient.free()
		return
	# This node will never be paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Initialy, the environment is paused
	get_tree().paused = true
	# Get the server IP/Port from argument
	var arguments = _parse_arguments()
	if 'serverIP' in arguments :
		serverIP = arguments['serverIP']
	if 'serverPort' in arguments :
		serverPort = int(arguments['serverPort'])
	# Get frame render parameters
	if 'renderPath' in arguments :
		renderPath = arguments['renderPath']
	# Connect to the ws server using those IP/port
	$WebSocketClient.connect_to_server(serverIP, serverPort)
	
func _physics_process(_delta : float) -> void :
	if not enabled :
		return
	# Simulate stepLength frames with the current action. 
	# Then pause the game and return the observation/reward/isDone to the server
	if frameCounter >= stepLength :
		get_tree().paused = true
		frameCounter = 0
		_returnData()
	else :
		if !get_tree().paused :
			frameCounter += 1
			environment.apply_action(currentAction)

# Called by WebSocketClient node when it recieve a step msg
func step(action : Array) -> void :
	# Set the action for this new step and run this step
	currentAction = action
	get_tree().paused = false
	
# Called by WebSocketClient node when it recieve a close msg
func close() -> void :
	$WebSocketClient.close()
	get_tree().quit()
	
# Return current observation/reward/isDone to the server
func _returnData() -> void :
	var obs : Array = environment.get_observation()
	var reward : float = environment.get_reward()
	var done : bool = environment.is_done()
	var answer : Dictionary = {'observation': obs, 'reward': reward, 'done': done}
	$WebSocketClient.send_to_server(JSON.stringify(answer))
	
# Called by WebSocketClient when it recieve a reset msg
func reset() -> void :
	environment.reset()
	var obs : Array = environment.get_observation()
	var answer : Dictionary = {'init_observation': obs}
	$WebSocketClient.send_to_server(JSON.stringify(answer))
	renderFrameCounter = 0

# Called by WebSocketClient when it recieve a render msg. 
# Renders to .png in the renderPath folder
func render() -> void :
	RenderingServer.force_draw()
	var screenshot = get_viewport().get_texture().get_data()
	screenshot.flip_y()
	var error = screenshot.save_png(renderPath + str(renderFrameCounter) + '.png')
	renderFrameCounter += 1
	var answer : Dictionary = {'render_error': str(error)}
	$WebSocketClient.send_to_server(JSON.stringify(answer))
        RSRC                    PackedScene            ��������                                                  resource_local_to_scene    resource_name 	   _bundled    script       Script    res://GymGodot.gd ��������   Script    res://WebSocketClient.gd ��������      local://PackedScene_wfcre 9         PackedScene          	         names "      	   GodotGym    script    Node    WebSocketClient    	   variants                                node_count             nodes        ��������       ����                            ����                   conn_count              conns               node_paths              editable_instances              version             RSRC               GST2   �   �      ����               � �        �  RIFF�  WEBPVP8L�  /������!"2�H�$�n윦���z�x����դ�<����q����F��Z��?&,
ScI_L �;����In#Y��0�p~��Z��m[��N����R,��#"� )���d��mG�������ڶ�$�ʹ���۶�=���mϬm۶mc�9��z��T��7�m+�}�����v��ح�m�m������$$P�����එ#���=�]��SnA�VhE��*JG�
&����^x��&�+���2ε�L2�@��		��S�2A�/E���d"?���Dh�+Z�@:�Gk�FbWd�\�C�Ӷg�g�k��Vo��<c{��4�;M�,5��ٜ2�Ζ�yO�S����qZ0��s���r?I��ѷE{�4�Ζ�i� xK�U��F�Z�y�SL�)���旵�V[�-�1Z�-�1���z�Q�>�tH�0��:[RGň6�=KVv�X�6�L;�N\���J���/0u���_��U��]���ǫ)�9��������!�&�?W�VfY�2���༏��2kSi����1!��z+�F�j=�R�O�{�
ۇ�P-�������\����y;�[ ���lm�F2K�ޱ|��S��d)é�r�BTZ)e�� ��֩A�2�����X�X'�e1߬���p��-�-f�E�ˊU	^�����T�ZT�m�*a|	׫�:V���G�r+�/�T��@U�N׼�h�+	*�*sN1e�,e���nbJL<����"g=O��AL�WO!��߈Q���,ɉ'���lzJ���Q����t��9�F���A��g�B-����G�f|��x��5�'+��O��y��������F��2�����R�q�):VtI���/ʎ�UfěĲr'�g�g����5�t�ۛ�F���S�j1p�)�JD̻�ZR���Pq�r/jt�/sO�C�u����i�y�K�(Q��7őA�2���R�ͥ+lgzJ~��,eA��.���k�eQ�,l'Ɨ�2�,eaS��S�ԟe)��x��ood�d)����h��ZZ��`z�պ��;�Cr�rpi&��՜�Pf��+���:w��b�DUeZ��ڡ��iA>IN>���܋�b�O<�A���)�R�4��8+��k�Jpey��.���7ryc�!��M�a���v_��/�����'��t5`=��~	`�����p\�u����*>:|ٻ@�G�����wƝ�����K5�NZal������LH�]I'�^���+@q(�q2q+�g�}�o�����S߈:�R�݉C������?�1�.��
�ڈL�Fb%ħA ����Q���2�͍J]_�� A��Fb�����ݏ�4o��'2��F�  ڹ���W�L |����YK5�-�E�n�K�|�ɭvD=��p!V3gS��`�p|r�l	F�4�1{�V'&����|pj� ߫'ş�pdT�7`&�
�1g�����@D�˅ �x?)~83+	p �3W�w��j"�� '�J��CM�+ �Ĝ��"���4� ����nΟ	�0C���q'�&5.��z@�S1l5Z��]�~L�L"�"�VS��8w.����H�B|���K(�}
r%Vk$f�����8�ڹ���R�dϝx/@�_�k'�8���E���r��D���K�z3�^���Vw��ZEl%~�Vc���R� �Xk[�3��B��Ğ�Y��A`_��fa��D{������ @ ��dg�������Mƚ�R�`���s����>x=�����	`��s���H���/ū�R�U�g�r���/����n�;�SSup`�S��6��u���⟦;Z�AN3�|�oh�9f�Pg�����^��g�t����x��)Oq�Q�My55jF����t9����,�z�Z�����2��#�)���"�u���}'�*�>�����ǯ[����82һ�n���0�<v�ݑa}.+n��'����W:4TY�����P�ר���Cȫۿ�Ϗ��?����Ӣ�K�|y�@suyo�<�����{��x}~�����~�AN]�q�9ޝ�GG�����[�L}~�`�f%4�R!1�no���������v!�G����Qw��m���"F!9�vٿü�|j�����*��{Ew[Á��������u.+�<���awͮ�ӓ�Q �:�Vd�5*��p�ioaE��,�LjP��	a�/�˰!{g:���3`=`]�2��y`�"��N�N�p���� ��3�Z��䏔��9"�ʞ l�zP�G�ߙj��V�>���n�/��׷�G��[���\��T��Ͷh���ag?1��O��6{s{����!�1�Y�����91Qry��=����y=�ٮh;�����[�tDV5�chȃ��v�G ��T/'XX���~Q�7��+[�e��Ti@j��)��9��J�hJV�#�jk�A�1�^6���=<ԧg�B�*o�߯.��/�>W[M���I�o?V���s��|yu�xt��]�].��Yyx�w���`��C���pH��tu�w�J��#Ef�Y݆v�f5�e��8��=�٢�e��W��M9J�u�}]釧7k���:�o�����Ç����ս�r3W���7k���e�������ϛk��Ϳ�_��lu�۹�g�w��~�ߗ�/��ݩ�-�->�I�͒���A�	���ߥζ,�}�3�UbY?�Ӓ�7q�Db����>~8�]
� ^n׹�[�o���Z-�ǫ�N;U���E4=eȢ�vk��Z�Y�j���k�j1�/eȢK��J�9|�,UX65]W����lQ-�"`�C�.~8ek�{Xy���d��<��Gf�ō�E�Ӗ�T� �g��Y�*��.͊e��"�]�d������h��ڠ����c�qV�ǷN��6�z���kD�6�L;�N\���Y�����
�O�ʨ1*]a�SN�=	fH�JN�9%'�S<C:��:`�s��~��jKEU�#i����$�K�TQD���G0H�=�� �d�-Q�H�4�5��L�r?����}��B+��,Q�yO�H�jD�4d�����0*�]�	~�ӎ�.�"����%
��d$"5zxA:�U��H���H%jس{���kW��)�	8J��v�}�rK�F�@�t)FXu����G'.X�8�KH;���[             [remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://bltykl08bqgdj"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
                extends RigidBody2D

var torque = 2_000_000
var drive_torque = 2000

var rotation_direction = 0
var drive_direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _integrate_forces(state):
	if Input.is_action_pressed("swerve_left"):
		rotation_direction = -1.0
	if Input.is_action_pressed("swerve_right"):
		rotation_direction = 1.0
		
	apply_torque(rotation_direction * torque)
	
	if Input.is_action_pressed("drive_up"):
		drive_direction.y = -1
	if Input.is_action_pressed("drive_down"):
		drive_direction.y = 1
	if Input.is_action_pressed("drive_left"):
		drive_direction.x = -1
	if Input.is_action_pressed("drive_right"):
		drive_direction.x = 1
		
	if drive_direction.length() > 0:
		drive_direction = drive_direction.normalized()
		#apply_central_force(drive_direction * drive_torque)
		apply_central_impulse(drive_direction * drive_torque)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
            RSRC                    PackedScene            ��������                                            
      resource_local_to_scene    resource_name 	   friction    rough    bounce 
   absorbent    script    custom_solver_bias    size 	   _bundled       Script    res://robot.gd ��������      local://PhysicsMaterial_h8e0n �         local://RectangleShape2D_pwga1 �         local://PackedScene_ujk2h ,         PhysicsMaterial          ��L?                  ?                  RectangleShape2D       
     �B  �B         PackedScene    	      	         names "   
      Robot 	   position    mass    physics_material_override    linear_damp    angular_damp    script    RigidBody2D    CollisionShape2D    shape    	   variants       
     C  C      B               �@     �@                         node_count             nodes        ��������       ����                                                          ����   	                conn_count              conns               node_paths              editable_instances              version             RSRCextends Node

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
          [remap]

path="res://.godot/exported/133200997/export-08d1e3c2b6ce474532775eb2c79c840a-environment.scn"
        [remap]

path="res://.godot/exported/133200997/export-3edaff0b57156128f734968cd24902c3-GymGodot.scn"
           [remap]

path="res://.godot/exported/133200997/export-a8a6c2d17c22928b6c4c68c746089ba7-robot.scn"
              list=Array[Dictionary]([])
     <svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><rect x="2" y="2" width="124" height="124" rx="14" fill="#363d52" stroke="#212532" stroke-width="4"/><g transform="scale(.101) translate(122 122)"><g fill="#fff"><path d="M105 673v33q407 354 814 0v-33z"/><path fill="#478cbf" d="m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 813 0v-39l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H447l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z"/><path d="M483 600c3 34 55 34 58 0v-86c-3-34-55-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g><g fill="#414042"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></g></svg>
             L��   res://environment.tscn,]�y�2   res://GymGodot.tscn���ݏ�e,   res://icon.svg'e�teHnX   res://robot.tscn     ECFG      application/config/name         Crescendo_OpenGym_2    application/run/main_scene          res://environment.tscn     application/config/features(   "         4.2    GL Compatibility       application/config/icon         res://icon.svg  "   display/window/size/viewport_width         #   display/window/size/viewport_height            input/swerve_left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script         input/swerve_right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script         input/drive_up�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script         input/drive_down�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script         input/drive_left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script         input/drive_right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script         physics/2d/default_gravity          #   rendering/renderer/rendering_method         gl_compatibility*   rendering/renderer/rendering_method.mobile         gl_compatibility   