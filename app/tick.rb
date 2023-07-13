# STORY_FILE = 'app/story.md'
# STORY_FILE = 'app/peas.md'
# STORY_FILE = 'app/threshold.md'
STORY_FILE = 'app/tests.md'
# STORY_FILE = 'app/todo.md'

# THEME = LIGHT_MODE
THEME = DARK_MODE
# THEME = KIFASS_THEME

#################
# Custom commands
#################

def inventory_add item
  inventory << item unless inventory_has? item
end

def inventory_del item
  inventory.delete item
end

def inventory_has? item
  inventory.include? item
end

def inventory
  $args.state.forked_inventory ||= []
end

def inventory_clear
  $args.state.forked_inventory = []
end

def jump label
  $story.follow $args, { action: label }
end
  
def tick args
  args.outputs.background_color = [51, 51, 51]

  $story = Forked::Story.new
  $story.args = args
  $story.tick

  if args.inputs.keyboard.key_held.nine

    args.outputs.labels  << { 
      x: 640, y: 360, 
      text: "#{args.gtk.current_framerate_render} fps render, #{args.gtk.current_framerate_calc} fps simulation", 
      size_enum: 20, 
      r: 255, g: 0, b: 0, alignment_enum: 1, vertical_alignment_enum: 1 }
    args.outputs.primitives << args.gtk.current_framerate_primitives
  end
  reset if args.inputs.keyboard.key_down.backspace
end

def reset
  $story = nil
  $args.gtk.reset
end

reset