
def config_defaults
  { 
    display: default_display,
    heading: default_heading,
    rule: default_rule,
    paragraph: default_paragraph,
    code_block: default_code_block,
    code_block_box: default_code_block_box,
    blockquote: default_blockquote,
    blockquote_box: default_blockquote_box,
    blockquote_image: default_blockquote_image,
    button: default_button,
    button_box: default_button_box,
    selected_button: default_selected_button,
    selected_button_box: default_selected_button_box,
    active_button: default_active_button,
    active_button_box: default_active_button_box,
    disabled_button: default_disabled_button,
    disabled_button_box: default_disabled_button_box,
    bold: default_bold_style,
    italic: default_italic_style,
    bold_italic: default_bold_italic_style,
    code: default_code_style,
    image: default_image_style
  }
end

def default_display
  {
    background_color: { r: 229, g: 229, b: 229 },
    margin_left: ml = 200,
    margin_top: mt = 60,
    margin_right: mr = 200,
    margin_bottom: mb = 20,
    w: 1280 - (ml + mr),
    h: 720 - (mb + mt),
  }
end

def default_paragraph
  {
    font: 'fonts/roboto/roboto-regular.ttf',
    size_enum: 0,
    line_spacing: 1, # 1.0 is the height of the font.
    r: 51, g: 51, b: 51,
    spacing_between: 0.6,
    spacing_after: 0.9,

  }
end

def default_box
  {
    padding_left: 0,
    padding_right: 0,
    padding_top: 0,
    padding_bottom: 0,
    margin_left: 0,
    margin_right: 0,
    margin_top: 0,
    margin_bottom: 0,
    min_height: 0,
  }
end

def default_heading # defaults for heading text
  {
    r: 51, g: 51, b: 51,
    size_enum: 4,
    font: 'fonts/roboto/roboto-black.ttf',
    spacing_after: 1.5
  }
end

def default_rule # defaults for horizontal rule
  {
    r: 51, g: 51, b: 51,
    weight: 3,
    spacing_after: 11,
  }
end

def default_code_block # defaults for code block text
  {
    font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
    size_enum: 0,
    line_spacing: 0.85,
    r: 76, g: 51, b: 127,
    spacing_after: 0.7, # 1.0 is line_height.
  }
end

def default_code_block_box # defaults for code block background
  default_box.merge(
    r: 192, g: 188, b: 204,
    padding_left: 20,
    padding_right: 20,
    padding_top: 7,
    padding_bottom: 12,
  )
end

def default_blockquote # defaults for block quote text
  default_paragraph.merge(
    r: 102, g: 76, b: 51,
    spacing_between: 0,
    spacing_after: 0.7,
  )
end

def default_blockquote_box # defaults for blockquote background
  default_box.merge(
    r: 204, g: 192, b: 168,
    padding_left: 20,
    padding_right: 20,
    padding_top: 10,
    padding_bottom: 10,
    margin_left: 20,
    margin_right: 20,
    min_height: 0 # default_blockquote_image[:height] + 20
  )
end

def default_blockquote_image
  {
    width: 80,
    height: 80,
    path: 'sprites/haunted.png'
  }
end

def default_button
  default_paragraph.merge(
    size_enum: 0,
    font: 'fonts/roboto/roboto-bold.ttf',
    r: 204, g: 204, b: 204,
    spacing_after: 0.7,
    spacing_between: 0.25
  )
end

def default_button_box
  default_box.merge(
    padding_left: 10,
    padding_top: 6,
    padding_right: 10,
    padding_bottom: 6,
    r: 51, g: 51, b: 51,
  )
end

def default_selected_button
  default_button.merge(
    r: 204, g: 204, b: 204,
  )
end

def default_selected_button_box
  default_button_box.merge(
    r: 51, g: 102, b: 102,
  )
end



def default_active_button
  default_button.merge(
    r: 204, g: 204, b: 204,
  )
end

def default_active_button_box
  default_button_box.merge(
    r: 255, g: 102, b: 102,
  )
end

def default_disabled_button
  default_button.merge(
    r: 204, g: 204, b: 204,
  )
end

def default_disabled_button_box
  default_button_box.merge!(
    r: 153, g: 153, b: 153,
  )
end

# styles
def default_bold_style
  default_paragraph.merge(
    font: 'fonts/roboto/roboto-bold.ttf',
  )
end

def default_italic_style
  default_paragraph.merge(
    font: 'fonts/roboto/roboto-italic.ttf',
  )
end

def default_bold_italic_style
  default_paragraph.merge(
    font: 'fonts/roboto/roboto-bolditalic.ttf',
  )
end

def default_code_style # inline code
  default_paragraph.merge(
    font: 'fonts/roboto_mono/static/robotomono-regular.ttf',
    r: 102, g: 51, b: 153,
  )
end

def default_image_style
  {
    spacing_after: 20,
    anchor_x: 0.5,
    x: $args.grid.w.half,
  }
end

$gtk.reset
$display = nil
