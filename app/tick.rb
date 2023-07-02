STORY_FILE = 'app/story.md'


DARK_MODE = {
  background_color: [51, 51, 51],
  text_color: { r: 204, g: 204, b: 204 },
  heading_text_color: { r: 204, g: 204, b: 204 },
  button_text_color: { r: 51, g: 51, b: 51 },
  button_disabled_text_color: { r: 51, g: 51, b: 51 },
  button_color: { r: 204, g: 204, b: 204 },
  button_rollover_color: { r: 204, b: 153, g: 153 },
  button_rollover_text_color: { r: 204, g: 204, b: 204 },
  button_disabled_color: { r: 102, g: 102, b: 102 },
  code_text_color: { r: 204, g: 204, b: 102 },
  horizontal_line_color: { r: 204, g: 204, b: 204 }
}

LIGHT_MODE = {
  background_color: [204, 204, 204],
  text_color: { r: 51, g: 51, b: 51 },
  heading_text_color: { r: 51, g: 51, b: 51 },
  button_text_color: { r: 204, g: 204, b: 204 },
  button_disabled_text_color: { r: 204, g: 204, b: 204 },
  button_color: { r: 51, g: 51, b: 51 },
  button_rollover_color: { r: 51, b: 102, g: 102 },
  button_rollover_text_color: { r: 51, g: 51, b: 51 },
  button_disabled_color: { r: 153, g: 153, b: 153 },
  code_text_color: { r: 51, g: 51, b: 102 },
  horizontal_line_color: { r: 51, g: 51, b: 51 }
}

DISPLAY = {
  # general display
  background_color: [204, 204, 204],
  margin_left: ml = 200,
  margin_top: 60,
  margin_right: mr = 200,
  margin_bottom: 20,
  w: 1280 - (ml + mr),

  # body text
  font_size_enum: 0,
  line_height: 26,
  text_color: { r: 51, g: 51, b: 51 },
  font_regular: 'fonts/Roboto/Roboto-Regular.ttf',
  paragraph_spacing: 0.5, # 1.0 is line_height.

  # headings
  heading_text_color: { r: 51, g: 51, b: 51 },
  heading_font_size_enum: 4,
  heading_font: 'fonts/Roboto/Roboto-Black.ttf',

  # buttons
  button_font_size_enum: -1,
  button_padding_left: 10,
  button_padding_top: 2,
  button_padding_right: 10,
  button_padding_bottom: 2,
  button_font: 'fonts/Roboto/Roboto-Bold.ttf',
  button_text_color: { r: 204, g: 204, b: 204 },
  button_disabled_text_color: { r: 204, g: 204, b: 204 },
  button_color: { r: 51, g: 51, b: 51 },
  button_rollover_color: { r: 51, b: 102, g: 102 },
  button_rollover_text_color: { r: 204, g: 204, b: 204 },
  button_disabled_color: { r: 153, g: 153, b: 153 },

  # code format
  code_font: 'fonts/Roboto_Mono/static/RobotoMono-Bold.ttf',
  code_text_color: { r: 102, g: 102, b: 153 },
  code_background_color: { r: 204, g: 204, b: 204 },

  # horizontal line
  horizontal_line_color: { r: 51, g: 51, b: 51 }
}

# DISPLAY.merge! DARK_MODE

def tick args
  args.outputs.background_color = [51, 51, 51]

  $story = Forked::Story.new
  $story.args = args
  $story.tick

end

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
  

$gtk.reset
$story = nil