extends TextEdit

###
# This script is just used to allow you to press tab in the desctiption Box
# and have it tab to the next field instead of putting a tab in the description
###
func set_focus_next(value):
    get_node(value).focus_previous = get_path()
    .set_focus_next(value)

func _input(event):
    if event.is_action_pressed("ui_focus_prev") and has_focus():
        if focus_previous != "":
            get_node(focus_previous).grab_focus()
        get_tree().set_input_as_handled()
    elif event.is_action_pressed("ui_focus_next") and has_focus():
        if focus_next != "":
            get_node(focus_next).grab_focus()
        get_tree().set_input_as_handled()
