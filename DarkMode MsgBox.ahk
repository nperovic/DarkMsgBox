#Requires AutoHotkey v2.1-alpha.9

class RECT  {
    left  : i32
    top   : i32
    right : i32
    bottom: i32
}

class __MsgBox
{
    static __New()
    {
        /** Thanks to geekdude & Mr Doge for providing this method to rewrite built-in functions. */
        nativeMsgbox := MsgBox.Call.Bind(MsgBox)
        MsgBox.DefineProp("Call", {Call: (dropThis, args*) => MsgBoxEx(args*)})

        MsgBoxEx(args*)
        {
            static WM_COMMNOTIFY := 0x44
            winTitle := Format("{1} ahk_class #32770", title?)
            static textHwnd := 0
            static btnHwnd  := 0

            WM_COMMAND    := 0x0111
            WM_COMMNOTIFY := 0x44
            WM_USER       := 0x0400
            WM_INITDIALOG := 0x0110
            WM_APPCOMMAND := 0x0319

            OnMessage(WM_COMMNOTIFY, ON_WM_COMMNOTIFY, -1)
            DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

            return nativeMsgbox(args*)
            
            ON_WM_COMMNOTIFY(wParam, lParam, msg, hwnd)
            {
                DetectHiddenWindows(true)
                DetectHiddenText(true)

                if msg != 68 || wParam != 1027
                    return

                EnumThreadWindows(GetCurrentThreadId(), 
                    CallbackCreate((hwnd, *) {
                        static WS_EX_COMPOSITED := 0x02000000
                        Critical()
                        SetWinDelay(-1)
                        SetControlDelay(-1)
                        DetectHiddenWindows(1)
                        DetectHiddenText(1)

                        if !WinExist("ahk_class #32770 ahk_id" hwnd) 
                            return 1

                        OnMessage(0x44, ON_WM_COMMNOTIFY, 0)
                        WinSetExStyle("+" WS_EX_COMPOSITED)

                        DwmSetWindowAttribute(hwnd, 2, 2)
                        DwmSetWindowAttribute(hwnd, 4, 0)
                        DwmSetWindowAttribute(hwnd, 10, 1)
                        DwmSetWindowAttribute(hwnd, 17, 1)
                        DwmSetWindowAttribute(hwnd, 20, true)
                        DwmSetWindowAttribute(hwnd, 38, 2)
                        DwmSetWindowAttribute(hwnd, 34, 0xFFFFFFFE)
                        DwmSetWindowAttribute(hwnd, 35, 0x2b2b2b)

                        GWL_WNDPROC(hwnd)
                        return 0
                }), 0)
            }
        }

        GWL_WNDPROC(_WinTitle:= "", btnHwnd?)
        {
            static SetWindowLong        := DllCall.Bind(A_PtrSize = 8 ? "SetWindowLongPtr" : "SetWindowLong", "ptr",, "int",, "ptr",, "ptr")
            static WM_CTLCOLORBTN       := 0x0135
            static WM_CTLCOLORDLG       := 0x0136
            static WM_CTLCOLORSTATIC    := 0x0138
            static WM_CLOSE             := 0x0010
            static WM_DESTROY           := 0x0002
            static WM_PAINT             := 0x000F

            DetectHiddenWindows(1)
            winId := WinExist(_WinTitle)
            
            DllCall("SetThreadDpiAwarenessContext", "ptr", -4, "ptr")

            for ctrl in WinGetControlsHwnd(winId) {
                SetWindowTheme(ctrl, "DarkMode_Explorer")
                if InStr(ControlGetClassNN(ctrl), "Button") {
                    ControlSetStyle("+0x4000000" , ctrl)
                    btnHwnd := ctrl
                }
            }

            WindowProcNew := CallbackCreate(WNDPROC)
            WindowProcOld := SetWindowLong(_WinTitle, -4, WindowProcNew)
            
            SetWindowLongPtrW(hWnd, nIndex, dwNewLong) => DllCall("SetWindowLongPtrW", "ptr", hWnd, "int", nIndex, "ptr", dwNewLong, "ptr")

            dc       := ""
            brush    := ""
            DC_BRUSH := ""

            WNDPROC(hwnd, uMsg, wParam, lParam)
            {
                Critical(-1)
                DetectHiddenWindows(1)
                DetectHiddenText(1)
                
                switch uMsg {
                case WM_CTLCOLORSTATIC: 
                {
                    if !DC_BRUSH
                        DC_BRUSH := DllCall("CreateSolidBrush", "UInt", 0x2b2b2b)

                    SelectObject(wParam, DC_BRUSH)
                    SetBkMode(wParam, 1)
                    SetTextColor(wParam, 0xFFFFFF)
                    SetBkColor(wParam, 0x2b2b2b)
                    return DC_BRUSH
                }
                case WM_CTLCOLORBTN: 
                {
                    if !brush
                        brush := CreateSolidBrush(0x202020)
                    SelectObject(wParam, brush)
                    SetBkMode(wParam, 1)
                    SetTextColor(wParam, 0xFFFFFF)
                    SetBkColor(wParam, 0x2b2b2b)
                    return DC_BRUSH
                }
                case WM_CTLCOLORDLG: 
                {
                    if !brush
                        brush := CreateSolidBrush(0x202020)

                    if !DC_BRUSH
                        DC_BRUSH := DllCall("CreateSolidBrush", "UInt", 0x2b2b2b)

                    dc := GetWindowDC(_WinTitle)
                    GetClientRect(_WinTitle, rcW := RECT())
                    GetClientRect(btnHwnd, rcBtn := RECT())

                    height        := (rcBtn.Bottom-rcBtn.Top)
                    rcFill        := RECT()
                    rcFill.Top    := rcW.Bottom-height
                    rcFill.Left   := rcW.Left
                    rcFill.Right  := rcW.Right+10
                    rcFill.Bottom := rcW.Bottom+100

                    FillRect(dc, rcFill, brush)
                    ReleaseDC(_WinTitle, dc)

                    return DC_BRUSH
                }
                case WM_CLOSE, WM_DESTROY: 
                {
                    if DC_BRUSH {
                        DeleteObject(DC_BRUSH)
                        DC_BRUSH := ""
                    }
                    if brush {
                        DeleteObject(brush)
                        brush := ""
                    }
                }}
                
                return CallWindowProc(WindowProcOld, hwnd, uMsg, wParam, lParam) 
            }
        }

        SetTextColor(hdc, crColor) => DllCall('Gdi32\SetTextColor', 'ptr', hdc, 'uint', crColor, 'uint')

        SetBkMode(hdc, iBkMode) => DllCall('Gdi32\SetBkMode', 'ptr', hdc, 'int', iBkMode, 'int')

        SelectObject(hdc, hgdiobj) => DllCall('Gdi32\SelectObject', 'ptr', hdc, 'ptr', hgdiobj, 'ptr')

        SetBkColor(hdc, crColor) => DllCall('Gdi32\SetBkColor', 'ptr', hdc, 'uint', crColor, 'uint')

        CreateSolidBrush(crColor) => DllCall('Gdi32\CreateSolidBrush', 'uint', crColor, 'ptr')

        GetWindowDC(hwnd) => DllCall("User32\GetWindowDC", "ptr", hwnd, "ptr")

        GetClientRect(hWnd, lpRect) => DllCall("User32\GetClientRect", "ptr", hWnd, "ptr", lpRect, "int")

        ReleaseDC(hWnd, hDC) => DllCall("User32\ReleaseDC", "ptr", hWnd, "ptr", hDC, "int")

        FillRect(hDC, lprc, hbr) => DllCall("User32\FillRect", "ptr", hDC, "ptr", lprc, "ptr", hbr, "int")

        EnumThreadWindows(dwThreadId, lpfn, lParam) => DllCall("User32\EnumThreadWindows", "uint", dwThreadId, "ptr", lpfn, "uptr", lParam, "int")

        GetCurrentThreadId() => DllCall("Kernel32\GetCurrentThreadId", "uint")

        SetWindowTheme(hwnd, pszSubAppName, pszSubIdList := "") => (!DllCall("uxtheme\SetWindowTheme"
				, "ptr", hwnd
				, "ptr", StrPtr(pszSubAppName)
				, "ptr", pszSubIdList ? StrPtr(pszSubIdList) : 0) ? true : false)

        CallWindowProc(lpPrevWndFunc, hWnd, uMsg, wParam, lParam) => DllCall("CallWindowProc", "Ptr", lpPrevWndFunc, "Ptr", hwnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)

        DeleteObject(hObject) => DllCall('Gdi32\DeleteObject', 'ptr', hObject, 'int')

        DWMSetWindowAttribute(hwnd, dwAttribute, pvAttribute, cbAttribute := 4) => 
            DllCall("Dwmapi\DwmSetWindowAttribute"
                , "Ptr" , hwnd
                , "UInt", dwAttribute
                , "Ptr*", &pvAttribute
                , "UInt", cbAttribute)
    }
}

/* Example

MsgBox("hello world", "TITLE")
ExitApp()