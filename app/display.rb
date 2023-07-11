  $gtk.reset

module Forked
  class Display
    attr_gtk
    
    def initialize theme = nil
      @theme = theme
    end

    def tick
      defaults unless data.defaults_set
      input
      render
    end

    def data
      args.state.forked.display ||= args.state.new_entity('forked display')
    end

    def defaults
      data.config = config_defaults
      data.options = []
      data.defaults_set = true
      apply_theme(@theme)
    end

    def apply_theme(theme)
      data.config = config_defaults
      return unless theme

      theme.each do |k, v|
        data.config[k].merge!(v)
      end
    end

    def input
      return if data.options.nil? || data.options.empty?

      data.options.each do |option|
        next if option.action.empty?

        if option.intersect_rect?(inputs.mouse.point)
          option.merge!(data.config.rollover_button_box)

          $story.follow(args, option) if args.inputs.mouse.up
        else
          option.merge!(data.config.button_box)
        end
      end
    end

    def update content
      data.primitives = []
      data.options = []

      display = data.config.display
      paragraph = data.config.paragraph
      heading = data.config.heading
      rule = data.config.rule
      code_block = data.config.code_block
      code_block_box = data.config.code_block_box
      blockquote = data.config.blockquote
      blockquote_box = data.config.blockquote_box
      blockquote_image = data.config.blockquote_image
      button = data.config.button
      button_box = data.config.button_box
      inactive_button_box = data.config.inactive_button_box

      # background solid for display area, not very useful

      # data.primitives << {
      #   x: display.margin_left,
      #   y: display.margin_bottom,
      #   w: display.w,
      #   h: display.h,
      #   **display.background_color
      # }.sprite!
      y_pos = display.margin_top.from_top

      content.each_with_index do |item, i|
        case item[:type]
        when :heading
          text = item.text
          text = $story.title if item.text.empty?

          heading.size_px = args.gtk.calcstringbox('X', heading.size_enum, heading.font)[1]

          data.primitives << {
            x: display.margin_left,
            y: y_pos,
            text: item.text,
          }.label!(heading)

          y_pos -= heading.size_px * heading.spacing_after
          
        when :rule
          data.primitives << {
            x: display.margin_left,
            y: y_pos,
            w: display.w,
            h: rule.weight
          }.sprite!(rule)

          y_pos -= rule.spacing_after

        when :paragraph
          x_pos = 0
          item.atoms.each_with_index do |atom, i|
            # defaults
            paragraph.size_px = args.gtk.calcstringbox('X', paragraph.size_enum, paragraph.font)[1]

            # font style can change
            font_style = get_font_style(atom.styles)

            default_space_w = args.gtk.calcstringbox(' ', font_style.size_enum, paragraph.font)[0]
            words = atom.text.split(' ')
            line_frag = ''

            until words.empty?
              word = words[0]

              new_frag = line_frag + word
              new_x_pos = x_pos + gtk.calcstringbox(new_frag, font_style.enum, font_style.font)[0]

              if new_x_pos > display.w
                loc = { x: x_pos + display.margin_left, y: y_pos }
                lab = loc.merge(make_paragraph_label(line_frag, font_style))
                data.primitives << lab
                line_frag = ''
                x_pos = 0
                y_pos -= paragraph.size_px * paragraph.line_spacing
              else
                line_frag = new_frag + ' '
                words.shift
              end

              if words.empty?
                loc = { x: x_pos + display.margin_left, y: y_pos }
                lab = loc.merge(make_paragraph_label(line_frag, font_style))
                data.primitives << lab 
                x_pos = new_x_pos + default_space_w
                line_frag = ''
              end
            end
          end
          y_pos -= paragraph.size_px
          y_pos -= paragraph.size_px * paragraph.spacing_after

        when :code_block
          text_array = wrap_lines_code_block(item.text, code_block.font, code_block.size_enum, display.w - (code_block_box.padding_left + code_block_box.padding_right))
          code_block.size_px = args.gtk.calcstringbox('X', code_block.size_enum, code_block.font)[1]

          box_height = text_array.count * (code_block.size_px * code_block.line_spacing) +
                      code_block_box.padding_top + code_block_box.padding_bottom

          temp_y_pos = y_pos

          data.primitives << {
            x: display.margin_left,
            y: temp_y_pos - box_height,
            w: display.w,
            h: box_height,
          }.sprite!(code_block_box)

          temp_y_pos -= code_block_box.padding_top

          data.primitives << text_array.map do |line|

            label = {
              x: display.margin_left + code_block_box.padding_left,
              y: temp_y_pos,
              text: line,
            }.label!(code_block)

            temp_y_pos -= code_block.size_px * code_block.line_spacing

            label
          end

          y_pos -= box_height
          y_pos -= code_block.size_px * code_block.spacing_after

        when :blockquote

          # if previous element is also a blockquote, use spacing_between instead of spacing_after
          if content[i - 1].type == :blockquote
            y_pos += blockquote.spacing_after * blockquote.size_px
            y_pos -= blockquote.spacing_between * blockquote.size_px
          end

          text_array = wrap_lines(item.text, blockquote.font, blockquote.size_enum, display.w - (blockquote_box.padding_left + blockquote_box.padding_right))

          blockquote.size_px = args.gtk.calcstringbox('X', blockquote.size_enum, blockquote.font)[1]

          box_height = text_array.count * (blockquote.size_px * blockquote.line_spacing) +
          blockquote_box.padding_top + blockquote_box.padding_bottom
          box_height = box_height.greater(blockquote_box[:min_height])

          data.primitives << {
            x: display.margin_left,
            y: y_pos - box_height,
            w: display.w,
            h: box_height,
          }.sprite!(blockquote_box)

          temp_y_pos = y_pos - blockquote_box.padding_top

          data.primitives << text_array.map do |line| 
            label = {
              x: display.margin_left + blockquote_box.padding_left,
              y: temp_y_pos,
              text: line,
            }.label!(blockquote)

            temp_y_pos -= blockquote.size_px * blockquote.line_spacing

            label
          end

          y_pos -= box_height
          y_pos -= blockquote.size_px * blockquote.spacing_after

        when :button
          # if previous element is also a button, use spacing_between instead of spacing_after
          if content[i - 1].type == :button
            y_pos += button.spacing_after * button.size_px
            y_pos -= button.spacing_between * button.size_px
          end

          button.size_px = args.gtk.calcstringbox('X', button.size_enum, button.font)[1]
          
          text_w, button.size_px = args.gtk.calcstringbox(item.text, button.size_enum, button.font)
          button_h = (button.size_px + button_box.padding_top + button_box.padding_bottom) 


          if !item.action.empty?
            option = {
              x: display.margin_left,
              y: y_pos - button_h,
              w: text_w + button_box.padding_left + button_box.padding_right,
              h: (button.size_px + button_box.padding_top + button_box.padding_bottom),
              action: item.action
            }.sprite!(button_box)
            y_pos -= button_box.padding_top

            data.primitives << option
            data.options << option unless data.options.include? option
          else
            data.primitives << {
              x: display.margin_left,
              y: y_pos - button_h,
              w: text_w + button_box.padding_left + button_box.padding_right,
              h: (button.size_px + button_box.padding_top + button_box.padding_bottom),

            }.sprite!(inactive_button_box)

            y_pos -= button_box.padding_top
          end

          data.primitives << {
            x: display.margin_left + button_box.padding_left,
            y: y_pos,
            text: item.text,
          }.label!(button)

          y_pos -= button.size_px + button_box.padding_bottom
          y_pos -= button.size_px * button.spacing_after
        end
      end
    end

    def get_font_style styles
      if styles.include?(:bold) && styles.include?(:italic)
        data.config.bold_italic
      elsif styles.include? :bold
        data.config.bold
      elsif styles.include? :italic
        data.config.italic
      elsif styles.include? :code
        data.config.code
      else
        data.config.paragraph
      end
    end

    # make a one line label in the specified style
    def make_paragraph_label text, font_style
      {
        text: text,
      }.label!(data.display.paragraph).merge!(font_style)
    end

    def wrap_lines_code_block str, font, size_px, width
      
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''
        if l.strip.empty?
          wrapped_text << ''
          next
        end
        words = l.strip.split(" ") 

        until words.empty?
          line_next = fixed_width_line + words[0]
          if args.gtk.calcstringbox(line_next, size_px, font)[0] < width
            fixed_width_line = line_next + ' '
            words.shift
          else
            wrapped_text << fixed_width_line
            fixed_width_line = ''
          end

          if words.empty?
            wrapped_text << fixed_width_line
            wrapped_text << '' if l.strip.empty?
          end
        end
      end

      wrapped_text
    end


    def wrap_lines str, font, size_px, width
      wrapped_text = []
      str.lines.map do |l|
        fixed_width_line = ''

        words = l.strip.split(" ") 

        until words.empty?
          line_next = fixed_width_line + words[0]
          if args.gtk.calcstringbox(line_next, size_px, font)[0] < width
            fixed_width_line = line_next + ' '
            words.shift
          else
            wrapped_text << fixed_width_line
            fixed_width_line = ''
          end

          if words.empty?
            wrapped_text << fixed_width_line
          end
        end
      end

      wrapped_text
    end

    def render
      outputs.background_color = data.config.display.background_color.values

      args.outputs.primitives << data.primitives
    end
  end
