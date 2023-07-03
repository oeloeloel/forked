STORY_FILE = 'app/story.md'
# STORY_FILE = 'app/peas.md'
# STORY_FILE = 'app/threshold.md'

THEME = LIGHT_MODE
# THEME = DARK_MODE
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
  
def tick args
  args.outputs.background_color = [51, 51, 51]

  $story = Forked::Story.new
  $story.args = args
  $story.tick
end

$gtk.reset
$story = nil