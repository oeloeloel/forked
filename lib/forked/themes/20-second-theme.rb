YELLOW_BRIGHT = { r: 0xff, g: 0xce, b: 0x27 }
YELLOW_PALE =   { r: 0xdf, g: 0xce, b: 0x77 }
PURPLE =        { r: 0x2f, g: 0x2f, b: 0x54 }
BLUE   =        { r: 0x97, g: 0xbf, b: 0xe8 }
WHITE  =        { r: 255,  g: 255,  b: 255  }

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
    r: 179, g: 204, b: 127,
  },
  code_block_box: {
    r: 63, g: 67, b: 51,
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
  rollover_button: {
    r: 51, g: 51, b: 51, 
  },
  rollover_button_box: {
    **YELLOW_BRIGHT
  },
  inactive_button: {
    r: 51, g: 51, b: 51,
  },
  inactive_button_box: {
    r: 102, g: 102, b: 102, 
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
    r: 153, g: 204, b: 102,
  }
}