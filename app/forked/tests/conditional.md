# Conditional Elements

## Test 1: Interpolation:

<:
"1 During"
:>

## Test 2: Interpolation after text

2 Before
<:
"2 During"
:>

## Test 3: Interpolation before text

<:
"3 During"
:>
3 After

## Test 4: Interpolation after and before text

4 Before
<:
"4 During"
:>
4 After

## Test 5: Conditional

<:
true
::
5 During
:>

## Test 6: Conditional after text

6 Before
<:
true
::
6 During
:>

## Test 7: Conditional before text

<:
true
::
7 During
:>
7 After

##Test 8: Conditional after and before text

8 Before
<:
true
::
8 During
:>
8 After

End

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

## Conditional content within a paragraph {#conditional-content-in-paragraph}

Conditional content can be inserted into an existing paragraph.

Visible Example:

This is the first part.
<:
  true
::
  "This is the second part."
:>
This is the third part.

Invisible Example

One.
<:
false
::
Two.
:>
Three.

Interpolation.

One part, 
<:
  "two part,"
:>
three part.

[Next]()