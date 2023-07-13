STORY_FILE = 'app/story.md'
# STORY_FILE = 'app/peas.md'
# STORY_FILE = 'app/threshold.md'
# STORY_FILE = 'app/tests.md'
# STORY_FILE = 'app/todo.md'

# THEME = LIGHT_MODE
THEME = DARK_MODE
# THEME = KIFASS_THEME

#################
# Custom commands
#################

### BAG (player inventory)

# adds an item to the player inventory
def bag_add item
  bag << item unless bag_has? item
end

# removes an item from the player inventory
def bag_del item
  bag.delete item
end

# returns true if the player inventory includes item
def bag_has? item
  bag.include? item
end

# the player inventory
def bag
  $args.state.forked_bag ||= []
end

# empties the player inventory
def bag_clear
  $args.state.forked_bag = []
end

### Navigation

# Jump to a specified label
def jump label
  $story.follow $args, { action: label }
end

### Background
def background_image(path)
  $args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 1280,
    h: 720,
    path: path
  }
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