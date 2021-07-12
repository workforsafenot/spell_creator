extends Control

# Filename of where to save the spells
const FILE_NAME = 'spells.json'

# Initialize our spell dictionary
var all_spells = {}

# Initialize our spell index
var cur_spell_index = 0

# Initialize our selected spell
var selected_node = null

# Initialize default spell icon path
var spell_icon_path = "spell_icons/default.png"


# Iniitalize the variables for the values we want to store in our spell file
# You will need to add a new variable here if you add fields to the 
# right side page.

# For the pop up window that lets you select the spell Icon
onready var icon_sel = $IconSelector

# For the spell table on the left page
onready var spell_tree = $main_window/spell_list/current_spells

# For the image icon on the right page
onready var spell_icon_img = $main_window/new_spell/spell_icon/ReferenceRect/spell_icon_image

# For the spell name input field
onready var spell_name = $main_window/new_spell/spell_name/spell_name_inp

# For the spell description input field
onready var spell_desc = $main_window/new_spell/spell_description/spell_desc_inp

# For the spell damage input field
onready var spell_damage = $main_window/new_spell/spell_damage/spell_damage_inp

# For the spell range input field
onready var spell_range = $main_window/new_spell/spell_range/spell_range_inp

# For the spell affliction change input field
onready var spell_afflic_chance = $main_window/new_spell/spell_afflic_chance/spell_afflic_chance_inp

# For the spell mana cost input field
onready var spell_mana_cost = $main_window/new_spell/spell_mana_cost/spell_mana_cost_inp

# For the spell quantity input field
onready var spell_quantity = $main_window/new_spell/spell_quantity/spell_quantity_inp

# For the spell boost input field
onready var spell_boost = $main_window/new_spell/spell_boost/spell_boost_inp

# For the spell link buff toggle
onready var spell_link_buff = $main_window/new_spell/spell_link_buff/spell_link_buff_inp

# For the spell tick input field
onready var spell_tick = $main_window/new_spell/spell_tick/spell_tick_inp



# For the spell ID label
onready var spell_id = $main_window/new_spell/spell_id_label



# This one is unique, it holds all of the spell types in it. 
# Since there are so many types we just loop through them all to see which
# types we have selected.  This variable is for the root node of all the 
# spell types
onready var spell_type_sel = $main_window/new_spell/spell_type/HBoxContainer



func _ready():
    # Makes the background trasparent
    get_tree().get_root().set_transparent_background(true)

    # Sets the file picker to the current directory the files is running from
    var cur_dir = OS.get_executable_path()
    icon_sel.set_current_dir(cur_dir)
    icon_sel.set_current_path(cur_dir)

    # This is used to call the on tree item selected function 
    # when you click a spell on the spells page
    spell_tree.connect("item_activated", self, "_on_tree_item_selected")
    
    # Styling for the spell table
    # dont auto expand the first column
    spell_tree.set_column_expand(0, false)
    # Set the first column width to 85 pixels
    spell_tree.set_column_min_width(0, 85)
    
    # Load the spells from our spells.json file
    all_spells = loadDictionary(FILE_NAME)
    
    # Update the spell list
    update_tree_node()
    
    # Get the total number of spells to make our next spell
    # (if there are 10 spells this would be 11 for the next one)
    cur_spell_index = len(all_spells)
    
    # update the text that says what spell we are on
    # Spell ID: #
    update_spell_id(cur_spell_index)
    
    # Set our focus to the spell name field by default
    spell_name.grab_focus()


func update_spell_id(num):
    # Sets the spell id text at the top of the right page
    # to say what spell number we have selected
    # (Defaults to a new spell id)
    var new_spell_id = "Spell ID: %s" % num
    spell_id.set_text(new_spell_id)

func customComparison(a, b):
    # Used for a sort function, just checking for the smallest number
    # Ex. a = 5 and b = 10 
    # int(5) < int(10) would return true
    return int(a) < int(b)