end

  # reference for display format
  #   [
  #     {
  #       type: :heading,
  #       text: "Non eram nescius",
  #     },
  #     {
  #       type: :rule
  #     },
  #     {
  #       type: :paragraph,
  #       atoms: [
  #         {
  #           text: "Non eram nescius,",
  #           styles: []
  #         },
  #         {
  #           text: "Brute, cum, quae summis ingeniis",
  #           styles: [:italic]
  #         }, 
  #         {
  #           text: " exquisitaque doctrina philosophi Graeco sermone tractavissent, ea",
  #           styles: []
  #         },
  #         {
  #           text: " Latinis litteris mandaremus,",
  #           styles: [:bold]
  #         },
  #         {
  #           text: "fore ut hic noster labor in varias reprehensiones incurreret. nam quibusdam, et iis quidem non admodum indoctis,",
  #           styles: []
  #         },
  #         {
  #           text: " totum hoc displicet",
  #           styles: [:bold, :italic]
  #         },   
  #         {
  #           text: " philosophari. quidam autem non tam id",
  #           styles: []
  #         }, 
  #         {
  #           text: " reprehendunt",
  #           styles: [:code]
  #         },
  #         {
  #           text: "si remissius agatur sed.",
  #           styles: []
  #         },  
  #        ]
  #     },
  #     {
  #     type: :code_block,
  #     text: "def default_code_block # defaults for code block text
  #   {
  #     font: 'fonts/Roboto_Mono/static/RobotoMono-Regular.ttf',
  #     size_px: 22,
  #     line_spacing: 0.85,
  #     r: 76, g: 51, b: 127,
  #     spacing_after: 0.7, # 1.0 is line_height.
  #   }
  # end",
  #     },
  #     {
  #     type: :blockquote,
  #     text: "Contra quos omnis dicendum breviter existimo. Quamquam philosophiae quidem vituperatoribus satis responsum est eo libro, quo a nobis philosophia defensa et collaudata est, cum esset accusata et vituperata ab Hortensio.",
  #     },
  #     {
  #     type: :button,
  #     text: "Contra quos omnis",
  #     action: "puz'This button was clicked'"
  #     },
  #   ]
