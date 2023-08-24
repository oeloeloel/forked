# Conditional Elements

## Single line string interpolation

Single line string interpolation is wrapped in `<:` and `:>` symbols.

<: "This text is conditional" :>

[Next](#)

## Multi line string interpolation

Multi line string interpolation has the `<:` on the preceding line and `:>` on the following line.

<:
"This text is conditional"
:>

[Next](#)

## String Interpolation requires a string expression {#string-interpolation-string-1}

If string interpolation returns a string, it is displayed. 

Example. The following line is displayed with String Interpolation.

<: "This line is displayed with String Interpolation" :>

[Next](#)



## String Interpolation requires a string expression {#string-interpolation-string-2}

If string interpolation returns a non-string. nothing is displayed.

Example. The following line returns a number so it is not displayed.

<: 1 :>

[Next](#)

## String Interpolation within a paragraph {#string-interpolation-in-para}

Strings can be interpolated within another string using single line breaks.

Example:

This is the first part.
<: "This is the second part." :>
This is the third part.

[Next](#)


## Conditional content {#conditional-content-1}

In a conditional content container, content appears if the condition is true.

Example. The following line appears because the condition is true.

<: 
  true 
:: 
  This line appears because the condition is true. 
:>

[Next](#)

## Conditional content {#conditional-content-2}

In a conditional content container, content is hidden if the condition is false.

Example. The following line is not visible because the condition is false.

<: 
  false 
:: 
  This line is hidden because the condition is false. 
:>

This line follows the condition

[Next](#)

## Conditional content within a parapraph {#conditional-content-in-paragraph}

Conditional content can be inserted into an existing paragraph.

Example:

This is the first part.
<:
  false
::
  "This is the second part."
:>
This is the third part.

## a

//<: 1 :>
//<: true :>
//<: Time :>

Nothing should appear between this line and the first line in this chunk (spacing between lines should be normal).

Normal paragraph spacing for reference.

Test\
test\
test

<: true :>

[Next]()