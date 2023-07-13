# Forked User Manual

## Welcome to Forked {#welcome}
Forked is a scripting system for DragonRuby that lets you write interactive stories, branching dialogues or anything else that requires writing and choices like, for example, this manual.

Forked is intended to be simple to pick up and easy for non-programmers to work with. For people who code, it offers a space for writing with fewer distractions combined with the ability to call on the full power of Ruby.

With Forked, you can learn how to write a simple interactive story in a few minutes.

[Next: Getting Started](#getting_started)

[Contents](#contents)

## Contents {#contents}

[Welcome to Forked](#welcome)
[Getting Started](#getting_started)
[The Story Title](#story_title)
[Story Chunks](#story_chunk)
[Heading Lines](#heading_line)
[Adding Text](#adding_text)
[Triggers](#triggers)
[Formatting](#formatting)
[Actions](#actions)
[Using Actions with Triggers](#actions_with_triggers)
[Conditional Text](#blocks)
[Examples](#examples)

## Getting Started {#getting_started}

First things first: You need DragonRuby Game Toolkit to use Forked.

[DragonRuby](#dragonruby)

Open up the story.md file in any text editor and you'll see the contents of this manual. When you look at the examples, you'll also be able to see the code that created them.

When you want to start a new story, create a new file in the 'app' folder and call it whatever you want.

Open the tick.rb file and look for a line near the top that says

```
STORY_FILE = 'app/story.md'
```

Change 'story.md' to whatever you named your file.

Then you can start writing your story.

[Next: The Story Title](#story_title)  
[Back: Welcome to Forked](#welcome)  
[Contents](#contents)

## DragonRuby Game Toolkit {#dragonruby}

If you're reading this, you probably already own DragonRuby and you probably also have it installed and working.

If not, you can find more information about DragonRuby at https://dragonruby.itch.io/dragonruby-gtk.

Be sure to visit the DragonRuby Discord for help or just to hang out with the super-friendly community: http://discord.dragonruby.org.

[Back: Getting Started](#getting_started)

## The Story Title {#story_title}
Every story needs a title and, in Forked, they are written like this:

```
# Gentleman, Adventurer, Amphibian: A Memoir
```

The title begins with a hash or pound symbol # followed by the text of the title.

You can have only one title in your story file and it should be at the top.

That's all for titles.

[Next: Story Chunks](#story_chunk)
[Back: Getting Started](#getting_started)
[Contents](#contents)

## Story Chunks {#story_chunk}
In Forked, stories are divided into sections called chunks. All the text you can see in this window is one chunk of the story.

With Forked, you can easily link chunks together so that the player can click a button and go to a different chunk. You've already seen this happening.

And you'll see it happen again when you click one of the buttons below.

[Next: The Heading Line](#heading_line)
[Back: The Story Title](#story_title)
[Contents](#contents)

## Heading Lines {#heading_line}
The first line of a chunk is the heading line. It's what lets Forked know that a new chunk is beginning.

```
## My Birth {#birth}
```

The heading line begins with two hash symbols ##. 

Next is the text of the heading (My Birth). This will be shown at the top of the screen when the chunk is displayed. This text is optional and if it is left out, Forked will show the story title instead.

Finally, there is the Chunk ID {#birth}. This identifies the chunk so Forked knows how to find it. It begins with a hash # followed by a unique name, without any spaces. It is wrapped in curly brackets, also known as braces {}.

[Next: Adding Text](#adding_text)
[Back: Story Chunks](#story_chunk)
[Contents](#contents)

## Adding Text {#adding_text}

Now that you have your heading line, you can start writing text underneath it.

```
## My Birth {#birth} 

My story begins on the day of my birth, though I do not remember much of that occasion.

My mother has never discussed it with me. Being a typical crocodile of the West African species, she is not much for conversation.
```

In Forked, you write text in paragraphs separated by a blank line.

[Next: Triggers](#triggers)
[Back: Heading Lines](#heading_line)
[Contents](#contents)

## Triggers {#triggers}
To allow the player to move from one chunk to another, we can use Triggers.

```
[Learn more about my birth](#crocodile_parenting)
[Let's get to the adventures!](#crocodile_hunters)
```

Triggers have two parts, the trigger text, which is surrounded by two square brackets [] and the trigger action, surrounded by two round brackets ().

Triggers are displayed as buttons labeled with the trigger text. You can see some trigger buttons at the bottom of the screen right now. 

Clicking a trigger button will perform its trigger action. In both the examples above, the action is a chunk_id and clicking the trigger will tell Forked to navigate to the specified chunk.

As well as navigating to other chunks, trigger actions can run Ruby code. We'll see more about that later.

If the trigger action is empty, Forked will display a non-clickable button like the next button below:
[This matter is now closed]()

[Next: Formatting](#formatting)
[Back: Adding Text](#adding_text)
[Contents](#contents)

## Formatting {#formatting}

Now that you know how to write a story, we can do a few things about the way it looks.

Simple formatting:
[Blockquotes](#blockquotes)
[Code Blocks](#code-blocks)

For more advanced presentations:
[Themes]()

Expect to see more formatting options added in future.

[Next: Actions](#actions)
[Back: Adding Text](#adding_text)
[Contents](#contents)

## Blockquotes {#blockquotes}
Blockquotes put your text in a box:
> The Maharajah's Star is a diamond of great reknown.

To make a blockquote, start the line with a right angle bracket >
```
> The Maharajah's Star is a diamond of great reknown.
```

If you put several blockquotes one after the other, they appear as a single blockquote:
```
> Many people have tried to steal it over the centuries.
> All of them perished.
> Horribly.
```

> Many people have tried to steal it over the centuries.
> All of them perished.
> Horribly.

[Back to Formatting](#formatting)

## Code Blocks {#code-blocks}
Code blocks, as you have already seen in this manual, are used to show code:
```
inventory_add "The Maharajah's Star"
```

Code blocks start and end with three backticks `
```
\```
  inventory_add "The Maharajah's Star"
\```
```

Code blocks present text 'as-is', without any formatting changes except for wrapping long lines.

Not every story will need to have code blocks. It's super-useful for manuals though.

[Back to Formatting](#formatting)

## Themes {#themes}

## Actions {#actions}
Actions get things done. You can drop an action into a chunk like this:

```
^^^
inventory_add "pith helmet"
^^^
```
Actions begin and end with three caret ^ symbols on the line above and another three carets on the line below. On the lines in-between, you can issue commands.

In this case, we are telling Forked to add a sturdy, yet attractive, "pith helmet" to the player's inventory. Forked comes with some useful commands added, including the ability to store and retrieve items from an inventory. More about custom commands later.

When you drop an action into a chunk like this, it will run once, each time this chunk is loaded. That's the perfect time to add or remove an item to your inventory.

[Next: Using Actions with Triggers](#actions_with_triggers)
[Back: Triggers](#triggers)
[Contents](#contents)

## Using Actions with Triggers {#actions_with_triggers}
Sometimes you will want a trigger to perform some kind of action instead of navigating to another chunk.

```
Drop the weapon](^^^
inventory_remove "dueling pistol"
^^^)
```

You can combine an action with a trigger by replacing the chunk id with a command wrapped in carets as in the example above. The carets must be on the line above and the line below the action.

In this case, the item "dueling pistol" will be removed from the player's inventory when the button is clicked.

[Next: Conditional Text](#conditions)
[Back: Actions](#actions)
[Contents](#contents)

## Conditional Text {#blocks}
Sometimes you may want to show, hide or change text depending on the situation.
```
The crew of the submarine threw themselves into the sea and proceeded to <^^^
    inventory_has? "dinghy" ? "row for shore." : "drown."
^^^>
```
In this example, if the player's inventory contains a "dinghy", the result will be:
> The crew of the submarine threw themselves into the sea and proceeded to row for shore.

If the player does not have a "dinghy" by this time, let us bow our heads and say a prayer for those poor, brave submariners.

[Back: Using Actions with Triggers](#actions_with_triggers)
[Contents](#contents)

## Examples {#examples}

[Setting the Display Theme](#theme)
[Countdown Timer](#timer)

## Example: Setting the Display Theme {#theme}

Change the presentation of the story.

[Turn the lights on](^^^
change_theme nil
^^^)
[Turn the lights off](^^^
change_theme DARK_MODE
^^^)
[Turn the lights fun and stupid](^^^
change_theme KIFASS_THEME
^^^)
%
You can edit the display theme to change the colour scheme. Open the file `app/themes/dark-mode-theme.rb` and you can see how it's done.

[Back to Examples](#examples)
[Back to Contents](#contents)

## Countdown Timer {#timer}
^^^
args.state.countdown_timer = 11.seconds
^^^
Warning: space suit rupture detected.
<^^^
  message = "Oxygen remaining "
  message += args.state.countdown_timer.idiv(60).to_s
  args.state.countdown_timer -= 1
  
  if args.state.countdown_timer <= 1
    message = "You ran out of oxygen and you are feeling poorly."
  end

  return message
^^^>

[Contents](#contents)