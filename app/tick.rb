STORY_FILE = 'app/story.md'
# STORY_FILE = 'app/story.json'
# STORY_FILE = 'app/peas.md'
# STORY_FILE = 'app/threshold.md'
  STORY_FILE = 'app/forked/tests/navigation.md'



# THEME = LIGHT_MODE
THEME = DARK_MODE
# THEME = KIFASS_THEME
# THEME = TWENTY_SECOND_THEME

#################
# Custom commands
#################

### BAG (player inventory)

# adds an item to the player inventory
def bag_add item
  bag << item unless bag_has? item
end

# removes an item from the player inventory
def bag_remove item
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
# def jump label
#   $story.follow $args, { action: label }
# end

### Background
# Sets the background image to a 1280x720 png file (run from a condition)
def background_image(path)
  $args.outputs.sprites << {
    x: 0,
    y: 0,
    w: 1280,
    h: 720,
    path: path
  }
end

### Counters

def counter
  $args.state.forked_counter ||= {}
end

def counter_up name, value = 1
  counter[name] += value
end

def counter_down name, value = 1
  counter[name] -= value
end

def counter_add name, value = 0
  counter[name] = value
end

def counter_remove name
  counter.delete(name)
end

def counter_check name
  counter[name]
end

def counter_clear
  $args.state.forked_counter = {}
end

### Memos
# stores information that can be checked later
def memo
  $args.state.forked_memo ||= {}
end

# adds a memo
def memo_add name, value
  memo[name] = value
end

# deletes a memo
def memo_remove name
  memo.delete(name)
end

# clears all memos
def memo_clear
  $args.state.forked_memo = {}
end

# returns true if a memo exists
def memo_exists? name
  memo[name] != nil
end

# returns the value of a memo
def memo_check name
  memo[name]
end

### Wallet
# Keeps track of the player's finances (gold coins, dollars, anything you like)
def wallet
  args.state.forked_wallet ||= 0
end

# adds money to the wallet
def wallet_plus num
  wallet = wallet + num
end

# removes money from the wallet
def wallet_minus num
  wallet = wallet - num
end

# removes all money from the wallet
def wallet_clear
  wallet = 0
end

### Timers
# lets you create timers
def timer
  args.state.forked_timer ||= {}
end

# creates a new, named timer with the provided duration
def timer_add name, duration
  timer[name] = {
    start_time: $args.tick_count,
    duration: duration
  }
end

# removes a named timer
def timer_remove name
  timer.delete(name)
end

# checks how much time is left for a timer (will be negative when duration is up)
def timer_check name
  timer[name][:duration] - ($args.tick_count - timer[name][:start_time])
end

# returns true if the named timer is complete
def timer_done? name
  timer_check(name) <= 0
end

# returns timer value as seconds, minimum 0
def timer_seconds(name)
  timer_check(name).idiv(60).greater(0)
end

### Dice Roll
def roll dice
  result = 0
  num_dice, num_sides = dice.split('d', 2)
  num_dice.to_i.times { result += rand(num_sides.to_i) + 1 }
  result
end

def tick args
  $timer_start = Time.now.to_f

  $story ||= Forked::Story.new
  args.outputs.background_color = [51, 51, 51]
  
  $story.args = args
  $story.tick

  if args.inputs.keyboard.key_held.nine
    args.outputs.labels << [10, 600, "%0.4f" % [$tick_time]].label
    args.outputs.labels << {
      x: 640, y: 360,
      text: "#{args.gtk.current_framerate_render} fps render, #{args.gtk.current_framerate_calc} fps simulation",
      size_enum: 20,
      r: 255, g: 0, b: 0, alignment_enum: 1, vertical_alignment_enum: 1 }
    args.outputs.primitives << args.gtk.current_framerate_primitives
  end
  
  args.state.forked.forked_show_eval ||= false
  if args.inputs.keyboard.key_held.two && args.inputs.keyboard.key_down.three
    args.state.forked.forked_show_eval = !args.state.forked.forked_show_eval
    puts args.state.forked.forked_show_eval 
  end
  $gtk.reset if args.inputs.keyboard.key_down.backspace

  $tick_time = Time.now.to_f - $timer_start 
end

$gtk.reset