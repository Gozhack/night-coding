extends Node

# AudioManager - Procedural Sound Generation
# Generates beeps, death sounds, and ambient loops via code

var audio_player: AudioStreamPlayer
var generator: AudioStreamGeneratorPlayback
var sample_rate: float = 22050.0 # Lowered for web performance

func _ready():
	audio_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.1
	audio_player.stream = stream
	add_child(audio_player)
	# Do NOT play here, browsers block it until a click (VT-04)

# Force audio to start/resume (must be called from a user gesture like a button click)
func resume_audio():
	if not audio_player.playing:
		audio_player.play()

	if not generator:
		generator = audio_player.get_stream_playback()
		if generator:
			# Pre-fill buffer with silence
			for i in range(generator.get_frames_available()):
				generator.push_frame(Vector2.ZERO)

# Simple beep sound
func play_beep(freq: float = 440.0, duration: float = 0.1):
	resume_audio()
	_generate_tone(freq, duration, 0.2)

# Tone for level up - slightly more complex
func play_level_up(level: int):
	resume_audio()
	# Ascending tones based on level
	var base_freq = 440.0 + (level * 50.0)
	_generate_tone(base_freq, 0.1, 0.3)
	_generate_tone(base_freq * 1.5, 0.15, 0.2)

func _generate_tone(freq: float, duration: float, volume: float):
	if not generator: 
		generator = audio_player.get_stream_playback()
		if not generator: return

	var phase = 0.0
	var increment = freq / sample_rate
	var frames = int(duration * sample_rate)
...
# Low frequency noise for death
func play_death():
	resume_audio()
	if not generator: return
	var frames = int(0.6 * sample_rate)

	for i in range(frames):
		var sample = sin(phase * 2.0 * PI) * volume
		# Basic envelope to prevent clicking
		if i < 200: sample *= i / 200.0
		if i > frames - 200: sample *= (frames - i) / 200.0
		
		generator.push_frame(Vector2(sample, sample))
		phase = fmod(phase + increment, 1.0)

# Low frequency noise for death
func play_death():
	if not generator: return
	var frames = int(0.6 * sample_rate)
	
	# Ensure we don't overflow buffer
	var available = generator.get_frames_available()
	frames = min(frames, available)
	
	for i in range(frames):
		var sample = randf_range(-0.5, 0.5) * (float(frames - i) / frames)
		generator.push_frame(Vector2(sample, sample))

# Minimalist ambient pulse (call this repeatedly or use a separate player)
func play_ambient_pulse(freq: float = 55.0):
	# This is a bit complex for a single generator without mixing logic
	# For the MVP, we'll focus on the beeps and death sound.
	pass
