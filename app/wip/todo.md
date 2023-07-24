# TODO LISTS

## Todo list (soon) {#todo}

Todo now/next

TODO: Conditional block should not extend paragraph if there is a blank line between. (Use context)\
TODO: Think: inline code uses single backtick. What to use if backtick is executable code?\
TODO: Inline styles (**code**, **bold**, *italic*, ***bold italic***.).\
TODO: Escape triple tilde\
TODO: Backslash on empty line is <br>\
TODO: Update tests\
TODO: BUG: This pattern breaks parsing: /x2 `x3 /x2. Guessing the second comment is preventing the first from parsing somehow and the backticks register as an unterminated block.


Exceptions need adding:\

[Future Todo List](#future)

## Todo later {#future}

For some time in the future
[Allow for linking to header text as in github md](#link_header_text)
[Show an optional title screen](#title-screen)
TODO Blank line between blockquotes should start a new blockquote. Consecutive lines should ignore newlines.\
TODO Inline links\
TODO Fall through if button has no link\
TODO Refresh from file but retain current location in story IF feasible.\
TODO: Escape more things (code blocks done)\
TODO: Allow escaping backticks with backslash AND four backticks.
TODO: Refactor parse methods\
TODO: Make methods to create parts of story hash instead of writing them out over again\
TODO: BUG: Interpolation is always followed by a space, meaning it cannot be followed by a full stop or other punctionation, etc. See test2 file: space after interpolation

[Future Todo List Part 2](#future-2)
[Todo List](#todo)

## Todo even later {#future-2}

TODO Images\
TODO Images in blockquotes (left or right)\
TODO Blank line between buttons leaves a bigger gap between them\
TODO Autogenerate contents page\
TODO Button rows\
[Allow multiple files and switch between them + launcher](#multifiles)
[Add commands](#commands)
[Performance improvements](#perf)
Add formats: Lists
[TODO List](#todo)

## Performance improvements {#perf}
Render blocks to render targets.\
Especially code blocks.\
Every block level element should have a dirty flag.\
When an update on that block is needed (most won't need it) the content changes and the block is marked as dirty.\
Display should handle the rendering and lower the flag each time.

[Back](#future-2)
[Todo List](#todo)

## Commands and Helpers to Add {#commands}
TODO Track every chunk the player goes through and give the writer access to it\
TODO Hide/Show Forked (& suspend interactivity)

[Back](#future-2)
[TODO list](#todo)

## Multiple files {#multifiles}
Allow user to create more than one Forked instance. This will allow writers to split long scenes into multiple files or allow switching between stories mid-flow.

The question is how to handle shared data. If the stories are truly separate, they should not risk overlapping namespaces.

If the files are linked or scenes from the same story, some things may want to remain available to all files. For example, the player inventory. Timers, etc.

[Back](#future-2)
[TODO List](#todo)

## Title Screen {#title-screen}

Title screen could be optional. If the next line after the title is a chunk heading, don't display a title screen.

If there is anything between the title and the first chunk heading, assume a title screen is desired and show one.

Title screen will display the title in big letters and center content, buttons, etc.

[Back](#future)
[TODO List](#todo)

## Link Header Text {#link_header_text}

Markdown headers, at the basic level look like this:

~~~
# Header text
~~~

In regular markdown, and in Forked, you specify an ID for links to go to:
~~~
# Header text {#header_id}
~~~

In VSC markdown, you cannot link to the header ID, only to the header. If the header line includes an ID, that must also be a part of the link. That would be something like this:
~~~
[go to the header](#header-text-header_id)
~~~

To make VSC a viable editor, it will be necessary to work with this.

So, if the writer gives a link that does not match any chunk ID, check the header texts and link there.
[Back](#future)
[TODO List](#todo)

## Done

DONE: Line wrap fail in manual: Adding Text\
DONE: \ at end of line is hard wrap\
DONE: Escape Code Block\
DONE: Make Conditional blocks work when there is no context (make a paragraph)\
DONE: MANUAL: Open DragonRuby, hooking up Forked.
DONE: Helpers: √Background image, √timer, √wallet, √memo\
DONE: Change executable code block (standard) to use triple backtick\
DONE: Change conditional block code block to use triple backtick\
DONE: Change trigger code block to use triple backtick\
DONE: Change fenced code block to use triple tilde\
DONE: Change conditional block to use <% %>\
DONE: Conditional block true section. (false can maybe come later, possibly with a %% between them.)\
DONE Change standard action block not to pick up in every circumstance\
DONE Timers
DONE Money
DONE Change action block syntax from 3 carets to 3 backticks.
DONE Change trigger action block syntax from (3-carets 3-carets) to (3-backticks 3-backticks)
DONE Change condition block syntax from <3-carets 3-carets> to <3-backticks 3-backticks>
DONE Allow presentation of code blocks with tildes again.
DONE: Check if there are any elements that should be conditional but are not yet
    Already: paragraph, blockquote, trigger, code block
    Can't do: header 1, header 2
DONE: MANUAL More explanation on coding before getting to conditional text.\
DONE EXCEPTION writer enters a ID link that does not correspond with an ID

[TODO List](#todo)
