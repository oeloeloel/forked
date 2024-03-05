# Forked User Manual

An interactive version of this manual is included with Forked as the default project. It will be displayed when you run Forked for the first time.

## Contents

[Welcome to Forked](#welcome-to-forked)\
[Getting Started](#getting-started)\
[Essentials](#essentials)\
[Formatting](#formatting)\
[Actions and Conditions](#actions-and-conditions)\
[Built-in Commands](#built-in-commands)\
[Examples](#examples)

## Welcome to Forked
Forked is a scripting system for DragonRuby that lets you write interactive stories, branching dialogues or anything else that requires writing and choices like, for example, this manual.

Forked is intended to be simple to pick up and easy for non-programmers to work with. For people who like to write code, it lets you focus on story-writing while giving you access to the full power of Ruby.

With Forked, you can learn how to write a simple interactive story in a few minutes.

[Back to Contents](#contents)


## Getting Started

### DragonRuby
First things first. Forked workes with DragonRuby Game Toolkit. You need DragonRuby to use Forked. 

If you're reading this, you probably already own DragonRuby and you probably also have it installed and working.

If not, you can find more information about DragonRuby at https://dragonruby.itch.io/dragonruby-gtk.

Be sure to visit the DragonRuby Discord for help or just to hang out with the super-friendly community: http://discord.dragonruby.org.

### Install Forked

To install Forked, you should start with a freshly unzipped DragonRuby project.

[Download the Forked project from GitHub](https://github.com/oeloeloel/forked). In GitHub, click the green `<> Code` button and select `Download ZIP`. Unzip the downloaded file.

Copy the _contents_ of the downloaded folder into the `mygame` folder in the DragonRuby project. Let it overwrite the existing files and folders.

Now run DragonRuby: double-click on the DragonRuby executable (dragonruby.exe on windows, dragonruby on macOS or Linux).

By default, Forked will open an interactive version of this manual to help you get started.

Now you can start writing your story.

### Writing and Editing the Story

Open up the `mygame/app/story.md` file in any text editor and you'll see the contents of the interactive version of this manual. When you look at the examples, you'll also be able to see the code that created them.

When you want to start a new story, create a new file in the `mygame/app` folder and call it whatever you want followed by the `.md` extension.

Open the `tick.rb` file and look for a line near the top that says

~~~rb
STORY_FILE = 'app/story.md'
~~~

Change `story.md` to whatever you named your file.

Then you can start writing your story:

[Back to Contents](#contents)


## Essentials

There are only a few things you *really* need to know to write a branching story with Forked.

### The Story Title
Every story needs a title and, in Forked, they are written like this:

~~~md
# Gentleman, Adventurer, Amphibian: A Memoir
~~~

The title begins with a the `#` symbol, followed by the text of the title.

You can have only one title in your story file and it should be at the top.

That's all for titles.

### Story Chunks
In Forked, stories are divided into sections called chunks. All the text you can see displayed in one screen is one chunk of the story.

With Forked, you can easily link chunks together so the player can click a button and go to a different chunk.

### Heading Lines
The first line of a chunk is the heading line. It's what lets Forked know that a new chunk is beginning.

~~~md
## The Day I Was Born
~~~

The heading line begins with two `#` symbols. 

Next is the text of the heading (`The Day I Was Born`). This will be shown at the top of the screen when the chunk is displayed.

### Adding Text

Now that you have your heading line, you can start writing text underneath it.

~~~md
## The Day I Was Born

My story begins on the day of my birth, though I do not remember much of that occasion.

My mother has never discussed it with me. Being a typical crocodile of the West African species, she is not much for conversation.
~~~

In Forked, you write text in paragraphs separated by a blank line.


[Back to Contents](#contents)


## Triggers
To allow the player to move from one chunk to another, we can use Triggers.

~~~md
[Learn more about my birth](#crocodile-parenting)
~~~

Triggers have two parts, the trigger text (`Learn more about my birth`), which is surrounded by two square brackets `[]` and the trigger action (`#crocodile-parenting`), surrounded by two round brackets `()`.

The trigger action is the text of the header you want to link to in the form of a "slug". The slug is the same text as the header but only lowercase letters, hyphens (`-`) and underscores (`_`) are allowed and spaces must be replaced with hyphens (`-`).

For example, if I want a trigger to navigate to the following chunk:
```md
## The Crocodile Hunter
```

The trigger would look like this:
```md
[Let's get straight to the adventures!](#the-crocodile-hunter)
```

Your code editor may help you to type slugs by automatically suggesting the text for you.

Triggers are displayed as buttons labeled with the trigger text.

Clicking a trigger button will perform its trigger action. In both the examples above, the action is a link to another chunk and clicking the trigger will tell Forked to navigate there.

As well as navigating to other chunks, trigger actions can run Ruby code. We'll see more about that later.

If the trigger action is empty, Forked will display a non-clickable button:
```md
[You cannot click on this button]()
```

Now you know how to create a simple branching story and link from one part to another. You could stop reading now if you wanted. Everything else is icing on the cake.

## Formatting

Now that you know how to write a story, we can do a few things about the way it looks.

### Inline Styles

Make text appear *in italics* by putting asterisks `*` aroung it:

~~~md
*This text is in italics*
**This text is bold**
***This text is in bold italics***
~~~

Note that you can also use underscores `_` instead of asterisks.

Make text appear as `code` by putting backticks `` ` `` around it:

~~~md
This line has `some code` in it
~~~

### Blockquotes
Blockquotes put your text in a box:
> The Maharajah's Star is a diamond of great renown.

To make a blockquote, start the line with a right angle bracket `>`.
~~~md
> The Maharajah's Star is a diamond of great renown.
~~~

If you put several blockquotes one after the other, they appear as a single blockquote:
~~~md
> Many people have tried to steal it over the centuries.
> All of them perished.
> Horribly.
~~~

> Many people have tried to steal it over the centuries.\
> All of them perished.\
> Horribly.


### Code Blocks
Code blocks are used to show code:
~~~rb
bag_add "The Maharajah's Star"
~~~

Code blocks start and end with three tildes ~
```rb
~~~
bag_add "The Maharajah's Star"
~~~
```

Code blocks present text 'as-is', without any formatting changes except for wrapping long lines.

Not every story will need to have code blocks. It's super-useful for manuals though.

### Horizontal Rules
You can draw a horizontal line anywhere in your story. To draw a line you just put three dashes (also known as hyphens) `-` at the start of a line:
~~~md
---
~~~

[Back to Contents](#contents)

## Actions and Conditions
Actions get things done. They are short pieces of code that you can put directly into your story to perform some common tasks. You can use actions to tell Forked to do something, remember something, count something, time something, roll dice, go to another chunk, and other things besides.

There are three ways to use actions. **Chunk Actions** perform tasks when the chunk gets displayed like, for example, adding an item to the inventory. **Trigger actions** make something happen when a player clicks a button like, for example, remembering a choice. **Conditions** make decisions like which text to display or which buttons should be visible.

Related: Forked includes a number of useful commands you can use with actions.
[Built-in Commands](#built-in-commands)


### Chunk Actions

You can drop an action into a chunk like this:

~~~rb
:: bag_add "pith helmet" ::
~~~
Chunk Actions begin and end with a pair of colon `:` symbols. Between the symbols, you can issue commands.

In this case, we are telling Forked to add a sturdy, yet attractive, "pith helmet" to the player's "bag" or inventory. Forked comes with some useful commands included, including the ability to store and retrieve items from an inventory. More about custom commands later.

When you drop an action into a chunk like this, it will run once, each time this chunk is loaded. That's the perfect time to add an item to, or remove an item from, your bag.

You can put commands on multiple lines, like this:
~~~rb
::
  bag_add "pith helmet"
  bag_remove "top hat"
::
~~~


### Trigger Actions

Sometimes you will want a trigger to perform some kind of action instead of navigating to another chunk.

~~~md
[Drop the weapon](: bag_remove "duelling pistol" :)
~~~

You can combine an action with a trigger by adding the colons above and using a command.

In this case, the item "duelling pistol" will be removed from the player's bag when the button is clicked.

You can put commands on multiple lines:
~~~
[Drop the weapon](:
  bag_remove "duelling pistol"
  jump "#surrender"
:)
~~~
The `jump` command lets you navigate to another chunk from a trigger action.


### Conditional Text
Sometimes you may want to show, hide or change text depending on the situation. Forked gives you a couple of ways to do this. The first lets you insert words or short pieces of text into the story.
~~~
Any fool knows that 
<:
  memo_check "dauphine_fave_color"
:> 
is the Dauphine's favourite colour!
~~~

One of the useful tools included with Forked is `memo` and it lets you remember and recall pieces of text like, for example, a character's favourite colour. If the dauphine's favourite colour is "Moroccan pink", the following text will be added into the story:

> Any fool knows that Moroccan pink is the Dauphine's favourite colour!

We'll learn more about `memo` and other included commands later.


We've just seen how short text can be inserted into the story. For longer texts as well as triggers and blockquotes, we can write them out and use conditions to decide if they should be displayed.

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


[Back to Contents](#contents)

## Built-in Commands
Forked contains some built-in commands to help you perform some useful or common tasks.



### Commands: Bag (Inventory Management)

The `bag` is where you keep track of the things your player collects during the game. For example, they may pick up a parcel of exotic spices to transport to Europe via submarine. You can add items to the bag like this:

~~~rb
bag_add "exotic spices"
~~~

Remove items:

~~~rb
bag_remove "exotic spices"
~~~

And check to see if the player has an item:
~~~rb
bag_has? "exotic spices"
~~~

If your player is involved in a dramatic shipwreck, they might lose the exotic spices along with everything else in their inventory. You can empty out the bag like this:

~~~rb
bag_clear
~~~


### Commands: Memo (Information Storage)

`memo` is for remembering information like, did the player meet the person of their dreams and fall in love? Did they run away from the evil pastry chef or stand their ground and fight? To remember something:

~~~rb
memo_add "in love with", "the Dauphine"
~~~

To check a memo:

~~~rb
memo_check "in love with"
~~~

To forget:

~~~rb
memo_remove "in love with"
~~~

If your player is hit on the head by a Montgolfier balloon and suffers from total amnesia, this is how to forget everything:
~~~rb
memo_clear
~~~


### Commands: Timer (Countdown Timers)

`timer` lets you create a countdown timer. You can check the timer to see if it's done and perform some other action if it is. For example, your player may only have a few seconds to defuse the saboteur's bomb and save the submarine crew:

~~~rb
timer_add "submarine explosion", 6.seconds"
~~~

To know if a timer has finished and the crew are lost:
~~~rb
timer_done? "submarine explosion"
~~~

To check how much time is left:

~~~rb
timer_check "submarine explosion"
~~~

To remove a timer:

~~~rb
timer_remove "submarine explosion"
~~~


### Commands: Counters (Number Tracking)

`counter` helps you keep track of the number of times something happens. It may be important in your story that the player gains five exquisite Persian rugs by winning games of croquet. To create a new counter:

~~~rb
counter_add "number of rugs", 0
~~~
To remove a counter:

~~~rb
counter_remove "number of rugs"
~~~

To increase or decrease a counter:
~~~rb
counter_up "number of rugs", 1
counter_down "number of rugs", 2
~~~

And to check how many rugs the player has:

~~~rb
counter_check "number of rugs"
~~~

[Back to Contents](#contents)


## Saving game data
By default, Forked will automatically save the player's progress. When the game is reloaded, Forked will load the save file so the player can continue where they left off.

If you prefer not to automatically save player progress, you can disable autosaves:
1. Open the file `app/forked/defaults`
2. Change the line 
```rb
autosave: true,
```
to
```rb
autosave: false,
```

If autosaves are disabled, you can manually trigger a save from inside your story file using the `save_game` command.
To save when a new chunk is loaded:
```
## Save when this chunk loads {#save-on-load}
:: save_game ::
```

To save when a player activates a button:
```
## Save when player clicks button {#save-on-click}
[Click to save](: save_game :)
```

If you need to remove saved data, you can use the `clear_save_data` command.
Note that if autosaves are enabled, this command may not appear to have any effect.
To clear save data when a new chunk is loaded:
```
## Clear save data when this chunk loads {#clear-save-on-load}
:: clear_save_data ::
```

To clear save data when a player activates a button:
```
## Clear save data when player clicks button {#clear-save-on-click}
[Click to clear save data file](: clear_save_data :)
```

It is also possible to enable/disable autosaving from inside a story file:
```
<!-- disable autosave when chunk loads -->
:: autosave_off ::

<!-- enable autosave when chunk loads -->
:: autosave_on ::

<!-- disable autosave when button is clicked -->
[Button](: autosave_off :)

<!-- enable autosave when button is clicked -->
[Button](: autosave_on :)
```

If you want to disable autosaving for a story file you can do that from within the story file by putting the `autosave_off` command after the story title (before the first chunk header):
```
# This is the Story Title

<!-- disable autosave for this story -->
:: autosave_off ::

## This is the first chunk
```

[Back to Contents](#contents)

## Examples

### Example: Setting the Display Theme

Change the presentation of the story.
```md
[Turn the lights on](: change_theme nil :)
[Turn the lights off](: change_theme DARK_MODE :)
[Turn the lights fun and stupid](: change_theme KIFASS_THEME :)

You can edit the display theme to change the colour scheme. Open the file `app/themes/dark-mode-theme.rb` and you can see how it's done.
```

### Example: Countdown Timer
```
<!-- Check to see if the "oxygen" timer has been created yet
and if it has not, show the button that will create (add) it -->
<:
  !timer_exist? "oxygen"
::
  [Accidentally poke your spacesuit with a screwdriver](: timer_add "oxygen", 10.seconds :)
:>

<!-- If the "oxygen" timer has already been created and is counting down
display another button to stop (remove) the timer -->
<:
  timer_exist? "oxygen"
::
  [Fix the hole in your spacesuit with duct tape](: timer_remove "oxygen" :)
  Warning: space suit rupture detected.
:>

<!-- If the "oxygen" timer exists...
AND if it has finished counting down (done), display a message
if it has not finished counting down, show how many seconds are left -->
<:
  if (timer_exist? "oxygen")
    if (timer_done? "oxygen")
      "Oxygen level: critical! You are feeling very poorly!"
    else
      "Oxygen level: #{timer_seconds "oxygen"}"
    end 
  else
    "Oxygen level: maximum"
  end
:>
```

### Example: Background Image
This example displays a background image behind the story.

The simplest way to do that is to add a conditional block and use the `background_image` command with the path to your image file.

~~~
<: 
background_image "sprites/background.png" 
:>
~~~



### Example: Roll the Dice
Are you feeling lucky?

The `roll` command lets you add some randomness to your game.

```rb
roll("1d6") # gives the roll of one, six-sided die
roll("2d6") # gives the roll of two, six-sided dice
roll("10d20") # gives the roll of ten, 20-sided dice
```

```
[Try to roll a 6!](: memo_add "roll", roll('1d6') :)

<:
# use a Ruby case statement to decide how to handle the result
case memo_check "roll" # check the result of the roll
when 6 # handle the different results
  "You did it! You rolled a 6!" # text to display for this result
when 5
  "Ye...oh! You almost got it. You rolled a 5!"
when 4
  "Getting close! You rolled a 4!"
when 3
  "Eh, you rolled a 3."
when 2
  "You're not very good at this. You rolled a 2."
when 1
  "Terrible! You rolled a 1!"
end
:>
```

### Example: Inventory

Forked gives you a bag to hold the player's inventory.

```
Your inventory currently contains: 
<: bag_sentence :>

[Pick up the potion of inconsequence](: bag_add "potion of inconsequence" :)
[Pick up the Spear of Astrabliano](: bag_add "Spear of Astrabliano" :)
[Pick up the Golden Crown of Impolior](: bag_add "Golden Crown of Impolior" :)

<: 
  bag_has? "potion of inconsequence" 
::
  [Drink the potion of inconsequence](: bag_remove "potion of inconsequence" :)
:>
<:
  bag_has? "Spear of Astrabliano" 
::
  [Throw the Spear of Astrabliano](: bag_remove "Spear of Astrabliano" :)
:>
<:
  bag_has? "Golden Crown of Impolior" 
::
  [Melt down the Golden Crown of Impolior](: bag_remove "Golden Crown of Impolior" :)
:>

[Turn your bag upside down and shake it out](: bag_clear :)
```

## Example: Memorizing info
```
:: memo_add "favourite colour", "a great mystery" ::

At that time, everyone in European society was speculating about the Dauphine's favourite colour. It was, of course,
<: (memo_check "favourite colour") + '.' :>

[The Dauphine's favourite colour was Moroccan Pink](: memo_add "favourite colour", "Moroccan Pink" :)
[The Dauphine's favourite colour was Cerulean Blue](: memo_add "favourite colour", "Cerulean Blue" :)
[The Dauphine's favourite colour was Etruscan Brown](: memo_add "favourite colour", "Etruscan Brown" :)
```

[Back to Contents](#contents)

