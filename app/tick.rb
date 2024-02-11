STORY_FILE = 'app/story.md'
# STORY_FILE = 'app/peas.md'
# STORY_FILE = 'app/threshold.md'
STORY_FILE = 'app/wip/ad-hoc-test.md'

# THEME = LIGHT_MODE
THEME = DARK_MODE
# THEME = KIFASS_THEME
# THEME = TWENTY_SECOND_THEME

def tick args
  $timer_start = Time.now.to_f

  $story ||= Forked::Story.new
  args.outputs.background_color = [51, 51, 51]
  
  $story.args = args
  $story.tick

  if args.inputs.keyboard.key_held.nine
    args.outputs.labels << [10, 600, "%0.4f" % [$tick_time]].label
    args.outputs.labels << {
      x: 640, y: 360,
      text: "#{args.gtk.current_framerate_render} fps render, #{args.gtk.current_framerate_calc} fps simulation",
      size_enum: 20,
      r: 255, g: 0, b: 0, alignment_enum: 1, vertical_alignment_enum: 1 }
    args.outputs.primitives << args.gtk.current_framerate_primitives
  end
  
  args.state.forked.forked_show_eval ||= false
  if args.inputs.keyboard.key_held.two && args.inputs.keyboard.key_down.three
    args.state.forked.forked_show_eval = !args.state.forked.forked_show_eval
    puts args.state.forked.forked_show_eval 
  end
  $gtk.reset if args.inputs.keyboard.key_down.backspace

  $tick_time = Time.now.to_f - $timer_start 
end

$gtk.reset