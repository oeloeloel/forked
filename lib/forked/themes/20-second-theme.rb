module TWENTY_SECOND_THEME

  YELLOW_BRIGHT = { r: 0xff, g: 0xce, b: 0x27 }
  YELLOW_PALE =   { r: 0xdf, g: 0xce, b: 0x77 }
  PALE_GREEN    = { r: 0x73, g: 0xB4, b: 0x9D }
  PURPLE =        { r: 0x2f, g: 0x2f, b: 0x54 }
  PALE_PURPLE   = { r: 0x4f, g: 0x4f, b: 0x74 }
  BLUE   =        { r: 0x97, g: 0xbf, b: 0xe8 }
  WHITE  =        { r: 255,  g: 255,  b: 255  }
  YELLOW_DARK =   { r: 0x65, g: 0x60, b: 0x55 }
  CODE_COLOR =    { r: 255, g: 255, b: 125 }
  CODE_COLOR =    { r: 9, g: 108, b: 57 }

  REGULAR_FONT = 'fonts/mali/mali-regular.ttf'.freeze
  BOLD_FONT = 'fonts/mali/mali-bold.ttf'.freeze
  ITALIC_FONT = 'fonts/mali/mali-italic.ttf'.freeze
  MEDIUM_ITALIC_FONT = 'fonts/mali/mali-mediumitalic.ttf'.freeze
  BOLD_ITALIC_FONT = 'fonts/mali/mali-bolditalic.ttf'.freeze
  CODE_FONT = 'fonts/mali/mali-semibold.ttf'.freeze

  class << self
    def theme
      body_font_size_enum = if ($gtk.orientation == :portrait) || 
        $gtk.platform?(:ios) || 
        $gtk.platform?(:android)
        6
      else
        2
      end

      {
        background: {
          background_color: { r: 0x2f, g: 0x2f, b: 0x54 },
        },
        heading: {
          **BLUE,
          size_enum: $gtk.orientation == :landscape ? 8 : 16,
          font: BOLD_FONT,
        },
        rule: {
          **BLUE
        },
        paragraph: {
          **WHITE,
          size_enum: body_font_size_enum,
          font: REGULAR_FONT,
          spacing_after: 0.4,
        },
        code_block: {
          **BLUE,
          size_enum: body_font_size_enum,
          font: CODE_FONT,
        },
        code_block_box: {
          **PALE_PURPLE
        },
        blockquote: {
          **PURPLE,
          font: ITALIC_FONT,
          size_enum: body_font_size_enum,
        },
        blockquote_box: {
          **BLUE
        },
        button: {
          r: 51, g: 51, b: 51,
          font: REGULAR_FONT,
          size_enum: body_font_size_enum,
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
          name: "bold",
          font: BOLD_FONT,
          **WHITE,
          size_enum: body_font_size_enum,
        },
        italic: {
          name: "italic",
          font: ITALIC_FONT,
          **WHITE,
          size_enum: body_font_size_enum,
        },
        bold_italic: {
          name: "bold_italic",
          font: BOLD_ITALIC_FONT,
          **WHITE,
          size_enum: body_font_size_enum,
        },
        code: {
          name: "code",
          font: CODE_FONT,
          **BLUE,
          size_enum: body_font_size_enum,
        },
        blockquote_bold: {
          name: "blockquote_bold",
          font: BOLD_ITALIC_FONT,
          **PURPLE,
          size_enum: body_font_size_enum,
        },
        blockquote_italic: {
          name: "blockquote_italic",
          font: REGULAR_FONT,
          **PURPLE,
          size_enum: body_font_size_enum,
        },
        blockquote_bold_italic: {
          name: "blockquote_bold_italic",
          font: BOLD_FONT,
          **PURPLE,
          size_enum: body_font_size_enum,
        },
        blockquote_code: {
          name: "blockquote_code",
          font: CODE_FONT,
          **CODE_COLOR,
          size_enum: body_font_size_enum,
        }
      }
    end
  end
end