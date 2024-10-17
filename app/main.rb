#### main.rb ####
# This file is the starting point of your game
# You can change some of the settings in here to
# quickly set things up

#### Require Forked ####
# This line tells DragonRuby where to find Forked
# If you change the location of Forked, you need
# to update this line
require 'lib/forked/forked.rb'

#### load the story file ####

# This line tells Forked where to find the story file.
# If you change the name or location of the file, update it here.
STORY_FILE = 'app/story.md'  # the Forked User Manual

#### Set the theme ####
# You can change the theme here, or set it in the story file

THEME = DARK_MODE # Dark background, light text
# other themes:
# THEME = LIGHT_MODE # Light background, dark text
# THEME = KIFASS_THEME # Vibrant colours inspired by the KIFASS game jam
# THEME = TWENTY_SECOND_THEME # Colour scheme inspired by the 20 Second Game Jam

#################
# TICK METHOD
# -----------
# Loads the story
#################
def tick args
  # on the html5 player, the story file loads faster if doesn't run immediately
  # the code below prevents Forked from running on the first tick (tick 0) if the game is running on the web
  # this is a good place to add a splash/loading screen if you want one
  # but, generally, loading will be complete before the player has time to read any text
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
