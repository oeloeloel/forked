# Forked Tests

## About this file {#about}

This file is not a story, it's a set of tests to help with development of Forked.

[All tests](#tests)

## Tests { #tests }

[Heading with no Text](#no_heading_text)
[Preserved lines](#preserve)
[Comments](#comment)
[Blockquote](#blockquote)
[Paragraph Newlines](#newlines)
[Background Image](#background)
Warning: The next test test plays audio.
[Multiline Chunk Action](#multi_chunk_action)
[Multiline Ruby in trigger actions](#multi_trigger_action)
[Button Action](#button_action)
[Conditions: String Interpolation](#condition-string-interpolation)
[Code Block](#code-block)

## {#no_heading_text}

This is a test chunk with no text in the heading line.
It should display the story title "Forked Tests" above.

[All tests](#tests)

## Preserved Lines {#preserve}

The next line should display "#Title" (1)
%#Title (2)

The next line should display "## Chunk" (3)
% ## Chunk (4)

The next line should display "> Not a blockquote" (5)
% > Not a blockquote (6)

The next line should display three backticks (7)
% ``` (8/8)

[All tests](#tests)

## Comments {#comment}

The next line should display a comment without stripping it (1)
% > Don't ``` format # // me ## {} (2)

The next code block should display a comment without stripping it (3)
```
code block // comment (4)
```
The next line should not display a comment (5)

inline comment (6) // comment

The next line should not display. (7)
// line comment

The next line inside the blockquote should not display a comment (8)
> Comment follows -> (9/9) // comment

[All tests](#tests)

## Blockquote {#blockquote}

> Blockquote paragraph one. (1)
> Blockquote paragraph two. (2)
> Blockquote paragraph three. (3)
Not a blockquote. (4)
> Another blockquote (5)
A blank line here should prevent the next blockquote from latching onto the previous one.
> A third blockquote (6)

TODO: A blank line between blockquotes should end the blockquote. Currently it extends the blockquote.
[All tests](#tests)

## Newlines {#newlines}

This is a paragraph. It is followed by a blank line and it should be displayed with a blank space afterwards. (1)

This is the next paragraph, separated from the surrounding paragraphs by blank lines. It's a long paragraph that will wrap onto more than one line. In Forked, as in markdown, a single newline should not be displayed. If two lines in the story file are separated by a single newline, they will be displayed as one line, without any newlines. If there are two newlines - that is to say a complete line with no characters other than whitespace, Forked should interpret it as a paragraph break.(2)

This paragraph
is written
with two
words on
each line
without any
empty lines. (3)

This is the last paragraph. (4/4)

[All tests](#tests)

## Set background image {#background}

^^^
args.outputs.static_sprites << {
  x: 0, y: 0, w: 1280, h: 720,
  path: 'sprites/bg2.png',
  r: 198, g: 167, b: 205
}
^^^

[Back to Tests](^^^
args.outputs.static_sprites.clear
jump("#tests")
^^^)

## Multiline Chunk Actions {#multi_chunk_action}
This chunk does some simple math and putses a value.

Then it plays a cool sound.

^^^
var = 1
var += 1
putz var
^^^

^^^
args.audio[:success] = {
  input: "sounds/big-success.wav" 
}
^^^

[All tests](#tests)

## Multiline Ruby in trigger actions {#multi_trigger_action}

^^^
args.state.bg = {
  x: 0, y: 0, w: 1280, h: 720,
  path: 'sprites/bg2.png',
  r: 255, g: 255, b: 255
}
args.outputs.static_sprites << args.state.bg
^^^

[Change background colour](^^^
args.state.bg.r = rand(127) + 64
args.state.bg.g = rand(127) + 64
args.state.bg.b = rand(127) + 64
^^^)

[All Tests](^^^
args.outputs.static_sprites.clear
jump("#tests")
^^^)

## Button action {#button_action}

[This button should puts a message ONLY when clicked](^^^
putz "a message"
^^^)

[All tests](#tests)

## Conditions: String Interpolation {#condition-string-interpolation}

^^^
args.state.variable = "some text is inserted"
^^^

The following text was set in a variable. (1)

This paragraph starts...
<^^^
args.state.variable + ' ' + args.tick_count.to_s
^^^>
... and this is the end of the paragraph (2)

This is a new paragraph. (3/3)

[All tests](#tests)

## Code Block {#code-block}
Code block indentation
```
This is a code block
..
  This line is indented by 2 spaces
....
    This line is indented again
......
      This line is more indented
      This line has a             long space in it


      This line is preceeded by two blank lines
......
      This line is long and it will wrap around to the next line when it                          reaches the maximum allowed width. This line is long and it will wrap around to the next line when it reaches the maximum allowed width. This line is long and it will wrap around to the next line when it reaches the maximum allowed width. This line is long and it will wrap around to the next line when it reaches the maximum allowed width. This line is long and it will wrap around to the next line when it reaches the maximum allowed width. 
      
      # this is a nice short line
```
[All tests](#tests)