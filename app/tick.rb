#########################################################################
# STORY FILE
# ----------
# Edit below to change the story file
# Adding a `#` at the start of a line will stop a story file from loading
# Removing the `#` from the start of a line will make the story file load
# Only one story file will load
#########################################################################

# This is the user manual
STORY_FILE = 'app/story.md'

# A story about three peas, written by Raymond Queneau
# STORY_FILE = 'app/peas.md'

# A fragment of a ghost story
# STORY_FILE = 'app/threshold.md'

########################################
# THEMES
# ------
# Edit below to change the display theme
########################################

# Light background, dark text
# THEME = LIGHT_MODE

# Dark background, light text
# THEME = DARK_MODE

# Vibrant colours inspired by the KIFASS game jam
THEME = KIFASS_THEME

# Colour scheme inspired by the 20 Second Game Jam
# THEME = TWENTY_SECOND_THEME

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
  $story ||= Forked::Story.new

  # keep the story running every tick
  $story.args = args
  $story.tick
end

$gtk.reset