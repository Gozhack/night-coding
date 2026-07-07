extends Node

var audio_player: AudioStreamPlayer
var generator: AudioStreamGeneratorPlayback
var sample_rate: float = 22050.0

var thrust_active: bool = false
var thrust_intensity: float = 0.0
var thrust_phase: float = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	audio_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.2
	audio_player.stream = stream
	add_child(audio_player)

func resume_audio():
	if audio_player and not audio_player.playing:
		audio_player.play()
		generator = audio_player.get_stream_playback()

func _process(_delta):
	if not generator:
		return
	
	if thrust_active:
		_generate_thrust_sound()

func set_thrust(active: bool, intensity: float):
	if active or intensity > 0.0:
		resume_audio()
	thrust_active = active
	thrust_intensity = intensity

func _generate_thrust_sound():
	var frames_available = generator.get_frames_available()
	if frames_available == 0:
		return
		
	# Fill buffer in small chunks
	var frames = min(int(0.05 * sample_rate), frames_available)
	var freq = 60.0 + (thrust_intensity * 40.0) # Rumble frequency rises slightly
	var increment = freq / sample_rate
	
	for i in range(frames):
		# Mix a low frequency sine wave with some noise for rumble
		var sine_val = sin(thrust_phase * TAU)
		var noise_val = randf_range(-1.0, 1.0)
		var volume = lerp(0.0, 0.4, thrust_intensity)
		var sample = (sine_val * 0.4 + noise_val * 0.6) * volume
		
		generator.push_frame(Vector2(sample, sample))
		thrust_phase = fmod(thrust_phase + increment, 1.0)

func play_success():
	resume_audio()
	if not generator:
		return
	# High tone + descent (like a bell or fanfare)
	_generate_tone(880.0, 0.1, 0.3)
	_generate_tone(1108.0, 0.1, 0.3) # C#6
	_generate_tone_slide(1318.0, 880.0, 0.4, 0.3) # E6 sliding down to A5

func play_crash():
	resume_audio()
	if not generator:
		return
	# Dissonant buzz/impact
	var frames = min(int(0.5 * sample_rate), generator.get_frames_available())
	var phase1 = 0.0
	var phase2 = 0.0
	var inc1 = 150.0 / sample_rate
	var inc2 = 165.0 / sample_rate # dissonant
	
	for i in range(frames):
		var env = float(frames - i) / float(frames)
		var sample = (sin(phase1 * TAU) + sin(phase2 * TAU)) * 0.5
		sample += randf_range(-1.0, 1.0) * 0.5 # Add noise
		sample *= env * 0.5
		generator.push_frame(Vector2(sample, sample))
		phase1 = fmod(phase1 + inc1, 1.0)
		phase2 = fmod(phase2 + inc2, 1.0)

func _generate_tone(freq: float, duration: float, volume: float):
	if not generator:
		return
	var frames = min(int(duration * sample_rate), generator.get_frames_available())
	var phase = 0.0
	var increment = freq / sample_rate
	for i in range(frames):
		var sample = sin(phase * TAU) * volume
		if i < 200:
			sample *= i / 200.0
		if i > frames - 200:
			sample *= float(frames - i) / 200.0
		generator.push_frame(Vector2(sample, sample))
		phase = fmod(phase + increment, 1.0)

func _generate_tone_slide(start_freq: float, end_freq: float, duration: float, volume: float):
	if not generator:
		return
	var frames = min(int(duration * sample_rate), generator.get_frames_available())
	var phase = 0.0
	for i in range(frames):
		var t = float(i) / float(frames)
		var current_freq = lerp(start_freq, end_freq, t)
		var increment = current_freq / sample_rate
		var sample = sin(phase * TAU) * volume
		if i < 200:
			sample *= i / 200.0
		if i > frames - 200:
			sample *= float(frames - i) / 200.0
		generator.push_frame(Vector2(sample, sample))
		phase = fmod(phase + increment, 1.0)
