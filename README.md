# Forked
Forked is a system for scripting interactive narratives in DragonRuby. The project is in development but complete enough to make fully functional text games, for example [My Death Story](https://akzidenz.itch.io/my-death-story).

Forked uses a simplified markup similar to markdown. It is intended to be simple to use, easy to learn for people without programming experience and to make it easier to focus on writing.

Additional functionality can be added by writing commands in Ruby.

What it lets you do:
* Write stories in a readable format with minimal distraction
* Player navigates to different parts of your story with button clicks
* Issue commands from within your story
  * Premade commands available for non-programmers
  * Custom commands are simple to create using Ruby
* Conditions allow you to control what the player sees
  * Show or hide text based on conditions
  * Show or hide buttons based on conditions
* Buttons can link to other parts of the story or run code
* Track the player's progress through the story
* Automatically (or manually) save the player's progress so they can continue playing where they left off

## Getting started
To begin:
1. Dowload the latest version of DragonRuby, if necessary. For help with DragonRuby visit the [Discord server](http://discord.dragonruby.org).
2. Unzip a fresh copy of DragonRuby. 
3. Download Forked and unzip it (go [here](https://github.com/oeloeloel/forked/tree/main), click the green **Code** button and select **Download Zip**).
4. Drag the **contents** of the `forked` folder to DragonRuby's `mygame` folder, letting it overwrite the existing folders.
5. Run DragonRuby. 

By default, the user manual will load up and be displayed. The user manual itself was created with Forked and you can [look at the code](https://github.com/oeloeloel/forked/blob/main/app/story.md?plain=1) to see how it was made.

When you're ready to make your own story:
1. Create a new blank text file in the `mygame/app` folder. 
2. Name the file however you like but it is recommended to end the filename with `.md`, for example, `my-life-story.md`.
3. Edit the file `mygame/app/tick.rb`. Change the line at the top of the file from...
```rb
STORY_FILE = 'app/story.md'
```
to the file you just created. Note that the file path should begin with `app` and not `mygame`.
```rb
STORY_FILE = 'app/my-life-story.md'
```

Now you can start writing your story in the `my-life-story.md` file. 

See the [User Manual](manual.md) to learn how to use Forked.
See the [Quick Reference](quick-reference.md) to see the formatting options and action commands available.
