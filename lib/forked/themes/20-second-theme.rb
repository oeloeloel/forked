YELLOW_BRIGHT = { r: 0xff, g: 0xce, b: 0x27 }
YELLOW_PALE =   { r: 0xdf, g: 0xce, b: 0x77 }
PALE_GREEN    = { r: 0x73, g: 0xB4, b: 0x9D }
PURPLE =        { r: 0x2f, g: 0x2f, b: 0x54 }
PALE_PURPLE   = { r: 0x4f, g: 0x4f, b: 0x74 }
BLUE   =        { r: 0x97, g: 0xbf, b: 0xe8 }
WHITE  =        { r: 255,  g: 255,  b: 255  }
YELLOW_DARK   = { r: 0x65, g: 0x60, b: 0x55 } 

TWENTY_SECOND_THEME = {
  display: {
    background_color: { r: 0x2f, g: 0x2f, b: 0x54 },
  },
  heading: {
    **BLUE,
    size_enum: 8,
    font: 'fonts/mali/mali-bold.ttf',
  },
  rule: {
    **BLUE
  },
  paragraph: {
    **WHITE,
    font: 'fonts/mali/mali-regular.ttf',
    size_enum: 2,
    spacing_after: 0.4,
  },
  code_block: {
    **BLUE
  },
  code_block_box: {
    **PALE_PURPLE
  },
  blockquote: {
    **PURPLE,
    size_enum: 2,
    font: 'fonts/mali/mali-mediumitalic.ttf'
  },
  blockquote_box: {
    **BLUE
  },
  button: {
    r: 51, g: 51, b: 51,
    size_enum: 2,
    font: 'fonts/mali/mali-regular.ttf',
  },
  button_box: {
    **YELLOW_PALE
  },
  selected_button: {
    r: 51, g: 51, b: 51, 
  },
  selected_button_box: {
    **YELLOW_BRIGHT
  },
  disabled_button: {
    r: 51, g: 51, b: 51,
  },
  disabled_button_box: {
    **YELLOW_DARK
  },
  active_button: {
    r: 51, g: 51, b: 51, 
  },
  active_button_box: {
    **PALE_GREEN
  },
  bold: {
    font: 'fonts/mali/mali-bold.ttf',
        size_enum: 2,
    **WHITE
  },
  italic: {
    font: 'fonts/mali/mali-italic.ttf',
        size_enum: 2,
    **WHITE
  },
  bold_italic: {
    font: 'fonts/mali/mali-bolditalic.ttf',
        size_enum: 2,
    **WHITE 
  },
  code: {
    font: 'fonts/mali/mali-semibold.ttf',
    size_enum: 2,
    **BLUE
  }
}