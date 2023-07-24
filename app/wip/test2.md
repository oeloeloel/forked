# TESTING CHANGES IN PROGRESS

## ID does not exist

[Broken button](#broken-link)

## Thematic break

---

Conditonal hr

<%```
true
```
---
%>

## Space after interpolation

```
args.state.variable = "text ends"
```

This paragraph starts...
<%```
args.state.variable
```%>
. text continues. 
                           
Problem: there is a space after the variable. I might want to follow that with a full stop or a comma depending on the context.


## Action Block {#action-block}

```
putz "hello from action block"
```

## Fences {#fence}
Code fences should be the only thing on their line. There should not be an error but ignore any other content.

Code Block\
Expected result:
~~~
# code block content
~~~

Actual result:
text before ~~~ text after
# code block content
text before ~~~ text after

Action Block\
Expected result in console: "action block content"
text before ``` text after
# action block content
putz "action block content"
text before ``` text after

Trigger Action Block
[Button](```
putz "trigger action block content"
```)
Expected result in console: "trigger action block content"

```
$one_time_putz = nil
```

Conditional Code Block\
Expected result in console: "conditional block content"
<%```
$one_time_putz ||= (putz "conditional block content"; true)
```%>

## Commenting out actions

The following is broken because html comments are not allowed but the backticks should NEVER be recognised as fences for a chunk action. This is because the forward slash comments should always discard them.

Expected result:

~~~
<!-- putz "this code does not run" <!--
~~~

Actual result:

<!-- //``` -->
putz "this code does not run"
<!-- //``` -->


## MAKE IT RAIN {#mir}

It's late at night. You are standing in the street in your pyjamas.

<%```
args.state.raining
```
The rain is coming down in buckets.

~~~
pitter_pat()
~~~

> pitter pat

[Stop the rain](```
  args.state.raining = false
```)
%>

[Make it rain](```
  args.state.raining = !args.state.raining
```)

[CONTENTS](#contents)

## CONDITIONS 2 {#conditions-two}

Next to do:

In EVERY element type (unless there are some that don't apply), add code that checks to see if a conditional block is open. If so, add the most recent condition to the element or atom condition so it only appears if the result is truthy.

Hello 
<%```
 "nose " + "hairs"
```%>
face
feet.

Goodbye
<%```
"eye " + "lashes"
```%>
legs
arms.

```
args.state.raining = false
```

<%```
args.state.raining
```
It's raining. Pitter pat.

This whole paragraph is conditional.

And so is this one.

> As well as this blockquote.

[And this button. Make it stop raining](```
  args.state.raining = false
```)
%>

<%```
true
```
This is just for good measure
%>

[make it rain](```
  args.state.raining = true
```)

[CONTENTS](#contents)

## CONDITIONS 1 {#conditions-one}

```
memo_add "condition_1", "Jellyfish"
```

Conditions allow the writer to conditionally display elements.

Conditional content is wrapped in tags: `<%` and `%>`.

Conditional content always starts with the condition that runs every time it is encountered (60 times per second). What gets displayed depends on the result of the condition.

If the result of the condition is a string (text), the string will be displayed:

<%```
memo_check 'condition_1'
```%>

This is `string interpolation` and it's good for inserting short, dynamic text into paragraphs but it is a difficult way to manage longer text and it cannot insert different content elemnts like buttons.

[CONTENTS](#contents)


## TRIGGER ACTION {#trigger-action}

A trigger action is contained within the action block of a trigger and is evaluated when the trigger button is clicked.

The button below puts "Button was clicked well." to the console.

//[test me](```
putz "Button was clicked well."
//```)

TODO: The triple backticks should work if moved to separate lines, as in the MD spec.
%

[CONTENTS](#contents)

## CHUNK ACTION {#chunk-action}

A chunk action is executable code dropped into the body of a chunk (paragraph space). The code is executed as DragonRuby Ruby. It is wrapped in three backticks.

The chunk action in this test puts "Chunk action code evaluated." to the console.

//```
putz "Chunk action code evaluated."
//```

TODO: Escapes do not currently prevent code from evaluating.

[CONTENTS](#contents)

## CODE BLOCK {#code-block}

A code block displays code in a fixed-width font without changes, except to soft-wrap lines. Code blocks are for display only and are not excutable. They are fenced with triple tildes (~).

~~~
  def this_is_a_code_block
    it_is_for_display_only()
    # it is not currently capable of displaying triple tildes within itself (todo). This line will wrap because it's long, right?
~~~

[CONTENTS](#contents)

## CONTENTS {#contents}

[CODE BLOCK](#code-block)
[CHUNK ACTION](#chunk-action)
[TRIGGER ACTION](#trigger-action)
[CONDITIONS 1: STRING INTERPOLATION](#conditions-one)
[CONDITIONS 2](#conditions-two)
