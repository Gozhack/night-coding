extends Node

# AudioManager - Procedural Sound Generation
# Generates beeps, level-up tones and a death noise via an AudioStreamGenerator.
# Browsers block audio until a user gesture, so resume_audio() must be called on the
# first button press (see Main._on_play_pressed -> AudioManager.resume_audio()).

var audio_player: AudioStreamPlayer
var generator: AudioStreamGeneratorPlayback
var sample_rate: float = 22050.0  # lowered for web performance

func _ready():
	audio_player = AudioStreamPlayer.new()
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.2
	audio_player.stream = stream
	add_child(audio_player)
	# Do NOT play here — browsers block audio until a user gesture (VT-04).

# Start/resume playback. MUST be called from a user gesture (e.g. a button press).
func resume_audio():
	if audio_player and not audio_player.playing:
		audio_player.play()
		generator = audio_player.get_stream_playback()

# Short beep (survival tick).
func play_beep(freq: float = 440.0, duration: float = 0.08):
	resume_audio()
	_generate_tone(freq, duration, 0.2)

# Ascending two-note chime for level up.
func play_level_up(level: int):
	resume_audio()
	var base_freq = 440.0 + (level * 50.0)
	_generate_tone(base_freq, 0.1, 0.3)
	_generate_tone(base_freq * 1.5, 0.12, 0.2)

# Descending noise burst on death.
func play_death():
	resume_audio()
	if not generator:
		return
	var frames = min(int(0.4 * sample_rate), generator.get_frames_available())
	for i in range(frames):
		var env = float(frames - i) / float(frames)  # fade out
		var sample = randf_range(-0.5, 0.5) * env
		generator.push_frame(Vector2(sample, sample))

# Push a sine tone into the generator buffer (clamped to available space).
func _generate_tone(freq: float, duration: float, volume: float):
	if not generator:
		return
	var frames = min(int(duration * sample_rate), generator.get_frames_available())
	var phase = 0.0
	var increment = freq / sample_rate
	for i in range(frames):
		var sample = sin(phase * TAU) * volume
		# Short attack/release envelope to avoid clicking.
		if i < 200:
			sample *= i / 200.0
		if i > frames - 200:
			sample *= float(frames - i) / 200.0
		generator.push_frame(Vector2(sample, sample))
		phase = fmod(phase + increment, 1.0)
