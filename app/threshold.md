# The Threshold


## The Threshold {#threshold}

You have never been here before. You have never seen this house. But you feel like it knows you.

Why did you come here? You heard the call.

You heard the call and you answered.

[Enter](#door)
[Flee](#driveway)

## The Door {#door}

The door is not locked. It yields to your touch, swinging ajar by a few inches, revealing a tall slice of shadow.

Reach for the handle. Quickly now, pull it closed. This door is not for opening. It is for holding back the cold dread, to keep it from leaking out into the world of light and warmth and life.

That is the world you leave behind you now, as you cross over the threshold.

[Push the door](#foyer)

## The Driveway {#driveway}

Your heels spin, your shoes tap down the stone steps and crunch over the sparse gravel of the overgrown driveway. 

What might be stealing up behind you? A stripe of terror rises up your neck and you bolt forwards, towards the gate, where you stop. 

The voice. There is the voice again. It calls you. You turn and walk towards the house.

[Return to the door](#door)

## The Darkness Ahead {#foyer}

Silence, as the door revolves around its hinges, compelled by your left hand as you step into the darkness. 

It would be fine to be somewhere else. Somewhere not here. There is a face, a child's face, a face you know, and it is gone. 

The room is too dark to see anything at all. Did you imagine it? You can only have imagined it. You remember the face from your past. Years ago. Back at school. It was the face of your friend. What was their name?

[Viv](^^^
memo_add "friend", "Viv"
memo_add "friend_pronoun", "they"
jump("#foyer2")
^^^)
[Ignatz](^^^
memo_add "friend", "Ignatz"
memo_add "friend_pronoun", "he"
jump("#foyer2")
^^^)
[Rebekah](^^^
memo_add "friend", "Rebekah"
memo_add "friend_pronoun", "she"
jump("#foyer2")
^^^)
[Constance](^^^
memo_add "friend", "Constance"
memo_add "friend_pronoun", "she"
jump("#foyer2")
^^^)
[Jules](^^^
memo_add "friend", "Jules"
memo_add "friend_pronoun", "they"
jump("#foyer2")
^^^)

## The Darkness Ahead {#foyer2}

Yes, you think that was their name.
<^^^
(memo_check "friend") + "."
^^^>
It was so long ago. How can
<^^^
memo_check "friend"
^^^>
be here now? How can
<^^^
memo_check "friend_pronoun"
^^^>
be so young?

[Your fate is sealed. This story is over. Begin again](#threshold)
