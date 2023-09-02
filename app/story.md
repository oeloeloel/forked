# Forked User Manual

## Welcome to Forked {#welcome}
Forked is a scripting system for DragonRuby that lets you write interactive stories, branching dialogues or anything else that requires writing and choices like, for example, this manual.

Forked is intended to be simple to pick up and easy for non-programmers to work with. For people who like to write code, it lets you focus on story-writing while giving you access to the full power of Ruby.

With Forked, you can learn how to write a simple interactive story in a few minutes.

---

[Next: Getting Started](#getting_started)

[Contents](#contents)

## Contents {#contents}

[Welcome to Forked](#welcome)
[Getting Started](#getting_started)
[Essentials](#essentials)
[Formatting](#formatting)
[Actions and Conditions](#actions)
[Built-in Commands](#commands)
[Examples](#examples)

## Getting Started {#getting_started}

First things first. You need DragonRuby Game Toolkit to use Forked:

[Get DragonRuby](#dragonruby)

Then you can install Forked:

[Install and Run Forked](#installation)

Now you can run Forked and start writing your story.

[Start Writing](#write)

---

[Next: Essentials](#essentials)  
[Back: Welcome to Forked](#welcome)  
[Contents](#contents)


## DragonRuby Game Toolkit {#dragonruby}

If you're reading this, you probably already own DragonRuby and you probably also have it installed and working.

If not, you can find more information about DragonRuby at https://dragonruby.itch.io/dragonruby-gtk.

Be sure to visit the DragonRuby Discord for help or just to hang out with the super-friendly community: http://discord.dragonruby.org.

---
[Back: Getting Started](#getting_started)

## Installation {#installation}
To install Forked, you should start with a freshly unzipped DragonRuby project.

Download the Forked project from GitHub and move the files into your DragonRuby project.

Copy/paste or drag the `Forked` folder into the `mygame/app` folder. Copy or drag the file `main.rb` into `mygame/app` and let it overwrite the existing file.

Now run DragonRuby: double-click on the DragonRuby executable (`dragonruby.exe` on windows, `dragonruby` on macOS or Linux).

By default, Forked will open this manual to help you get started. Since you're already reading this manual, congratulations on a job well done.

---
[Back: Getting Started](#getting_started)

## Writing and Editing the Story {#write}

Open up the `app/story.md` file in any text editor and you'll see the contents of this manual. When you look at the examples, you'll also be able to see the code that created them.

When you want to start a new story, create a new file in the `app` folder and call it whatever you want.

Open the `main.rb` file and look for a line near the top that says

~~~
STORY_FILE = 'app/story.md'
~~~

Change `story.md` to whatever you named your file.

Then you can start writing your story:

---

[Back: Getting Started](#getting_started)

## Essentials {#essentials}

There are only a few things you really need to know to write a branching story with Forked.

[Set The Story Title](#story_title)
[Divide the Story into Chunks](#story_chunk)
[Give Each Chunk a Heading](#heading_line)
[Add Some Text](#adding_text)
[Link Chunks to Each Other with Triggers](#triggers)

Once you've covered that, you can write a simple branching story and share it with the world.

---
[Next: Formatting](#formatting)
[Back: Getting Started](#getting_started)
[Contents](#contents)

## The Story Title {#story_title}
Every story needs a title and, in Forked, they are written like this:

~~~
# Gentleman, Adventurer, Amphibian: A Memoir
~~~

The title begins with a hash (also know as a pound) symbol `#` followed by the text of the title.

You can have only one title in your story file and it should be at the top.

That's all for titles.

---
[Next: Story Chunks](#story_chunk)
[Back to Essentials](#essentials)

## Story Chunks {#story_chunk}
In Forked, stories are divided into sections called chunks. All the text you can see in this window is one chunk of the story.

With Forked, you can easily link chunks together so the player can click a button and go to a different chunk. You've already seen this happening.

And you'll see it happen again when you click one of the buttons below.

---
[Next: The Heading Line](#heading_line)
[Back: The Story Title](#story_title)
[Back to Essentials](#essentials)

## Heading Lines {#heading_line}
The first line of a chunk is the heading line. It's what lets Forked know that a new chunk is beginning.

~~~
## The Day I Was Born {#birth}
~~~

The heading line begins with two hash symbols ##. 

Next is the text of the heading (The Day I Was Born). This will be shown at the top of the screen when the chunk is displayed. This text is optional and if it is left out, Forked will show the story title instead.

Finally, there is the Chunk ID {#birth}. This identifies the chunk so Forked knows how to find it. It begins with a hash # followed by a unique name, without any spaces. It is wrapped in curly brackets, also known as braces {}.

---
[Next: Adding Text](#adding_text)
[Back: Story Chunks](#story_chunk)
[Back to Essentials](#essentials)

## Adding Text {#adding_text}

Now that you have your heading line, you can start writing text underneath it.

~~~
## The Day I Was Born {#birth} 

My story begins on the day of my birth, though I do not remember much of that occasion.

My mother has never discussed it with me. Being a typical crocodile of the West African species, she is not much for conversation.
~~~

In Forked, you write text in paragraphs separated by a blank line.

---
[Next: Triggers](#triggers)
[Back: Heading Lines](#heading_line)
[Back to Essentials](#essentials)

## Triggers {#triggers}
To allow the player to move from one chunk to another, we can use Triggers.

~~~
[Learn more about my birth](#crocodile_parenting)
[Let's get to the adventures!](#crocodile_hunters)
~~~

Triggers have two parts, the trigger text, which is surrounded by two square brackets [] and the trigger action, surrounded by two round brackets ().

Triggers are displayed as buttons labeled with the trigger text. You can see some trigger buttons at the bottom of the screen right now. 

Clicking a trigger button will perform its trigger action. In both the examples above, the action is a chunk_id and clicking the trigger will tell Forked to navigate to the specified chunk.

As well as navigating to other chunks, trigger actions can run Ruby code. We'll see more about that later.

If the trigger action is empty, Forked will display a non-clickable button like the next button below:
[This matter is now closed]()

---
[Back: Adding Text](#adding_text)
[Back to Essentials](#essentials)

## Formatting {#formatting}

Now that you know how to write a story, we can do a few things about the way it looks.

Simple formatting:
[Blockquotes](#blockquotes)
[Code Blocks](#code-blocks)
[Horizontal Rules](#rules)

Related: For more advanced formatting:
[Themes]()

Expect to see more formatting options added in future.

---
[Next: Actions](#actions)
[Back: Essentials](#essentials)
[Contents](#contents)

## Blockquotes {#blockquotes}
Blockquotes put your text in a box:
> The Maharajah's Star is a diamond of great reknown.

To make a blockquote, start the line with a right angle bracket >
~~~
> The Maharajah's Star is a diamond of great reknown.
~~~

If you put several blockquotes one after the other, they appear as a single blockquote:
~~~
> Many people have tried to steal it over the centuries.
> All of them perished.
> Horribly.
~~~

> Many people have tried to steal it over the centuries.
> All of them perished.
> Horribly.

---
[Back to Formatting](#formatting)

## Code Blocks {#code-blocks}
Code blocks, as you have already seen in this manual, are used to show code:
~~~
bag_add "The Maharajah's Star"
~~~

Code blocks start and end with three tildes ~
~~~
\~~~
  bag_add "The Maharajah's Star"
\~~~
~~~

Code blocks present text 'as-is', without any formatting changes except for wrapping long lines.

Not every story will need to have code blocks. It's super-useful for manuals though.

---
[Back to Formatting](#formatting)

## Horizontal Rules {#rules}
You can draw a horizontal line anywhere in your story like this one:

---

To draw a line you just put three dashes (also known as hyphens) `-` at the start of a line:
~~~
---
~~~

This manual uses horizontal rules to separate the content from the navigational buttons at the bottom of each chunk, but you can use them wherever you like. You can also use as many as you like:

---
---
---

---
[Back to Formatting](#formatting)

## Themes {#themes}

## Actions and Conditions {#actions}
Actions get things done. They are short pieces of code that you can put directly into your story to perform some common tasks. You can use actions to tell Forked to do something, remember something, count something, time something, roll dice, go to another chunk, and other things besides.

There are three ways to use actions. Chunk Actions perform tasks when the chunk gets displaye like, for example, adding an item to the inventory. Trigger actions make something happen when a player clicks a button like, for example, remembering a choice. Conditions  make decisions like which text to display or which buttons should be visible.

[Chunk Actions](#chunk-actions)

[Trigger Actions](#trigger-actions)

[Conditions](#conditions-1)
Related: Forked includes a number of useful commands you can use with actions.
[Built-in Commands](#commands)

---
[Next: Commands](#commands)
[Back: Formatting](#formatting)
[Contents](#contents)

## Chunk Actions {#chunk-actions}

You can drop an action into a chunk like this:

~~~
:: bag_add "pith helmet" ::
~~~
Chunk Actions begin and end with a pair of colon `:` symbols. Between the symbols, you can issue commands.

In this case, we are telling Forked to add a sturdy, yet attractive, "pith helmet" to the player's "bag" or inventory. Forked comes with some useful commands included, including the ability to store and retrieve items from an inventory. More about custom commands later.

When you drop an action into a chunk like this, it will run once, each time this chunk is loaded. That's the perfect time to add an item to, or remove an item from, your bag.

You can put commands on multiple lines, like this:
~~~
::
  bag_add "pith helmet"
  bag_remove "top hat"
::
~~~
---
[Next: Trigger Actions](#trigger-actions)
[Back to Actions](#actions)

## Trigger Actions {#trigger-actions}

Sometimes you will want a trigger to perform some kind of action instead of navigating to another chunk.

~~~
[Drop the weapon](: bag_remove "dueling pistol" :)
~~~

You can combine an action with a trigger by adding the colons above and replacing the chunk id with a command.

In this case, the item "dueling pistol" will be removed from the player's bag when the button is clicked.

You can put commands on multiple lines:
~~~
[Drop the weapon](:
  bag_remove "dueling pistol"
  jump "#surrender"
:)
~~~
The `jump` command lets you navigate to another chunk from a trigger action.
---
[Next: Conditional Text](#conditions-1)
[Back: Chunk Actions](#chunk-actions)
[Back to Actions](#actions)

## Conditional Text Part 1 {#conditions-1}
Sometimes you may want to show, hide or change text depending on the situation. Forked gives you a couple of ways to do this. The first lets you insert words or short pieces of text into the story.
~~~
Any fool knows that 
<:
  memo_check "dauphine_fave_color"
:> 
is the Dauphine's favourite colour!
~~~

One of the useful tools included with Forked is `memo` and it lets you remember and recall pieces of text like, for example, a character's favourite colour. If the dauphine's favourite color is "Moroccan pink", the following text will be added into the story:

> Any fool knows that Moroccan pink is the Dauphine's favourite colour!

We'll learn more about `memo` and other included commands later.

---
[Next: Conditions Part 2](#conditions-2)
[Back: Trigger Actions](#trigger-actions)
[Back to Actions](#actions)

## Conditional Text Part 2 {#conditions-2}
In the previous chunk, we saw how short text can be inserted into the story. For longer texts as well as triggers and blockquotes, we can write them out and use conditions to decide if they should be displayed.

~~~
But how would I travel to Europe?
<:
  bag_has? "submarine"
::
  Of course! The Maharajah's gift! I could travel to Europe by submarine.

  [Travel to Europe by Submarine](#submarine)
:>
~~~

In the example above, if the player does not have a submarine in their bag, they will see only the line:
> But how would I travel to Europe?

But if they have the submarine, they see more text:

> But how would I travel to Europe? Of course! The Maharajah's gift! I could travel to Europe by submarine.

They will also see a nice new button to help them start their under-sea voyage.

---
[Back: Conditions Part 1](#conditions-1)
[Back to Actions](#actions)

## Built-in Commands {#commands}
Forked contains some built-in commands to help you perform some useful or common tasks.

[Commands: Bag (Inventory Management)](#bag)
[Commands: Memo (Information Storage)](#memo)
[Commands: Timer (Countdown Timers)](#timer)
[Commands: Counter (Number Tracking)](#counter)

---
[Next: Examples](#examples)
[Back: Actions](#actions)
[Contents](#contents)

## Commands: Bag (Inventory Management) {#bag}

The `bag` is where you keep track of the things your player collects during the game. For example, they may pick up a parcel of exotic spices to transport to Europe via submarine. You can add items to the bag like this:

~~~
bag_add "exotic spices"
~~~

Remove items:

~~~
bag_remove "exotic spices"
~~~

And check to see if the player has an item:
~~~
bag_has? "exotic spices"
~~~

If your player is involved in a dramatic shipwreck, they might lose the exotic spices along with everything else in their inventory. You can empty out the bag like this:

~~~
bag_clear
~~~

---
[Back to Commands](#commands)

## Commands: Memo (Information Storage) {#memo}

`memo` is for remembering information like, did the player meet the person of their dreams and fall in love? Did they run away from the evil pastry chef or stand their ground and fight? To remember something:

~~~
memo_add "in love with", "the Dauphine"
~~~

To check a memo:

~~~
memo_check "in love with"
~~~

To forget:

~~~
memo_remove "in love with"
~~~

If your player is hit on the head by a Montgolfier balloon and suffers from total amnesia, this is how to forget everything:
~~~
memo_clear
~~~

---
[Back to Commands](#commands)

## Commands: Timer (Countdown Timers) {#timer}

`timer` lets you create a countdown timer. You can check the timer to see if it's done and perform some other action if it is. For example, your player may only have a few seconds to defuse the saboteur's bomb and save the submarine crew:

~~~
timer_add "submarine explosion", 6.seconds"
~~~

To know if a timer has finished and the crew are lost:
~~~
timer_done? "submarine explosion"
~~~

To check how much time is left:

~~~
timer_check "submarine explosion"
~~~

To remove a timer:

~~~
timer_remove "submarine explosion"
~~~

---
[Back to Commands](#commands)

## Commands: Counters (Number Tracking) {#counter}

`counter` helps you keep track of the number of times something happens. It may be important in your story that the player gains five exquisite Persian rugs by winning games of croquet. To create a new counter:

~~~
counter_add "number of rugs", 0
~~~
To remove a counter:

~~~
counter_remove "number of rugs"
~~~

To increase or decrease a counter:
~~~
counter_up "number of rugs", 1
counter_down "number of rugs", 2
~~~

And to check how many rugs the player has:

~~~
counter_check "number of rugs"
~~~

---
[Back to Commands](#commands)


## Examples {#examples}

[Setting the Display Theme](#theme)
[Countdown Timer](#example-timer)

---
[Back: Built-in Commands](#commands)
[Contents](#contents)

## Example: Setting the Display Theme {#theme}

Change the presentation of the story.

[Turn the lights on](: change_theme nil :)
[Turn the lights off](: change_theme DARK_MODE :)
[Turn the lights fun and stupid](: change_theme KIFASS_THEME :)

You can edit the display theme to change the colour scheme. Open the file `app/themes/dark-mode-theme.rb` and you can see how it's done.

---
[Back to Examples](#examples)
[Back to Contents](#contents)

## Countdown Timer {#example-timer}
::
  timer_add "oxygen", 11.seconds
::

Warning: space suit rupture detected.

<: 
  "Oxygen remaining: #{timer_seconds "oxygen"}"
:>

<:
  timer_done? "oxygen"
::
  You ran out of oxygen and you are feeling poorly.
:>

---
[Back to Examples](#examples)
[Back to Contents](#contents)