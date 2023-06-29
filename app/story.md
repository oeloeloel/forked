# Forked User Manual

## Welcome to Forked {#welcome}

Forked is a scripting system for DragonRuby that lets you write interactive stories, branching dialogues or anything else that requires writing and choices like, for example, this manual.

Forked is intended to be simple to pick up and easy for non-programmers to work with. For people who code, it offers a space for writing with fewer distractions combined with the ability to call on the full power of Ruby.

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
[Show or Hide Blocks]()
[Show or Hide Triggers]()
[Alternative Text in Blocks]()
[Embedding Ruby Code]()
[Examples](#examples)



## Getting Started {#getting_started}

Open up the story.md file and you'll see the contents of this manual. When you look at the examples, you'll also be able to see the code that created them.

When you want to start a new story, create a new file in the 'app' folder and call it whatever you want.

Open the tick.rb file and look for a line near the top that says

~~~STORY_FILE = 'app/story.md'~~~

Change 'story.md' to whatever you named your file.

Then you can start writing your story.

[Next: The Story Title](#story_title)  
[Back: Welcome to Forked](#welcome)  
[Contents](#contents)

## The Story Title {#story_title}
Every story needs a title and, in Forked, they are written like this:

~~~# Gentleman, Adventurer, Amphibian: Memoirs of a Crocodile~~~

The title begins with a hash or pound symbol # followed by the text of the title.

You can have only one title in your story file.

That's all for titles.

[Next: Story Chunks](#story_chunk)
[Prev: Getting Started](#getting_started)
[Contents](#contents)

## Story Chunks {#story_chunk}
In Forked, stories are divided into chunks. Chunks are sections of the story that contain related text and which the player can navigate between.

Everything you see on the screen now is one chunk of the story. When you click on one of the buttons below, you'll be taken to another chunk.

The first chunk in your story file is the first one that will be displayed. The order of the rest of the chunks doesn't matter.

Chunks begin with a heading line and end when the next heading line is reached or the end of the file is reached.

Go ahead and click the Heading Line button below and we'll go and see what's in the Heading Line chunk.

[Next: The Heading Line](#heading_line)
[Prev: The Story Title](#story_title)
[Contents](#contents)

## Heading Lines {#heading_line}
The first line of a chunk is the heading line. It's what lets Forked know that a new chunk is beginning.

~~~ ## The Day of my Birth {#start} ~~~

The heading line begins with two hash symbols (##). 

Next is the text of the heading (The Start of My Story). This text will be shown at the top of the screen when the chunk is displayed. This text is optional and if it is left out, Forked will show the story title instead.

Finally, there is the Chunk ID {#start}. This identifies the chunk so we can navigate to it from other chunks. It begins with a hash (#) followed by a unique name, without any spaces. It is wrapped in curly brackets {}.

[Next: Adding Text](#adding_text)
[Prev: Story Chunks](#story_chunk)
[Contents](#contents)

## Adding Text {#adding_text}

Now that you have your heading line, you can start writing text underneath it.

~~~ ## The Day of my Birth {#start} ~~~

~~~My story begins on the day of my birth. I do not have much recollection of that time but I have learned some of it from others and through my own research.~~~

~~~My mother, if she remembers my birth, has never spoken of it. Being a typical crocodile of the West African species, she is not much for conversation.~~~

In Forked, text is written with line breaks after paragraphs. It is not necessary to leave a blank line between paragraphs but it makes the file easier to read.

[Next: Triggers](#triggers)
[Prev: Heading Lines](#heading_line)
[Contents](#contents)

## Triggers {#triggers}
To navigate between chunks, we can use Triggers.

~~~[Learn more about my birth](#my_father)~~~
~~~[Let's get to the adventures!](#crocodile_hunters)~~~

Triggers have two parts, the trigger text, which is surrounded by two square brackets [] and the trigger action, surrounded by two round brackets ().

Triggers are displayed as buttons labeled with the trigger text. You can see three trigger buttons at the bottom of the screen right now. 

Clicking a trigger button will perform its trigger action. In both the examples above, the action is a chunk_id and clicking the trigger will tell Forked to navigate to the specified chunk.

As well as navigating to other chunks, trigger actions can run Ruby code. We'll see more about that later.

If the trigger action is empty, Forked will display a non-clickable button like the next button below:
[I do not wish to discuss it any further]()

[Next: Actions](#actions)
[Prev: Adding Text](#Adding Text)
[Contents](#contents)

## Actions {#actions}
Actions get things done. You can drop an action into a chunk like this:

~~~``` inventory_add "pith helmet" ```~~~

The action `inventory_add` is a custom command that is included with Forked. If you're making an adventure game, the inventory will help you keep track of any items your player character posesses. In this case, we have added an attractive, yet sturdy, pith helmet to the player's inventory.

Actions are wrapped with three tick ` symbols on each side. 

When you drop an action into a chunk like this, it will run once, each time this chunk is loaded.

[Next: Using Actions with Triggers](#actions_with_triggers)
[Prev: Triggers](#triggers)
[Contents](#contents)

## Using Actions with Triggers {#actions_with_triggers}
Sometimes you will want a trigger to perform some kind of action instead of navigating to another chunk.

~~~[Drop the weapon and surrender](```inventory_remove "dueling pistol"```)~~~

You can combine an action with a trigger by replacing the chunk id with a command wrapped in backticks as in the example above.

In this case, the item "dueling pistol" will be removed from the player's inventory when the button is clicked.

[Next: Blocks](#blocks)
[Prev: Actions](#actions)
[Contents](#contents)

## Blocks {#blocks}
Blocks group things together. Blocks begin and end with angle brackets < >, and they can contain paragraphs (one or more) or triggers, or both. 

In the example below, a block is used to combine an action with a paragraph to create text that only appears under certain conditions:

~~~<```inventory_has? "dinghy"``` Leaving the submariners taking turns to fill the inflatable dingly with air, I leaped from the boat in pursuit of my quarry.>~~~

The paragraph above will only be shown if the player has acquired an infflatable dinghy along the way.

Blocks can wrap around multiple paragraphs as well as triggers.

~~~<```inventory_has? "pistol"``` I touched the barrel of my dueling pistol to the tip of the archduke's nose.~~~

~~~[Pull the trigger and become a fugitive crocodile](#on_the_run)>~~~


[Prev: Using Actions with Triggers](#actions_with_triggers)
[Contents](#contents)

## Examples {#examples}

[Setting the Display Theme](#theme)

## Example: Setting the Display Theme {#theme}

Change the presentation of the story.

[Dark Mode](```change_theme DARK_MODE ```)
[Light Mode](```change_theme LIGHT_MODE ```)

%
%
You can edit the display theme to change the colour scheme. Open the file `tick.rb` and you can see the configuration options near the top.

[Back to Examples](#examples)
[Back to Contents](#contents)

## Block Test {#block_test}

Text

<```true``` display this text>
<```false``` do not display this text>

<```true``` display this multiline
text>

<```true```[display this button]()>
<```false```[don't display this button]()>