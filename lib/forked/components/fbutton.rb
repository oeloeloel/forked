# a module for Forked Components
module Effed
  # Forked Button
  class FButton
    attr_gtk
    attr_sprite
    attr_accessor :action, :counter

    def initialize(**kwargs)
      @data = kwargs
      @action = kwargs.rect.action
      @x = kwargs.rect.x
      @y = kwargs.rect.y
      @w = kwargs.rect.w
      @h = kwargs.rect.h
      force_status_change(:enabled)
    end

    def force_status_change(status)
      # disabled, enabled, focused, active
      @primitives = if status == :active && @data.active
                      @data.active
                    elsif status == :focused && @data.focused && !$gtk.platform?(:touch)
                      @data.focused
                    elsif status == :disabled && @data.disabled
                      @data.disabled
                    else
                      @data.enabled
                    end

      @output = @primitives.map do |prim|
        {
          **prim,
          **@data.rect,
          x: (prim.x || 0) + @data.rect.x,
          y: (prim.y || 0) + @data.rect.y,
          w: prim.w || @data.rect.w,
          h: prim.h || @data.rect.h
        }
      end
    end

    def draw_override(ffi_draw)
      @output.each do |o|
        if o.path
          ffi_draw.draw_sprite_6(
            o.x, o.y, o.w, o.h,
            o.path.to_s,
            0,
            255, o.r, o.g, o.b,
            nil, nil, nil, nil,
            nil, nil,
            nil, nil,
            nil, nil, nil, nil,
            nil,
            nil,
            nil,
            nil
          )
        elsif o.text
          ffi_draw.draw_label_5(
            o.x, o.y,
            o.text,
            o.size_enum, nil,
            o.r, o.g, o.b, o.a,
            o.font,
            nil,
            nil, nil,
            0.5, 0.5
          )
        end
      end
    end
  end

  class << self
    def button args, **kwargs
      if (kwargs.keys & %i[rect enabled]).size < 2
        msg = "Missing argument(s). Provide required rect and enabled state."
        raise msg
      end

      within = args.inputs.mouse.inside_rect? kwargs.rect
      was_pushed_within = args.inputs.mouse.previous_click&.inside_rect? kwargs.rect
      active = within && was_pushed_within && args.inputs.mouse.held

      args.gtk.set_system_cursor(:hand) if within
      kwargs.action.call if args.inputs.mouse.up && within && was_pushed_within && kwargs.action

      primitives = if active && kwargs.active
                     kwargs.active
                   elsif within && kwargs.focused
                     kwargs.focused
                   else
                     kwargs.enabled
                   end

      primitives.map do |prim|
        {
          **prim,
          **kwargs.rect,
          x: (prim.x || 0) + kwargs.rect.x,
          y: (prim.y || 0) + kwargs.rect.y,
          w: prim.w || kwargs.rect.w,
          h: prim.h || kwargs.rect.h
        }
      end
    end

    def pill_button_layer _args, **params
      [
        {
          path: 'sprites/white-circle.png',
          x: 0,
          w: params.rect.h, h: params.rect.h,
          **params.bg
        }.sprite!,
        {
          path: 'sprites/white-circle.png',
          x: params.rect.w - params.rect.h,
          w: params.rect.h, h: params.rect.h,
          **params.bg
        }.sprite!,
        {
          x: params.rect.h / 2,
          path: :solid, **params.bg,
          w: params.rect.w - params.rect.h
        }.sprite!,
        {
          x: params.rect.w / 2,
          y: params.rect.h / 2,
          text: params.text, **params.color,
          font: params.font, size_enum: params.size_enum,
          anchor_x: 0.5, anchor_y: 0.5
        }
      ]
    end
  end
end
