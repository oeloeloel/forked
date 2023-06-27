STORY_FILE = 'app/story.md'

DISPLAY = {
  # general display
  w: 1240,
  margin_left: 20,
  margin_top: 20,
  margin_right: 20,
  margin_bottom: 20,

  # body text
  font_size_enum: 0,
  line_height: 26,
  text_color: { r: 51, g: 51, b: 51 },
  font_regular: 'fonts/Roboto/Roboto-Regular.ttf',

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
  button_rollover_color: { r: 204, b: 51, g: 51 },
  button_disabled_color: { r: 153, g: 153, b: 153 },

  # code format
  code_font: 'fonts/Roboto_Mono/static/RobotoMono-Bold.ttf',
  code_text_color: { r: 102, g: 102, b: 153 },
}

def tick args
  $story = Forked::Story.new
  $story.args = args
  $story.tick
end

$gtk.reset
$story = nil