class_name Player
extends Resource

const colors: Array = [
	Color(1, 0, 0),     # Red
	Color(0, 1, 0),     # Green
	Color(0, 0, 1),     # Blue
	Color(1, 1, 0),     # Yellow
	Color(1, 0, 1),     # Magenta
	Color(0, 1, 1)      # Cyan
]

const titles = [
	"The", "Mr.", "Super", "Dr.", "Captain", "Professor", "Madame", "Sir", "Lady", "Lord", "Count", "Princess", "King", "Queen", "Commander"
]

const terms = [
	"Intercourse", "Funny", "Gamer", "Loser", "Awesome", "Sneaky", "Fluffy", "Daring", "Epic", "Ninja", "Cheesy", "Joker", "Cool", "Zombie", "Silly"
]

var ready = false

var targetInput: int
var titleIndex = 0
var termIndex = 0
var _colorIndex: int = -1  # Internal backing variable for colorIndex


var name: String:
	get:
		return "%s %s" % [titles[titleIndex % titles.size()], terms[termIndex % terms.size()]]

# Static set to keep track of assigned color indexes
static var assigned_color_indices := {}
var colorIndex: int:
	get:
		return _colorIndex
	set(value):
		value = value % colors.size()
		
		# Remove old index from assigned set if set
		if _colorIndex != -1:
			assigned_color_indices.erase(_colorIndex)
		
		var direction = 1 if value > _colorIndex else -1
		# Special case if _colorIndex == -1 (initial), just assign requested color
		if _colorIndex == -1:
			direction = 1
		
		var start_value = value
		while assigned_color_indices.has(value):
			# Move in requested direction and wrap around
			value = (value + direction) % colors.size()
			if value < 0:
				value = colors.size() - 1
			if value == start_value:
				push_error("No available colors left!")
				# Re-add old color if we erased it before
				if _colorIndex != -1:
					assigned_color_indices[_colorIndex] = true
				return # no change
		
		_colorIndex = value
		assigned_color_indices[_colorIndex] = true

var color: Color:
	get:
		if _colorIndex == -1:
			return Color(1, 1, 1) # default white if no color assigned
		return colors[_colorIndex]

func _init(_targetInput):
	targetInput = _targetInput
	titleIndex = randi() % 10000 
	termIndex = randi() % 10000
	colorIndex = randi() % 10000
	

func _to_string():
	return "Player ( name:\"%s\" input:%s color:%s)" % [ name, targetInput, colorIndex]