func update_tree_node():
    # This function is used to redraw the spell table on the left page
    #
    # Checks if our spell dictionary has anything in it
    # if the size of the dictionary is 0 it will skip all of this
    if all_spells.size() > 0:
        # Clear the Spell Table (on the left page)
        spell_tree.clear()
        
        # Create a new entry for the Spell Table
        var spell_tree_root = spell_tree.create_item()
        # It will be the root (first element) and all the spells
        # Will go under it, so we will just give it a blank name
        spell_tree_root.set_text(0, "")
        # Make it not selectable
        spell_tree_root.set_selectable(0, false)
        # Make it so it isnt colapsable
        spell_tree_root.set_disable_folding(true)
        
        # Create an enpty array to store our spells in
        var sorted_spells = []
        # loop through all of the spells and push the spell ID to 
        # the sorted_spells array
        for c_spell in all_spells:
            sorted_spells.append(c_spell)
        
        # Sort our spell ids from smallest to largest (customComparison function)
        sorted_spells.sort_custom(self, "customComparison")
        
        # Loop through all of the IDs in sorted_spells
        for c_spell in sorted_spells:
            # Create a new entry on the spell table under the root node
            var n_spell = spell_tree.create_item(spell_tree_root)
            
            # Set the spell ID on the current entry with 4 padded 0s
            # Ex: 1 would be 0001
            n_spell.set_text(0, "%04d" % int(c_spell))
            
            # Set the spell name on the same row in column 2
            n_spell.set_text(1, all_spells[str(c_spell)]['spell_name'])
            # Set the metadata to the spell ID
            n_spell.set_metadata(0, str(c_spell))
            # check if the spell we are adding is the one we had selected
            if c_spell == selected_node:
                # If its the one we had selected then scroll the spell
                # list to the one we had selected
                spell_tree.scroll_to_item(n_spell)
                # select (highlight) the spell we had selected
                n_spell.select(0)
                # Update the Spell ID text (on top of the right page)
                update_spell_id(str(c_spell))
    

func add_spell(c_cur_spell_index):
    # This function is used to add a new spell
    
    # start off creating an empty dictionary to hold our spell types
    var spell_types = {}
    
    # This variable starts blank but will be updated with the type
    # base type the checkbox falls under
    # Ex: Fundamental Magic
    var t_spell_type_sel = ""
    
    # Loop through all of the nodes under our spell_type_sel node
    for types in spell_type_sel.get_children():
        # each container is using the base type as its name
        # so set t_spell_type_sel to the current nodes name
        # Ex. Fundamental
        t_spell_type_sel = types.name
        
        # loop through all the checkboxes in the current node we are on
        for chk in types.get_children():
            # check if the checkbox is checked
            if chk.is_pressed():
                # if it is checked, check our spell_types dictionary to see
                # if the base type is already in there, if its not we add it
                # Ex. check if Fundamental is in spell_types
                if spell_types.has(t_spell_type_sel) == false:
                    spell_types[t_spell_type_sel] = []
                
                # add the magic that is cheked to the dictionary
                # under the base type
                # Ex: spell_types["Fundamental"].append("Fire")
                spell_types[t_spell_type_sel].append(chk.text)
    
    # create our spell to be stored in the JSON file
    # we will get the text or values of each input field defined above
    var spell = {
            'spell_name': spell_name.text,
            'spell_desc': spell_desc.text,
            'spell_icon_path': spell_icon_path,
            'spell_types': spell_types,
            'spell_damage': spell_damage.value,
            'spell_range': spell_range.value,
            'spell_affliction_chance': spell_afflic_chance.value,
            'spell_mana_cost': spell_mana_cost.value,
            'spell_link_buff': spell_link_buff.is_pressed(),
            'spell_quantity': spell_quantity.value,
            'spell_boost': spell_boost.value,
            'spell_tick': spell_tick.value,
    }
    
    # Add a new entry to our all_spells dictionary with the new spell
    all_spells[str(c_cur_spell_index)] = spell
    
    # update our spell ID index to make sure our next spell will be a new id
    cur_spell_index = len(all_spells)
    
    # update the Spell ID text at the top of th left page
    update_spell_id(cur_spell_index)
    
    # Save our spells to the JSON file
    save_all_spells()

func save_all_spells():
    # Call the save function to save all of our spells to the JSON file
    save(FILE_NAME, all_spells)
    
    # Refresh the spell table (left page) with the new spell
    update_tree_node()

func load_spell(spell):
    # This function is used to load a spell onto the right page
    # by passing in the spell we want to edit/see
    
    # These are all using the all_spells dictionary 
    # set the spell name to the current spell we passed in 
    spell_name.set_text(spell['spell_name'])

    # set the spell description to the current spell we passed in 
    spell_desc.set_text(spell['spell_desc'])
    
    # set the spell icon to the current spell we passed in 
    set_texture(spell['spell_icon_path'])
    
    # set the spell damage to the current spell we passed in 
    spell_damage.set_value(float(spell['spell_damage']))
    
    # set the spell range to the current spell we passed in 
    spell_range.set_value(float(spell['spell_range']))
    
    # set the spell affliction chance to the current spell we passed in 
    spell_afflic_chance.set_value(float(spell['spell_affliction_chance']))

    # set the spell mana cost to the current spell we passed in 
    spell_mana_cost.set_value(float(spell['spell_mana_cost']))

    # set the spell link buff to the current spell we passed in 
    spell_link_buff.set_pressed(spell['spell_link_buff'])

    # set the spell quantity to the current spell we passed in 
    spell_quantity.set_value(float(spell['spell_quantity']))

    # set the spell boost to the current spell we passed in 
    spell_boost.set_value(float(spell['spell_boost']))

    # set the spell tick to the current spell we passed in 
    spell_tick.set_value(float(spell['spell_tick']))


    # update the spell_icon_path variable to the current spells icon
    spell_icon_path = spell['spell_icon_path']
    
    # Get all of the spell types of the current spell
    var spell_types = spell['spell_types']
    
    # initialize an array to store all the spell types
    var spells_to_flag = []

    # loop through the base spell types
    # Ex. Fundamental
    for spell_t in spell_types:
        # loop through the spell types
        # Ex. Fire
        for spell_n in spell_types[spell_t]:
            # Add the spell type to our spells_to_flag array
            spells_to_flag.append(spell_n)
    
    # loop through our base spell types node
    # Ex. Fundamental
    for types in spell_type_sel.get_children():
        # loop through each spell type on the current base spell type
        # Ex. Fire
        for chk in types.get_children():
            # Check if the node is in our spells_to_flag array
            if chk.text in spells_to_flag:
                # If it is set the checkbox as checked
                chk.set_pressed(true)
            else:
                # If it isnt, clear the checkbox
                # we need this so that any checkboxes we had selected
                # before loading will be cleared
                chk.set_pressed(false)



