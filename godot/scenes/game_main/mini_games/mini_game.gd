class_name MiniGame
extends Node2D

signal puzzle_solved()
signal on_started()
signal on_won()

@export var check_win_condition: Callable
@export var win_calldown_sec: float = 0.9

var _started = false
var _win = false
var _win_timer := Timer.new()

@onready var title := %Title
@onready var mini_game := %MiniGame

func is_started():
	return _started

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	mini_game.visible = false
	add_child(_win_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not _started:
		if Input.is_action_just_released("primary_action"):
			_started = true
			_win = false
			title.visible = false
			mini_game.visible = true
			on_started.emit()
			return
	else:
		assert(check_win_condition, "Set check_win_condition in your _ready(), required for checking win condition")
		_check_win(check_win_condition)

func _check_win(pred: Callable) -> bool:
	if not pred or not pred.is_valid():
		push_error("Invalid Callable for win condition.")
		return false

	# not won and win (cooldown) timer not started, yet .. check for win
	if not _win and _win_timer.is_stopped() and pred.call():
		_win_timer.timeout.connect(func(): puzzle_solved.emit())
		_win_timer.start(win_calldown_sec)
		print_debug("WIN")
		_win = true
		on_won.emit()
		return true
	return false

func has_won():
	return _started and not _win_timer.is_stopped() and _win