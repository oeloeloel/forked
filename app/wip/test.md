# Forked Tests

## New Code Block {#code-block-v2}

~~~
fenced code block now uses 3 tildes
~~~
A valid multiline action begins and ends with 3 backticks, alone on a line with no other non-whitespace characters.
~~~
```
# it looks like this
def tick args
  putz "amazing"
end
```
~~~

[All tests](#tests)

## executable code {#executable}
//```
This line is surrounded by backticks that have been commented and should be visible.
//```

<!-- ``` -->
putz "this line is generating a visual code block but it should not"
<!-- ``` -->

if a line contains but doesn't start with ```, it's not code

``` if a line starts with 3 backticks and ends with 3 backticks, it's inline code```

``` if a line starts with 3 bts but doesn't end with 3bts, the rest of the line is discarded
# if a line starts with 3 bts but doesn't end with 3bts, the rest of the line is discarded. But the following lines are code
```

``` if a line starts with 3bts ``` and contains another 3bts but doesn't end with 3bts, it's inline code.

If a line doesn't start or end with 3bts ``` but contains a span wrapped with 3bts ```, it's inline code

```
# A code block where the closing 3bts are not the first thing on their line
# hello ```
The closing bts are ignored.
```

```
# A code block where the closing 3bts are followed by text
``` and this is extra
```

   ```
   # code block
   # code block
   ```

So. Rules:
If a line contains two sets of 3bts, treat as inline (same as 1bts).

In every other case, the 3bts must be the only non whitespace character on their line to be considered opening or closing code fences. Otherwise, they are treated as paragraph text.

If the opening 3bts are indented more than 0 but less than 4 characters, the code block will have an equal number of spaces removed from the left of each line (until there are 0)

^^^ 
putz "this doesn't do anything" 
^^^
```
putz "this is an executable code block"
```

<!-- //<``` -->
<!-- //putz "this is a conditional code block" -->
<!-- //```> -->

[button](```
putz "this is trigger action code block"
```)

## About this file {#about}

This file is not a story, it's a set of tests to help with development of Forked.

[All tests](#tests)

## Tests { #tests }

[Heading with no Text](#no_heading_text)
[Comments](#comment)
[Blockquote](#blockquote)
[Newlines](#newlines)
[Background Image](#background)
Warning: The next test test plays audio.
[Multiline Chunk Action](#multi_chunk_action)
[Multiline Ruby in trigger actions](#multi_trigger_action)
[Button Action](#button_action)
[Code Block](#code-block)
[Code Block v2](#code-block-v2)
[Contexts](#contexts)
[Conditions](#conditions)

## Newlines {#newlines}
[Paragraph Newlines](#paragraph-newlines)
[Hard Wrap](#hard-wrap)
//
[All tests](#tests)

## Conditions {#conditions}
[Conditions: String Interpolation](#condition-string-interpolation)
[Condition without paragraph](#background-image)

[All tests](#tests)

## {#no_heading_text}

This is a test chunk with no text in the heading line.
It should display the story title "Forked Tests" above.

[All tests](#tests)

## Comments {#comment}

The next code block should display a comment without stripping it (1)
~~~
code block // comment (2)
~~~
The next line should not display a comment (3)

inline comment (4) // comment

The next line should not display (5)
// line comment

The next line inside the blockquote should not display a comment (6)
> Comment follows -> (7/7) // comment

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

## Paragraph Newlines {#paragraph-newlines}

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

[Back to newlines](#newlines)

## Set background image {#background}

```
putz "This should print"
args.outputs.static_sprites << {
  x: 0, y: 0, w: 1280, h: 720,
  path: 'sprites/bg2.png',
  r: 198, g: 167, b: 205
}
```

[Back to Tests](```
args.outputs.static_sprites.clear
jump("#tests")
```)

## Multiline Chunk Actions {#multi_chunk_action}
This chunk does some simple math and putses a value.

Then it plays a cool sound.

```
var = 1
var += 1
putz var
```

```
args.audio[:success] = {
  input: "sounds/big-success.wav" 
}
```

[All tests](#tests)

## Multiline Ruby in trigger actions {#multi_trigger_action}

```
args.state.bg = {
  x: 0, y: 0, w: 1280, h: 720,
  path: 'sprites/bg2.png',
  r: 255, g: 255, b: 255
}
args.outputs.static_sprites << args.state.bg
```

[Change background colour](```
args.state.bg.r = rand(127) + 64
args.state.bg.g = rand(127) + 64
args.state.bg.b = rand(127) + 64
```)

[All Tests](```
args.outputs.static_sprites.clear
jump("#tests")
```)

## Button action {#button_action}

[This button should puts a message ONLY when clicked](```
putz "a message"
```)

[All tests](#tests)

## Conditions: String Interpolation {#condition-string-interpolation}

```
args.state.variable = "some text is inserted"
```

The following text was set in a variable. (1)

This paragraph starts...
<%```
args.state.variable + ' ' + args.tick_count.to_s
```%>
... and this is the end of the paragraph (2)

This is a new paragraph. (3/3)

[Back to Conditions](#conditions)

## Code Block {#code-block}
Code block indentation
~~~
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
~~~
[All tests](#tests)

## Contexts {#contexts}
[Code block context](#code-block-context)
[Blockquote context part 1](#blockquote-context-1)
[Blockquote context part 2](#blockquote-context-2)
[All tests](#tests)

## Things that shouldn't be inside a code block {#code-block-context}

~~~
Code block
> Block quote shouldn't be inside a code block

```
multiline action shouldn't be inside a code block
```

# Title shouldn't be inside a code block

## Heading shouldn't be inside a code block

Comment // shouldn't be inside a code block

[Trigger shouldn't be inside a code block](#action)

<%
Condition shouldn't be inside a code block
%>

~~~

[Back to Contexts](#contexts)
[All tests](#tests)

## Things that shouldn't be inside a blockquote Part 1 {#blockquote-context-1}

> ~~~
> code block shouldn't be inside a blockquote (yet?)
> ~~~
> > Blockquote shouldn't be inside a blockquote (yet)
> <%```
> condition shouldn't be inside a blockquote (yet)
> ```%>
> ```
> action block shouldn't be inside a blockquote (yet)
> ```

[Back to Contexts](#contexts)
[All tests](#tests)


## Things that shouldn't be inside a blockquote Part 2 {#blockquote-context-2}

> [Trigger shouldn't be inside a Blockquote](#yet)
> # Title shouldn't be inside a blockquote
> ## Heading shouldn't be inside a blockquote
> Comments // should be removed from a blockquote

[Back to Contexts](#contexts)
[All tests](#tests)

## Hard Wrap {#hard-wrap}
If a line\
Ends with a backslash\
Add a newline\
And continue\
The same\
Paragraph. (1)

Normal separation of paragraphs is not affected. (2)

Normal removal of single newlines
is not affected. (3/3)

[Back to Newlines](#newlines)

## Condition without paragraph {#background-image}
> The following condition block should start a new paragraph. It is working if the background of this chunk is a white image.
<%```
background_image "sprites/bg2.png"
```%>
[Back to Conditions](#conditions)
