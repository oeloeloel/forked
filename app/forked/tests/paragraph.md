# Paragraph Tests

## Paragraph - Creation {#creation}

Paragraphs are created by default when there is a non-blank line that cannot be interpreted as any other element. This is an example of a paragraph.
[Next](#single-newline)

## Paragraph - Single Newline  {#single-newline}
A single paragraph can span multiple lines.
If two lines of text are separated by a single newline, the newline is ignored
and the paragraph is continued. Example:

This is the start of a paragraph.
This text is on a separate line.
[Next](#multiple-paragraphs)

## Paragraph - Multiple Paragraphs {#multiple-paragraphs}
Chunks can contain multiple paragraphs. If two lines of text are separated by a blank line, the second line will open a new paragraph. Example:

Paragraph one.

Paragraph two.

[Next](#soft-wrap)

<: 
```rb
    # putz args.outputs.primitives[4...6]
    $expect = [{:x=>200, :y=>546, :text=>"Paragraph one. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>200, :y=>511, :text=>"Paragraph two. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
```
:>

<: $expect == args.outputs.primitives[4...6] ? "Test passed " : "Test failed" :>


## Paragraph - Soft Wrap {#soft-wrap}
Paragraph text is soft-wrapped when it exceeds the maximum allowed line length. To illustrate, there now follows some latin: 

Quid igitur est? inquit; audire enim cupio, quid non probes. Principio, inquam, in physicis, quibus maxime gloriatur, primum totus est alienus. Democritea dicit perpauca mutans, sed ita, ut ea, quae corrigere vult, mihi quidem depravare videatur. ille atomos quas appellat, id est corpora individua propter soliditatem, censet in infinito inani, in quo nihil nec summum nec infimum nec medium nec ultimum nec extremum sit, ita ferri, ut concursionibus inter se cohaerescant, ex quo efficiantur ea, quae sint quaeque cernantur, omnia, eumque motum atomorum nullo a principio, sed ex aeterno tempore intellegi convenire.

[Next](#hard-wrap)

## Paragraph - Hard Wrap {#hard-wrap}
Text can be hard wrapped by ending a line with a backslash character (\).

~~~
Line 1\
Line 2\
Line 3
~~~

Line 1\
Line 2\
Line 3

[Next](#followed-by-blockquote)

## Paragraph - Followed by Blockquote {#followed-by-blockquote}
Paragraphs can be interrupted by other elements. For example, it is not necessary to leave a blank line between a paragraph and a blockquote.
> Blockquotes can follow paragraphs without a separating blank line
[Next](#followed-by-trigger)

## Paragraph - Followed by Trigger {#followed-by-trigger}
Paragraphs can be interrupted by triggers.
[Trigger buttons can follow paragraphs without a separating blank line]()

[Next](#followed-by-code-block)

## Paragraph - Followed by Code Block {#followed-by-code-block}
Paragraphs can be interrupted by code blocks.
~~~
code blocks can follow paragraphs without a separating blank line
~~~

[Next](#leading-trailing-spaces)


## Paragraph - Leading and trailing spaces {#leading-trailing-spaces}
Leading (and trailing) spaces are removed from paragraph lines.

    This example shows spaces being removed.    

[Next](#)

<: 
  ```rb
    # putz args.outputs.primitives[3]
    $expect = {:x=>200, :y=>568, :text=>"This example shows spaces being removed. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}
  ```
:>

<: $expect == args.outputs.primitives[3] ? "Test passed " : "Test failed" :>