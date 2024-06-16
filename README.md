# DarkMsgBox
![DarkMode_MsgBox](https://github.com/nperovic/DarkMsgBox/assets/122501303/cd0a25de-54fc-42e1-b0e1-56b373c5ce29)

![DarkMode_InputBox](https://github.com/nperovic/DarkMsgBox/assets/122501303/a986b964-f98f-4d5a-a44a-f79db4d94b07)

## How To Use
### Basic
```py
#Requires AutoHotkey v2
#Include Dark_MsgBox_v2.ahk

IB := InputBox("Please enter a phone number.", "Phone Number", "w300 h200")
if (IB.Result = "Cancel")
    MsgBox "You entered '" IB.Value "' but then cancelled.",, 0x1
else
    MsgBox "You entered '" IB.Value "'.", , 0x1
```

### Add Icon
> It has to be `MsgBox.Call` for setting icons.
```py
#Requires AutoHotkey v2
#include <Dark_MsgBox>

MsgBox.Call("123456", "Title", "CTC", "copilot.ico")
```
> For further details, please refer to the official document: [CLICK HERE](https://www.autohotkey.com/docs/v2/lib/MsgBox.htm)
