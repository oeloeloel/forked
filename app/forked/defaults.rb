module Forked
  extend self

  def forked_defaults
    {
      # if autosave is true, game progress will be
      # saved every time the player clicks a button
      autosave: false,
    }
  end
end