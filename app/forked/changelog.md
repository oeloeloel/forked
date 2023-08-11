Current Version

Version 0.0.1
* Fixed bug: Changing the size_enum caused interpolated text to appear in the wrong x location and line lengths were miscalculated.
* Fixed bug: When displaying the story title in place of a missing heading, the prefix # was displayed.
* Fixed bug: Comment markers at line character zero were ignored if the line contained extra comment markers later on.
* Reenabled feature "preserved line" (effectivle pre-formatted) allows a line to skip formatting and be presented as-is. Marker: line starts with `$$`.
* Clean-up in parse.rb to use methods to create hashes so they can be consistently applied from anywhere.
* Fixed bug: If there are two interpolated texts, they will now be displayed as two paragraphs if there is a blank line between them.
* Fixed bug (possibly): trigger action code starting with `#` tries to navigate instead of executing code. This is fixed with a kludge so Forked can tell the difference at runtime. It seems to work.

Previous versions:

Version 0.0.0
* Initial version