DARK_MODE = {
  display: {
    background_color: { r: 35, g: 35, b: 35 },
  },
  heading: {
    r: 204, g: 204, b: 204,
  },
  rule: {
    r: 204, g: 204, b: 204,
  },
  paragraph: {
    r: 204, g: 204, b: 204,
  },
  code_block: {
    r: 179, g: 204, b: 127,
  },
  code_block_box: {
    r: 63, g: 67, b: 51,
  },
  blockquote: {
    r: 153, g: 179, b: 204,
  },
  blockquote_box: {
    r: 51, g: 63, b: 87,
  },
  button: {
    r: 51, g: 51, b: 51,
  },
  button_box: {
    r: 204, g: 204, b: 204,
  },
  rollover_button: {
    r: 51, g: 51, b: 51, 
  },
  rollover_button_box: {
    r: 204, g: 153, b: 153, 
  },
  inactive_button: {
    r: 51, g: 51, b: 51,
  },
  inactive_button_box: {
    r: 102, g: 102, b: 102, 
  },
  bold: {
    r: 204, g: 204, b: 204,
  },
  italic: {
    r: 204, g: 204, b: 204, 
  },
  bold_italic: {
    r: 204, g: 204, b: 204, 
  },
  code: {
    r: 153, g: 204, b: 102,
  }
}

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
    button: default_button,
    button_box: default_button_box,
    rollover_button: default_rollover_button,
    rollover_button_box: default_rollover_button_box,
    inactive_button: default_inactive_button,
    inactive_button_box: default_inactive_button_box,
    bold: default_bold_style,
    italic: default_italic_style,
    bold_italic: default_bold_italic_style,
    code: default_code_style
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
    font: 'fonts/Roboto/Roboto-Regular.ttf',
    size_enum: 0,
    line_spacing: 1, # 1.0 is the height of the font.
    r: 51, g: 51, b: 51,
    spacing_after: 0.7, 
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
    margin_bottom: 0
  }
end

def default_heading # defaults for heading text
  {
    r: 51, g: 51, b: 51,
    size_enum: 4,
    font: 'fonts/Roboto/Roboto-Black.ttf',
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
    font: 'fonts/Roboto_Mono/static/RobotoMono-Regular.ttf',
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
    padding_top: 10,
    padding_bottom: 10,
  )
end

def default_blockquote # defaults for block quote text
  default_paragraph.merge(
    r: 102, g: 76, b: 51,
  )
end

def default_blockquote_box # defualts for blockquote background
  default_box.merge(
    r: 204, g: 192, b: 168,
    padding_left: 100,
    padding_right: 20,
    padding_top: 10,
    padding_bottom: 10,
    margin_left: 20,
    margin_right: 20,
  )
end

def default_button
  default_paragraph.merge(
    size_enum: 0,
    font: 'fonts/Roboto/Roboto-Bold.ttf',
    r: 204, g: 204, b: 204,
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

def default_rollover_button
  default_button.merge(
    r: 204, g: 204, b: 204,
  )
end

def default_rollover_button_box
  default_button_box.merge(
    r: 51, g: 102, b: 102,
  )
end

def default_inactive_button
  default_button.merge(
    r: 204, g: 204, b: 204,
  )
end

def default_inactive_button_box
  default_button_box.merge!(
    r: 153, g: 153, b: 153,
  )
end

# styles
def default_bold_style
  default_paragraph.merge(
    font: 'fonts/Roboto/Roboto-Bold.ttf',
  )
end

def default_italic_style
  default_paragraph.merge(
    font: 'fonts/Roboto/Roboto-Italic.ttf',
  )
end

def default_bold_italic_style
  default_paragraph.merge(
    font: 'fonts/Roboto/Roboto-BoldItalic.ttf',
  )
end

def default_code_style # inline code
  default_paragraph.merge(
    font: 'fonts/Roboto_Mono/static/RobotoMono-Regular.ttf',
    r: 102, g: 51, b: 153,
  )
end

$gtk.reset
$display = nil