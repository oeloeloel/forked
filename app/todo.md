# TODO LISTS

## Todo list (next release) {#todo}

Todo now/next

DONE: \ at end of line is hard wrap
DONE: Escape Code Block\
DONE: Make Conditional blocks work when there is no context (make a paragraph)\
MANUAL: More explanation on coding before getting to conditional text.\
TODO: Make methods to create parts of story hash instead of writing them out over again\
TODO: Inline styles (bold, italic, etc.).\
Helpers: Background image, timer, wallet, memo\

Exceptions need adding:
> User enters a ID link that does not correspond with an ID

[Future Todo List](#future)

## Future Todo List {#future}

For some time in the future
[Allow for linking to header text as in github md](#link_header_text)
[Show an optional title screen](#title-screen)
[Change the action block syntax to use 3 backticks](#action-syntax)
> Blank line between blockquotes should start a new blockquote. Consecutive lines should ignore newlines.
> Inline links?
> Fall through if button has no link
> Refresh from file but retain current location in story IF feasible.
TODO: Escape more things (code blocks done)


[Future Todo List Part 2](#future-2)
[Todo List](#todo)

## Future Todo List 2 {#future-2}

> Images
> Images in blockquotes (left or right)
> Blank line between buttons leaves a bigger gap between them
> Autogenerate contents
> Button rows
[Allow multiple files and switch between them + launcher](#multi-files)
[Add commands](#commands)
Add formats: Lists
[Performance improvements](#perf)
%
[TODO List](#todo)

## Performance improvements {#perf}
Render blocks to render targets.
Especially code blocks.
Every block level element should have a dirty flag.
When an update on that block is needed (most won't need it) the content changes and the block is marked as dirty.
Display should handle the rendering and lower the flag each time.

[Back](#future)
[Todo List](#todo)

## Commands and Helpers to Add {#commands}
> Track every chunk the player goes through and give the writer access to it
> Timers
> Money
> Hide/Show Forked (& suspend interactivity)


## Multiple files (#multi-files)
Allow user to create more than one Forked instance. This will allow writers to split long scenes into multiple files or allow switching between stories mid-flow.

The question is how to handle shared data. If the stories are truly separate, they should not risk overlapping namespaces.

If the files are linked or scenes from the same story, some things may want to remain available to all files. For example, the player inventory. Timers, etc.

[Back](#future)
[TODO List](#todo)


## Action Block Syntax {#action-syntax}
Change action block syntax from 3 carets to 3 backticks.
Change trigger action block syntax from (3-carets 3-carets) to (3-backticks 3-backticks)
Change condition block syntax from <3-carets 3-carets> to <3-backticks 3-backticks>

Allow escaping backticks with backslash AND four backticks.

Allow presentation of code blocks with tildes again.

[Back](#future)
[TODO List](#todo)

## Title Screen {#title-screen}

Title screen could be optional. If the next line after the title is a chunk heading, don't display a title screen.

If there is anything between the title and the first chunk heading, assume a title screen is desired and show one.

Title screen will display the title in big letters and center content, buttons, etc.

[Back](#future)
[TODO List](#todo)

## Link Header Text {#link_header_text}

Markdown headers, at the basic level look like this:

```
# Header text
```

In regular markdown, and in Forked, you specify an ID for links to go to:
```
# Header text {#header_id}
```

In github markdown, you cannot link to the header ID, only to the header. That would be something like this:
```
[go to the header](#header-text-header_id)
```

To make VSC a viable editor, it will be necessary to work with this.

So, if the writer gives a link that does not match any chunk ID, check the header texts and link there.
[Back](#future)
[TODO List](#todo)