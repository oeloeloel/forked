<!-- This line is a comment. It is not displayed in the game so we can use it to leave helpful notes in the story file. -->
<!-- The next line is the story title. Your story must have a title and it must be the first line (not counting comments).
The `#` symbol at the start of the line tells Forked that this is the title.
The rest of the line `The Threshold` is the text of the title. -->
# The Threshold

<!-- Forked stories are divided into chunks and the next line tells Forked that we're starting a new chunk. This is called the Chunk Heading.
The `##` symbols tell Forked that this is a Chunk Heading.
The next part `The Threshold` is the text of the heading and will be displayed at the top of the screen.
If the text of the heading is left blank, Forked will display the story title instead (see the `peas.md` story for an example).
The last part `{theshold}`` is the Chunk ID, which we use to identify the chunk.
The Chunk ID is required for navigation but can be omitted in some cases. -->
## The Threshold {#threshold}

<!-- Now we're inside a chunk, we can write some text. -->
You have never been here before. You have never seen this house. But you feel like it knows you.

Why did you come here? You heard the call.

You heard the call and you answered.

<!-- The next line, beginning with `---`, draws a horizontal line in the display.
You can use these lines for any purpose but in this story we're using it to divide the content
of the chunk above from navigation options below. -->
---

<!-- These are buttons. The text between the square brackets `[Enter]` is the text that is displayed in the button.
The last part `(#door)` is a Chunk ID. Clicking this button will take the player to the chunk with the ID `#door`, which is the next chunk in this story file. -->
[Enter](#door)
<!-- This button navigates to the chunk with the ID `#driveway`, further down in this file. -->
[Flee](#driveway)

<!-- This chunk is now finished and the next line is another Chunk Heading, so Forked knows a new chunk is beginning. 
If the player clicked the `Enter` option in the previous chunk, they will come here. -->
## The Door {#door}
<!-- In Forked, paragraphs are separated by a blank line, which you can see with the three paragraphs below. -->
The door is not locked. It yields to your touch, swinging ajar by a few inches, revealing a tall slice of shadow.

Reach for the handle. Quickly now, pull it closed. This door is not for opening. It is for holding back the cold dread, to keep it from leaking out into the world of light and warmth and life.

That is the world you leave behind you now, as you cross over the threshold.

---
[Push the door](#foyer)

## The Driveway {#driveway}
<!-- In Forked, single new lines are ignored. Only blank lines will end a paragraph or start a new one. The text below is displayed as three paragraphs. -->
Your heels spin, your shoes
tap down the stone steps and
crunch over the sparse gravel
of the overgrown driveway.

What might be stealing up
behind you? A stripe of
terror rises up your neck and
you bolt forwards, towards
the gate, where you stop.

The voice. There is the voice
again. It calls you. You turn
and walk towards the house.

---
<!-- You can go back to any Chunk as many times as you like. Here we are going back to the `#door` Chunk, even though we have been there before. -->
[Return to the door](#door)

## The Darkness Ahead {#foyer}

Silence, as the door revolves around its hinges, compelled by your left hand as you step into the darkness. 

It would be fine to be somewhere else. Somewhere not here. There is a face, a child's face, a face you know, and it is gone. 

The room is too dark to see anything at all. Did you imagine it? You can only have imagined it. You remember the face from your past. Years ago. Back at school. It was the face of your friend. What was their name?

<!-- Instead of simply navigating to a new chunk, these buttons run some built-in actions.
Forked will remember the name the player selected.
It will also remember a pronoun to use with the selected name.
Finally, Forked will jump to the `#foyer2` chunk using the `jump` command. -->
[Viv](:
  memo_add "friend", "Viv"
  memo_add "friend_pronoun", "they"
  jump "#foyer2"
:)

[Ignatz](:
  memo_add "friend", "Ignatz"
  memo_add "friend_pronoun", "he"
  jump "#foyer2"
:)

[Rebekah](:
  memo_add "friend", "Rebekah"
  memo_add "friend_pronoun", "she"
  jump "#foyer2"
:)

[Constance](:
  memo_add "friend", "Constance"
  memo_add "friend_pronoun", "she"
  jump "#foyer2"
:)

[Jules](:
  memo_add "friend", "Jules"
  memo_add "friend_pronoun", "they"
  jump "#foyer2"
:)

[Jaswinder](:
  memo_add "friend", "Jaswinder"
  memo_add "friend_pronoun", "he"
  jump "#foyer2"
:)

---

<!-- We come to this chunk from the one above, where the player has just selected a name,
and Forked memorized the name and pronoun -->
## The Darkness Ahead {#foyer2}

<!-- The following text is treated as a single paragraph because there are no blank lines in it.
We can use the `<: :>` marks to put our saved names and pronouns into the text.
This is called String Interpolation. -->
Yes, you think that was the name.
<: (memo_check "friend") + "." :> <!-- inserts the name -->
It was so long ago. How can
<: memo_check "friend" :> <!-- inserts the name again -->
be here now? How can
<: memo_check "friend_pronoun" :> <!-- inserts the pronoun -->
be so young?

---
[Your fate is sealed. This story is over. Begin again](#threshold)
