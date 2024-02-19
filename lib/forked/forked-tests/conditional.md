# Conditional Elements

## Interpolation solo

~~~
<:
"1 During"
:>
~~~

<:
"1 During"
:>
---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...7]
    expect = [{:x=>200, :y=>528.9, :w=>880, :h=>75.09999999999999, :primitive_marker=>:sprite, :padding_left=>20, :padding_right=>20, :padding_top=>7, :padding_bottom=>12, :margin_left=>0, :margin_right=>0, :margin_top=>0, :margin_bottom=>0, :min_height=>0, :r=>63, :g=>67, :b=>51}, {:x=>220, :y=>597.0, :text=>"<:\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>578.3, :text=>"\"1 During\"\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>559.5999999999999, :text=>":>\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>200, :y=>513, :text=>"1 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>


## Interpolation after text
~~~
2 Before
<:
"2 During"
:>
~~~

2 Before
<:
"2 During"
:>

---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...9]
    expect = [{:x=>200, :y=>510.2, :w=>880, :h=>93.8, :primitive_marker=>:sprite, :padding_left=>20, :padding_right=>20, :padding_top=>7, :padding_bottom=>12, :margin_left=>0, :margin_right=>0, :margin_top=>0, :margin_bottom=>0, :min_height=>0, :r=>63, :g=>67, :b=>51}, {:x=>220, :y=>597.0, :text=>"2 Before\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>578.3, :text=>"<:\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>559.5999999999999, :text=>"\"2 During\"\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>540.8999999999999, :text=>":>\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>200, :y=>494, :text=>"2 Before ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>274, :y=>494, :text=>"2 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## Interpolation before text

~~~
<:
"3 During"
:>
3 After
~~~

<:
"3 During"
:>
3 After
---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...9]

    expect = [{:x=>200, :y=>510.2, :w=>880, :h=>93.8, :primitive_marker=>:sprite, :padding_left=>20, :padding_right=>20, :padding_top=>7, :padding_bottom=>12, :margin_left=>0, :margin_right=>0, :margin_top=>0, :margin_bottom=>0, :min_height=>0, :r=>63, :g=>67, :b=>51}, {:x=>220, :y=>597.0, :text=>"<:\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>578.3, :text=>"\"3 During\"\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>559.5999999999999, :text=>":>\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>540.8999999999999, :text=>"3 After\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>200, :y=>494, :text=>"3 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>274, :y=>494, :text=>"3 After ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>


## Interpolation before and after text
~~~
4 Before
<:
"4 During"
:>
4 After
~~~

4 Before
<:
"4 During"
:>
4 After

---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...11]
    expect = [{:x=>200, :y=>491.5, :w=>880, :h=>112.5, :primitive_marker=>:sprite, :padding_left=>20, :padding_right=>20, :padding_top=>7, :padding_bottom=>12, :margin_left=>0, :margin_right=>0, :margin_top=>0, :margin_bottom=>0, :min_height=>0, :r=>63, :g=>67, :b=>51}, {:x=>220, :y=>597.0, :text=>"4 Before\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>578.3, :text=>"<:\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>559.5999999999999, :text=>"\"4 During\"\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>540.8999999999999, :text=>":>\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>220, :y=>522.1999999999998, :text=>"4 After\n ", :primitive_marker=>:label, :font=>"fonts/roboto_mono/static/robotomono-regular.ttf", :size_enum=>0, :line_spacing=>0.85, :r=>179, :g=>204, :b=>127, :spacing_after=>0.7, :size_px=>22.0}, {:x=>200, :y=>476, :text=>"4 Before ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>274, :y=>476, :text=>"4 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>349, :y=>476, :text=>"4 After ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>


## Conditional

<:
true
::
5 During
:>

---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...3]
    expect = [{:x=>200, :y=>604, :text=>"5 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## Conditional after text

6 Before
<:
true
::
6 During
:>

---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...4]
    expect = [{:x=>200, :y=>604, :text=>"6 Before ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>274, :y=>604, :text=>"6 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## Conditional before text

<:
true
::
7 During
:>
7 After

---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...4]
    expect = [{:x=>200, :y=>604, :text=>"7 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>274, :y=>604, :text=>"7 After ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## Conditional after and before text

8 Before
<:
true
::
8 During
:>
8 After

---
[Next](#)

<: 
```rb
    subject = args.outputs.primitives[2...5]
    expect = [{:x=>200, :y=>604, :text=>"8 Before ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>274, :y=>604, :text=>"8 During ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>349, :y=>604, :text=>"8 After ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## Single line string interpolation

Single line string interpolation is wrapped in `<:` and `:>` symbols.

<: "This text is conditional" :>

---
[Next](#)

<: 
```rb
    
    subject = args.outputs.primitives[2...4]
    expect = [{:x=>200, :y=>604, :text=>"Single line string interpolation is wrapped in `<:` and `:>` symbols. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>200, :y=>568, :text=>"This text is conditional ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## Multi line string interpolation

Multi line string interpolation has the `<:` on the preceding line and `:>` on the following line.

<:
"This text is conditional"
:>

---
[Next](#)

<:
```rb
    
    subject = args.outputs.primitives[2...4]
    expect = [{:x=>200, :y=>604, :text=>"Multi line string interpolation has the `<:` on the preceding line and `:>` on the following line. ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>200, :y=>568, :text=>"This text is conditional ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## String Interpolation requires a string expression {#string-interpolation-string-1}

If string interpolation returns a string, it is displayed. 

Example. The following line is displayed with String Interpolation.

<: "This line is displayed with String Interpolation" :>

---
[Next](#)



## String Interpolation requires a string expression {#string-interpolation-string-2}

If string interpolation returns a non-string. nothing is displayed.

Example. The following line returns a number so it is not displayed.

<: 1 :>

---
[Next](#)

## String Interpolation within a paragraph {#string-interpolation-in-para}

Strings can be interpolated within another string using single line breaks.

Example:

This is the first part.
<: "This is the second part." :>
This is the third part.

---
[Next](#)


## Conditional content {#conditional-content-1}

In a conditional content container, content appears if the condition is true.

Example. The following line appears because the condition is true.

<: 
  true 
:: 
  This line appears because the condition is true. 
:>

---
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

---
[Next](#)

## Conditional content within a paragraph {#conditional-content-in-paragraph-1}

Conditional content can be inserted into an existing paragraph.

Visible Example:

This is the first part.
<:
  true
::
  This is the second part.
:>
This is the third part.

---
[Next](#)

## Conditional content within a paragraph {#conditional-content-in-paragraph-2}

Invisible Example

One.
<:
false
::
Two.
:>
Three.

---
[Next](#)

## Conditional content within a paragraph {#conditional-content-in-paragraph-3}

Interpolation.

One part, 
<:
  "two part,"
:>
three part.

---
[Next](#)

## Conditional is empty except for a blank line

This test contains a conditional block. The condition evaluates to true but there is only a blank line in the true result. The result should not display so the very next thing should be the horizontal rule.

<:
```rb
  true
```
::

:>

---
[next](#)

## First line of conditional text is blank
Conditional result contains a blank line before the true result. This test is successful if the next line is "Success".
<:
```rb
  true
```
::

Success.
:>

---
[next](#)

## Conditional with blockquote, blank line, text
Conditional result contains a blockquote, a blank line and text.
<:
```rb
  true
```
::
  > Blockquote

Success if no blank line before this text.
:>

---
[Next](#)

## Conditional paragraph\block\paragraph

<:
true
::
Test Paragraph 1
[Test Block Element]()
Test Paragraph 2
:>

---
[Next]()

<: 
```rb
    
    subject = args.outputs.primitives[2...6]
    expect = [{:x=>200, :y=>604, :text=>"Test Paragraph 1 ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>200, :y=>528.2, :w=>182, :h=>34.0, :primitive_marker=>:sprite, :padding_left=>10, :padding_right=>10, :padding_top=>6, :padding_bottom=>6, :margin_left=>0, :margin_right=>0, :margin_top=>0, :margin_bottom=>0, :min_height=>0, :r=>102, :g=>102, :b=>102}, {:x=>210, :y=>556.2, :text=>"Test Block Element", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-bold.ttf", :size_enum=>0, :line_spacing=>1, :r=>51, :g=>51, :b=>51, :spacing_between=>0.25, :spacing_after=>0.7, :size_px=>22.0}, {:x=>200, :y=>512, :text=>"Test Paragraph 2 ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}]
    expect == subject ? "Test passed " : "Test failed"
```
:>

## Interpolation evaluates to empty string {#empty-string}

Forked should not attempt to display string interpolation if the result string is empty

:: $val = "" ::

Text before interpolation
<: $val :>

Paragraph after interpolation

---
[Next]()

<: 
```rb
    
    subject = args.outputs.primitives[2...5]
    expect = [{:x=>200, :y=>604, :text=>"Forked should not attempt to display string interpolation if the result string is empty ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>200, :y=>568, :text=>"Text before interpolation ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>200, :y=>533, :text=>"Para after ", :primitive_marker=>:label, :font=>"fonts/roboto/roboto-regular.ttf", :size_enum=>0, :line_spacing=>1, :r=>204, :g=>204, :b=>204, :spacing_between=>0.6, :spacing_after=>0.9, :size_px=>22.0}, {:x=>200, :y=>491.7999999999999, :w=>880, :h=>1, :primitive_marker=>:sprite, :r=>204, :g=>204, :b=>204, :weight=>3, :spacing_after=>11}]
```
:>