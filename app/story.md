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
[Actions](#actions)
[Using Actions with Triggers](#actions_with_triggers)
[Blocks](#blocks)
[Alternative Text in Blocks]()
[Embedding Ruby Code]()
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

Finally, there is the Chunk ID {#start}. This identifies the chunk so Forked knows how to find it. It begins with a hash # followed by a unique name, without any spaces. It is wrapped in curly brackets, also known as braces {}.

[Next: Adding Text](#adding_text)
[Back: Story Chunks](#story_chunk)
[Contents](#contents)

## Adding Text {#adding_text}

Now that you have your heading line, you can start writing text underneath it.

```
## My Birth {#birth} 

My story begins on the day of my birth, though I do not remember much of that momentous occasion.

My mother has never discussed it with me. Being a typical crocodile of the West African species, she is not much for conversation.
```

In Forked, you write text in paragraphs separated by a blank line.

[Next: Triggers](#triggers)
[Back: Heading Lines](#heading_line)
[Contents](#contents)

## Triggers {#triggers}
To navigate between chunks, we can use Triggers.

```
[Learn more about my birth](#my_father)
[Let's get to the adventures!](#crocodile_hunters)
```

Triggers have two parts, the trigger text, which is surrounded by two square brackets [] and the trigger action, surrounded by two round brackets ().

Triggers are displayed as buttons labeled with the trigger text. You can see some trigger buttons at the bottom of the screen right now. 

Clicking a trigger button will perform its trigger action. In both the examples above, the action is a chunk_id and clicking the trigger will tell Forked to navigate to the specified chunk.

As well as navigating to other chunks, trigger actions can run Ruby code. We'll see more about that later.

If the trigger action is empty, Forked will display a non-clickable button like the next button below:
[This matter is now closed]()

[Next: Actions](#actions)
[Back: Adding Text](#adding_text)
[Contents](#contents)

## Actions {#actions}
Actions get things done. You can drop an action into a chunk like this:

```
^^^inventory_add "pith helmet" ^^^
```

The action `inventory_add` is a custom command that is included with Forked. If you're making an adventure game, the inventory will help you keep track of any items your player character posesses. In this case, we have added an attractive, yet sturdy, pith helmet to the player's inventory.

Actions are wrapped with three tick ` symbols on each side. 

When you drop an action into a chunk like this, it will run once, each time this chunk is loaded. That's the perfect time to add or remove an item to your inventory.

[Next: Using Actions with Triggers](#actions_with_triggers)
[Back: Triggers](#triggers)
[Contents](#contents)

## Using Actions with Triggers {#actions_with_triggers}
Sometimes you will want a trigger to perform some kind of action instead of navigating to another chunk.

```
Drop the weapon](^^^inventory_remove "dueling pistol"^^^)
```

You can combine an action with a trigger by replacing the chunk id with a command wrapped in backticks as in the example above.

In this case, the item "dueling pistol" will be removed from the player's inventory when the button is clicked.

[Next: Blocks](#blocks)
[Back: Actions](#actions)
[Contents](#contents)

## Blocks {#blocks}
Blocks group things together. Blocks begin and end with angle brackets < >, and they can contain paragraphs (one or more) or triggers, or both. 

In the example below, a block is used to combine an action with a paragraph to create text that only appears under certain conditions:

```
<^^^inventory_has? "dinghy"^^^ Leaving the submariners taking turns to fill the inflatable dinghy with air, I leaped from the boat in pursuit of my quarry.>
```

The paragraph above will only be shown if the player has acquired an inflatable dinghy along the way.

Blocks can contain multiple paragraphs as well as triggers.

```
<^^^inventory_has? "pistol"^^^ I touched the barrel of my dueling pistol to the tip of the archduke's nose.

[Pull the trigger and become a fugitive crocodile](#on_the_run)>
```

[Back: Using Actions with Triggers](#actions_with_triggers)
[Contents](#contents)

## Examples {#examples}

[Setting the Display Theme](#theme)

## Example: Setting the Display Theme {#theme}

Change the presentation of the story.

[Turn the lights off](^^^change_theme DARK_MODE ^^^)
[Turn the lights on](^^^change_theme nil ^^^)
[Turn the lights fun and stupid](^^^change_theme KIFASS_THEME^^^)
%
You can edit the display theme to change the colour scheme. Open the file `app/themes/dark-mode-theme.rb` and you can see how it's done.

[Back to Examples](#examples)
[Back to Contents](#contents)

## The TODO list (next release) {#todo}
For the next release
> TODO: Blocks
> TODO: Parser: Make code work again
> TODO: Parser: Inline styles (bold, italic, etc.).


Exceptions:

> User enters a ID link that does not correspond with an ID

[Next](#future)

## TODO list {#future}

For after the next release
> Actions go back to three backticks? Code block goes back to tildes? Code block with backticks in it becomes 4 backticks surrounding 3 backticks?
> TODO: Design: Inline links?
> TODO: Design: External links?
> TODO: Forked: Fall through if button has no link
> TODO: Forked: Refresh from file but retain current location in story IF POSSIBLE.
> TODO: ? Title screen if any content between Title and Root Chunk
> TODO: Parser/Display: Single newline ignored. Double newline is a paragraph. Single newline\ is line feed.

[New Newline Behaviour](#test_newline_change)

Something to think about: People want a title screen and they can have one. If the title is followed by a header, the header is the first chunk. If the title has content between, that's the first chunk. The title screen layout will be different (header lower down), everything centered?

Exceptions:
[TODO List](#todo)
[Welcome](#welcome)

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