extends Node

var fps_samples: Array = []
var update_interval := 2.0  # seconds

var average_fps: float = 0.0
var one_percent_low_fps: float = 0.0

var _time_accumulator := 0.0

func _process(delta):
	var current_fps := Engine.get_frames_per_second()
	fps_samples.append(current_fps)

	_time_accumulator += delta
	if _time_accumulator >= update_interval:
		_compute_metrics()
		_time_accumulator = 0.0
		fps_samples.clear()


func _compute_metrics():
	if fps_samples.size() == 0:
		return

	# Average FPS
	var sum := 0.0
	for fps in fps_samples:
		sum += fps
	average_fps = sum / fps_samples.size()

	# 1% low: sort and get the 1% lowest average
	var sorted_samples := fps_samples.duplicate()
	sorted_samples.sort()

	var count_1_percent = max(1, int(sorted_samples.size() * 0.01))
	var low_samples := sorted_samples.slice(0, count_1_percent)
	var low_sum := 0.0
	for fps in low_samples:
		low_sum += fps
	one_percent_low_fps = low_sum / low_samples.size()

	# Optional debug output
	#print("Average FPS: %.2f, 1%% Low: %.2f" % [average_fps, one_percent_low_fps])
