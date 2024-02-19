# Memo
:: 
autosave_off
clear_save_data
::

## Memo Commands
Memo is for storing useful textual information, such as your player's name or what pronouns they use to describe themself. You can use it to store any information you want check or reuse later in your story.

---
[Next](#)
[Restart Tests](#memo-commands)

## memo_add
Create a new memo called "test memo" with a value of "test value"

:: memo_add "test memo", "test value" ::



---
[Next](#)
[Restart Tests](#memo-commands)

## memo_check
Check the value of "test memo".

Value of "test memo" is "
<: (memo_check "test memo") + "\"." :>

---
[Next](#)
[Restart Tests](#memo-commands)


## memo_remove
Remove memo "test memo"

:: memo_remove "test memo" ::

Does the "test memo" exist?
<: (memo_check "test memo").nil? ? "No" : "Yes" :>

---
[Next](#)
[Restart Tests](#memo-commands)


## memo_clear

Add memo "monkey" with value "banana"
:: memo_add "monkey", "banana" ::

Now clear all memos
:: memo_clear ::

The current number of memos is
<: memo.count.to_s :>

---
<!-- [Next](#) -->
[Restart Tests](#memo-commands)
