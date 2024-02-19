# Comments

## Comment tests

Text marked as a comment is ignored when parsing the Story File and will not be displayed by Forked. It is useful for make notes in the code that should not be shown to the player but that may be helpful for the writer or other people reading the code.

Comments come in two forms, the first is a simple C-style comment that is easy to type:
~~~
// this line is a comment

a = 1 // this is an inline comment
~~~

The second form is an HTML-style comment. This may be preferable if you are using a code editor that supports MarkDown. For example, in Visual Studio code, pressing (Windows) `CTRL-/` or (Mac) `CMD-/` in a `.md` file will convert selected line or lines to this style of comment.

Note that unlike the C-style comment, the HTML-style comment can run over multiple lines and must be closed.

~~~~~~~~~~~~~
<!-- this is an HTML-style comment -->
~~~~~~~~~~~~~
---

[Next](#)


## Full line C-style comment {#c-line}

Line A: The following line (Line B) should not be displayed.

// Line B: This line is a comment

Line C: The previous line (Line B) should not be displayed.

---
[Next](#)


## Inline C-style comment {#c-inline}

This line ends right here // this part of the line should not display

---
[Next](#)


## Single line HTML-style comment {#html-single-line}

Line A: The following line (Line B) should not be displayed.

<!-- Line B: This line is a comment -->

Line C: The previous line (Line B) should not be displayed.

---
[Next](#)



## Multi-line HTML-style comment {#html-multi-line}

Line A: The following lines (Lines B, C and D) should not be displayed.

<!-- Line B: This line is the start of a comment 
Line C: This line is part of a comment
Line D: This line is part of a comment -->

Line E: The previous lines (Line B, C and D) should not be displayed.

---
[Next](#)



## Inline HTML-style comment {#html-inline}

(A) This line has part A and C, it skips part B. <!-- (B) this part of the line should not display --> (C) This is part C.

---
[Next](#)

<!-- ## Ignored Chunk {#html-ignored}
This entire chunk is ignored. The following Ruby code will cause an exception if this chunk is loaded.
:: raise("This code shall not pass! This error means the parser failed to ignore this commented code.") :: -->

## Not ignored {#html-ignored}
If we make it here, it means the previous commented out chunk was successfully ignored.