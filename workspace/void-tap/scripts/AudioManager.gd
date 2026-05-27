extends Node

# AudioManager - Procedural Sound Generation
# Generates beeps, death sounds, and ambient loops via code

var audio_player: AudioStreamPlayer
var generator: AudioStreamGeneratorPlayback
var sample_rate: float = 44100.0

func _ready():
	audio_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.1
	audio_player.stream = stream
	add_child(audio_player)
	audio_player.play()
	generator = audio_player.get_stream_playback()

# Simple beep sound
func play_beep(freq: float = 440.0, duration: float = 0.1):
	var phase = 0.0
	var increment = freq / sample_rate
	var frames = int(duration * sample_rate)
	
	for i in range(frames):
		var sample = sin(phase * 2.0 * PI)
		# Basic envelope to prevent clicking
		if i < 100: sample *= i / 100.0
		if i > frames - 100: sample *= (frames - i) / 100.0
		
		generator.push_frame(Vector2(sample, sample))
		phase = fmod(phase + increment, 1.0)

# Low frequency noise for death
func play_death():
	var frames = int(0.5 * sample_rate)
	for i in range(frames):
		var sample = randf_range(-1.0, 1.0) * (float(frames - i) / frames)
		generator.push_frame(Vector2(sample, sample))

# Minimalist ambient pulse (call this repeatedly or use a separate player)
func play_ambient_pulse(freq: float = 55.0):
	# This is a bit complex for a single generator without mixing logic
	# For the MVP, we'll focus on the beeps and death sound.
	pass
