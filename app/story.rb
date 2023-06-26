Forking.story do
  title "The Threshold"

  location :threshold do
    heading "The threshold"

    p "You have never been here before. You have never seen this house. But you feel like it knows you."
    p "Why did you come here? You heard the call."
    p "You heard the call and you answered."

    choice "Enter", :door
    choice "Flee!", :driveway
  end

  location :door do
    heading "The door"

    p "The door is not locked. It yields to your touch," \
      "swinging ajar by a few inches, revealing a tall slice of shadow."

    p "Reach for the handle. Quickly now, pull it closed. This door is not for opening." \
      "It is for holding back the cold dread, to keep it from leaking out into the world of" \
      "light and warmth and life."

    p "That is the world you leave behind you now, as you cross over the threshold."

    choice "Your fate is sealed. This story is over. Begin again", :threshold
  end

  location :driveway do
    heading "The Driveway"

    p "Your heels spin, your shoes tap down the stone steps and crunch over" \
      " the sparse gravel of the overgrown driveway."

    p "What might be stealing up behind you? A stripe of terror rises up your neck" \
      "and you bolt forwards, towards the gate, where you stop."

    p "The voice. There is the voice again. It calls you." \
      "You turn and walk towards the house."

    choice "Return to the door", :door
  end
end