func save(var path : String, var thing_to_save):
    # Function to save data to json file
    # !!THIS OVERWRITES THE FILE EACH TIME!!
    # That is why we store all of the spells in all_spells and 
    # then pass it back into this function when we save

    # Create a new File
    var file = File.new()
    
    # Open up the file by the filename we passed in
    file.open(path, File.WRITE)
    
    # convert the contents of the variable we passed in to the file
    # to JSON and then write to the file
    file.store_line(to_json(thing_to_save))
    
    # close the file
    file.close()


func loadDictionary (var path : String) -> Dictionary:
    # This function loads from the JSON file and converts the contents 
    # to a dictionary variable
    
    # initialize an emty dictionary
    var dict = {}
    
    # create a file variable
    var file = File.new()
    
    # open up the file by the filename we passed in
    file.open(path, file.READ)
    
    # get the contents of the file as text and store them
    var text = file.get_as_text()
    
    # close the file
    file.close()
    
    # parse the text as JSON and store it
    var result_json = JSON.parse(text)
    
    # If the result_json is valid JSON
    if result_json.error == OK:
        # Store the JSON as a dictionary
        # Godot automatically converts it for us
        dict = result_json.result
    else:
        # If there are errors print them out.
        # This will error when the spells.json file is blank
        print("Error: ", result_json.error)
        print("Error Line: ", result_json.error_line)
        print("Error String: ", result_json.error_string)
    
    # return the dictionary we created
    return dict

func set_texture(txtur):
    # This function is used to set the spell icon on the right page
    
    # create a new image
    var image = Image.new()
    
    # try to load our image and store it
    var err = image.load(txtur)
    
    # check if the image was loaded successfully
    if err != OK:
        # If it wasnt then ignore it, the icon will be blank
        pass
    
    # Create a new Image texture
    var texture = ImageTexture.new()
    
    # set the texture to our image that was just loaded
    texture.create_from_image(image, 0)
    
    # set the icon to the texture we just created
    spell_icon_img.set_normal_texture(texture)

   
func _on_spell_icon_image_pressed():
    # This function is triggered when the icon is pressed
    
    # pop up the file selector
    icon_sel.popup_centered()

func _on_IconSelector_file_selected(path):
    # This function is triggered when a file is selected
    
    # set the spell icon path to the path from the file selector
    spell_icon_path = path
    
    # update the spell icon texture
    set_texture(path)

func _on_tree_item_selected():
    # This function is called when we select a spell from the table
    # on the page on the left
    
    # Get the selected spells metadata
    if spell_tree.get_selected().get_metadata(0) == null:
        # if the metadata is null or doesnt exist then return nothing
        return
    
    # Set our selected_node variable to the spell we selected on the spell table
    selected_node = str(spell_tree.get_selected().get_metadata(0))
    
    # Update the spell ID text on the right page
    update_spell_id(str(selected_node))
    
    # Load the spell we selected by looking up the spell
    # in our all_spells dictionary
    load_spell(all_spells[selected_node])

func _on_add_spell_pressed():
    # This function is triggered when the "Add Spells" button is pressed
    add_spell(cur_spell_index)

func _on_save_spell_pressed():
    # This function is triggered when the "Save Spells" button is pressed
    if selected_node != null:
        add_spell(selected_node)
        save_all_spells()


func _on_remove_spell_pressed():
    # This function is triggered when the "Remove Spells" button is pressed
    if selected_node != null:
        all_spells.erase(selected_node)
        save_all_spells()


func _on_quit_button_down():
    # This function is triggered when the X in the corner is pressed
    get_tree().quit()
