# Forked User Manual

## Welcome to Forked {#welcome}

Forked is a scripting system for DragonRuby that lets you write interactive stories, branching dialogues or anything else that requires writing and choices.

It is intended to be simple to pick up and easy for non-programmers to work with. For people who code, it offers a space for writing with fewer distractions combined with the ability to call on the full power of Ruby.

[Next: Getting Started](#getting_started)

[Contents](#contents)

## Contents {#contents}

[Welcome to Forked](#welcome)
[Getting Started](#getting_started)
[The Story Title](#story_title)
[Story Chunks](#story_chunk)
[Heading Lines](#heading_line)
[Adding Text](#adding_text)
[Triggers]()
[Actions]()
[Using Actions with Triggers]()
[Blocks]()
[Show or Hide Blocks]()
[Show or Hide Triggers]()
[Alternative Text in Blocks]()
[Embedding Ruby Code]()



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

The title begins with a hash or pound symbol (#) followed by the text of the title.

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

Finally, there is the Chunk ID {#start}. This identifies the chunk so we can navigate to it from other chunks. It begins with a hash (#) followed by a unique name, without any spaces. It is wrapped in curly brackets ({}).

[Next: Adding Text](#adding_text)
[Prev: Story Chunks](#story_chunk)
[Contents](#contents)

## Adding Text {#adding_text}

Now that you have your heading line, you can start writing text underneath it.

~~~ ## The Day of my Birth {#start} ~~~


[Next: Triggers](#triggers)
[Prev: Heading Lines](#heading_line)
[Contents](#contents)