# TODO LIST

## Syntax
- Title: `# title`
- Heading line: `heading text #{chunk_id}`
- Trigger & target `[Trigger text](#chunk_id)`
  - or: `[Trigger text]{```code```}
- Code block: ```code``` (also multiline)
- Block `<...>`
- Conditional text: `<```code```> inserts result into text unless code is `true` or `falsey`.
  - <```code``` text displayed if true */* text displayed if falsey>.



- [] Change name from `target`
- [] Backslash escapes characters: #
- [] Choose a new identifier for inline code.
- [] What's a good identifier for the alternate block


## Errors
- [] Navigating to a chunk_id that does not exist
- [] Exception if there is more than one title

## Things that need to be figured out or might be game changers
- [ ] Include more advanced code blocks. Maybe surround code in backticks?
- [ ] Think deeply about situations that allow freer use of code execution. For example, 
- [ ] allow the dev to set and check flags without needing to write custom methods for each one
- [ ] allow execution of multiple statements in conditions and make it more robust
- [ ] checking for code execution should parse smarter because currently, using round brackets, code can't have brackets or it breaks
- [ ] Sometimes you will want to do <condition --> code>
- [ ] Nesting conditions, code execution in conditions
- [ ] Combine navigation with actions

## Things that are broken and need to be fixed
- [ ] brackets in code break the code


## Things to do but not immediately
- ### Error checking
- [ ] Give error/warning if a chunk heading does not have an id
- [ ] Centralise error reporting and give line numbers for properly identified errors
- [ ] Allow pulling the results of code directly into the text. "The winning color is #{winning_color}!" type of thing.

- ### LOGIC
- [] Rethink the execution of commands. Commands can run one time (chunk actions), every tick (conditions), when a button is clicked(trigger actions))?