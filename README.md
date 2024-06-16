# DarkMsgBox
> [!NOTE]  
> This is for ahk [v2-alpha.13+](https://www.autohotkey.com/docs/alpha/ChangeLog.htm#v2.1-alpha.13) users.  
> If you are using ahk v2.0.x, please [click here](https://github.com/nperovic/DarkMsgBox).

![DarkMode_MsgBox](https://github.com/nperovic/DarkMsgBox/assets/122501303/cd0a25de-54fc-42e1-b0e1-56b373c5ce29)

![DarkMode_InputBox](https://github.com/nperovic/DarkMsgBox/assets/122501303/a986b964-f98f-4d5a-a44a-f79db4d94b07)

## How To Use
### Include `Dark_MsgBox.ahk`
Learn more about `#Include`: [AHK Official Document](https://www.autohotkey.com/docs/alpha/lib/_Include.htm)
```php
#Requires AutoHotkey v2
#Include <Dark_MsgBox>
```

### Basic Uses
```py
IB := InputBox("Please enter a phone number.", "Phone Number", "w300 h200")
if (IB.Result = "Cancel")
    MsgBox "You entered '" IB.Value "' but then cancelled.",, 0x1
else
    MsgBox "You entered '" IB.Value "'.", , 0x1
```

### Add Icon
> It has to be `MsgBox.Call` for setting icons.
```py
MsgBox.Call("123456", "Title", "CTC", "copilot.ico")
```
> For further details, please refer to the official document: [CLICK HERE](https://www.autohotkey.com/docs/v2/lib/MsgBox.htm)
