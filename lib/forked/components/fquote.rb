module Effed
  class << self
    def rounded_panel(**kwargs)
      diameter = kwargs.rect.w * 0.025
      color = { r: kwargs.rect.r, g: kwargs.rect.g, b: kwargs.rect.b }
      [
        {
          x: (kwargs.rect.x + diameter / 2).to_i, 
          y: kwargs.rect.y.to_i,
          w: (kwargs.rect.w - diameter).to_i, 
          h: kwargs.rect.h.to_i,
          **color,
        }.sprite!,
        {
          x: kwargs.rect.x.to_i, 
          y: (kwargs.rect.y + diameter / 2).to_i,
          w: kwargs.rect.w.to_i, 
          h: (kwargs.rect.h - diameter).to_i,
          **color
        }.sprite!,
        {
          x: kwargs.rect.x.to_i, 
          y: kwargs.rect.y.to_i, 
          w: diameter.to_i, h: diameter.to_i, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!,
        {
          x: kwargs.rect.x.to_i, 
          y: (kwargs.rect.y + kwargs.rect.h - diameter).to_i, 
          w: diameter.to_i, h: diameter.to_i, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!,
        {
          x: (kwargs.rect.x + kwargs.rect.w - diameter).to_i, 
          y: kwargs.rect.y.to_i, 
          w: diameter.to_i, h: diameter.to_i, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!,
        {
          x: (kwargs.rect.x + kwargs.rect.w - diameter).to_i, 
          y: (kwargs.rect.y + kwargs.rect.h - diameter).to_i, 
          w: diameter.to_i, h: diameter.to_i, 
          **color,
          path: 'sprites/white-circle.png'
        }.sprite!
      ]
    end
  end
end