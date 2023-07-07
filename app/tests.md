# Forked Tests

## About this file{#about}

This file is not a story, it's a set of tests to help with development of Forked.

It's probably not interesting for most people.

[Do a thing](^^^
  putz "oorawooraloolamoolafoola"
^^^)
[The tests](#test)

## Set background image {#background}

^^^
args.outputs.static_sprites << {
  x: 0, y: 0, w: 1280, h: 720,
  path: 'sprites/bg2.png',
  r: 198, g: 167, b: 205
}
^^^

[Back to Tests](#test)

## New Newline Behaviour {#test_newline_change}
For paragraphs, one newline is ignored (added to previous with one space). Two newlines marks a new paragraph.

For every other element, is it case by case?

Code blocks should be as-is, without any fucking around. Need to think through every element (current and planned behaviour) and decide if the newline changes should be applied at the element level or before it gets there (code blocks excluded.)

This is the first paragraph.
This text should be displayed on the first paragraph.

This is the second paragraph.\
This text should be displayed in the second paragraph but with a newline before it. The backslash should not be displayed.

[This link](#test) should be on the same line as 
[This other link](#test).

[This link](#test) should be separated by a newline from\
[this other link](#test).

[This link](#test) should be separated by a paragraph from

[This link](#test).

## Test {#test}

[Test Preserved lines](#test_preserve)
[Test Comments](#test_comment)
[Test Heading with no Text](#no_heading_text_test)

[Test Multiline Chunk Action](#multi_chunk_action)

## Test Preserved Lines {#test_preserve}
[Back to Test](#test)

The next line should display "#Title"
%#Title

The next line should display "## Chunk"
% ## Chunk

The next line should display "> Not a blockquote"
% > Not a blockquote

The next line should display three backticks
% ```

## Test Comments {#test_comment}

The next line should display a comment without stripping it
% > Don't ``` format # // me ## {}

The next code block should display a comment without stripping it
```
code block // comment
```
The next line should not display a comment
inline comment // comment

The next line should not display.
// line comment

The next line should not display a comment
> Comment follows -> // comment

[Back to Test](#test)

## {#no_heading_text_test}

This is a test chunk with no text in the heading line.
It should display the story title instead.

[Back to Test](#test)

## No chunk ID test

This is a test chunk with no chunk ID.
We should not be able to navigate directly to this chunk but it should not cause the parser to fail.

In future, if a button does not specify a target, Forked will fall through to the heading immediately below it in the file, so this chunk will eventually be reachable.

[Back to Test](#test)

## Multiline Chunk Actions {#multi_chunk_action}

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

[Back to Test](#test)