#### main.rb ####
# This file is the starting point of your game

#### Require Forked ####
# Tell DragonRuby where to find Forked
require 'lib/forked/forked'

#### load the story file ####

# Tell Forked where to find the story file.
STORY_FILE = 'app/story.md' # the Forked User Manual

#### Set the theme ####
# You can change the theme here, or set it in the story file
THEME = DARK_MODE # Dark background, light text

# some other themes:
# THEME = LIGHT_MODE # Light background, dark text
# THEME = KIFASS_THEME # Vibrant colours inspired by the KIFASS game jam
# THEME = TWENTY_SECOND_THEME # Colour scheme inspired by the 20 Second Game Jam

#################
# TICK METHOD
# -----------
# Loads the story
#################
def tick args
  # performance optimization for web: don't run the story on the first tick
  if args.tick_count.zero? && args.gtk.platform?(:web)
    # display a black background color so we don't get a white flash
    args.outputs.background_color = { r: 0, g: 0, b: 0 }
    return
  end

  # load the story file specified at the top of this page
  $story ||= Forked::Story.new(STORY_FILE)

  # keep the story running every tick
  $story.args = args
  $story.tick
end

$gtk.reset
