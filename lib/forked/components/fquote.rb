module Effed
  class FQuote
    attr_gtk
    attr_sprite

    def initialize(**kwargs)
      @data = kwargs
      
    end

    def draw_override(ffi_draw)
      # @output.each do |o|
      #   if o.path
      #     ffi_draw.draw_sprite_6(
      #       o.x, o.y, o.w, o.h,
      #       o.path.to_s,
      #       0,
      #       255, o.r, o.g, o.b,
      #       nil, nil, nil, nil,
      #       nil, nil,
      #       nil, nil,
      #       nil, nil, nil, nil,
      #       nil,
      #       nil,
      #       nil,
      #       nil
      #     )
      #   elsif o.text
      #     ffi_draw.draw_label_5(
      #       o.x, o.y,
      #       o.text,
      #       o.size_enum, nil,
      #       o.r, o.g, o.b, o.a,
      #       o.font,
      #       nil,
      #       nil, nil,
      #       0.5, 0.5
      #     )
      #   end
      # end
    end
  end

  class << self
    def rounded_panel(**kwargs)
      putz kwargs
      diameter = kwargs.rect.w * 0.025
      color = { r: kwargs.rect.r, g: kwargs.rect.g, b: kwargs.rect.b }
      [
        {
          x: kwargs.rect.x + diameter / 2, y: kwargs.rect.y,
          w: kwargs.rect.w - diameter, h: kwargs.rect.h,
          **color,
        }.sprite!,
        {
          x: kwargs.rect.x, y: kwargs.rect.y + diameter / 2,
          w: kwargs.rect.w, h: kwargs.rect.h - diameter,
          **color
        }.sprite!,
        {
          x: kwargs.rect.x, 
          y: kwargs.rect.y, 
          w: diameter, h: diameter, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!,
        {
          x: kwargs.rect.x, 
          y: kwargs.rect.y + kwargs.rect.h - diameter, 
          w: diameter, h: diameter, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!,
        {
          x: kwargs.rect.x + kwargs.rect.w - diameter, 
          y: kwargs.rect.y, 
          w: diameter, h: diameter, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!,
        {
          x: kwargs.rect.x + kwargs.rect.w - diameter, 
          y: kwargs.rect.y + kwargs.rect.h - diameter, 
          w: diameter, h: diameter, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!
      ]
    end
  end
end