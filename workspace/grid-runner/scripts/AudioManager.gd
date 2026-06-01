extends Node

# Procedural audio for Grid-Runner (move blip, goal chime, death noise).
# Browsers block audio until a user gesture, so resume_audio() runs on the first input.

var audio_player: AudioStreamPlayer
var generator: AudioStreamGeneratorPlayback
var sample_rate: float = 22050.0

func _ready():
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

func play_move():
	resume_audio()
	_generate_tone(330.0, 0.04, 0.12)

func play_goal():
	resume_audio()
	_generate_tone(660.0, 0.07, 0.2)
	_generate_tone(990.0, 0.09, 0.18)

func play_death():
	resume_audio()
	if not generator:
		return
	var frames = min(int(0.4 * sample_rate), generator.get_frames_available())
	for i in range(frames):
		var env = float(frames - i) / float(frames)
		generator.push_frame(Vector2(randf_range(-0.5, 0.5) * env, randf_range(-0.5, 0.5) * env))

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
