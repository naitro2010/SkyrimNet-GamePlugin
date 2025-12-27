Scriptname UITextEntryMenu extends UIMenuBase

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.textEntry." autoReadonly

string _internalString = ""
string _internalResult = ""
string _clipboard = ""

; Layout persistence (saved with game)
float _menuPosX = 0.0
float _menuPosY = 0.0
float _menuScale = 100.0
float _fontSize = 18.0
float _bgAlpha = 100.0

string Function GetMenuName()
    return "UITextEntryMenu"
EndFunction

string Function GetResultString()
    return _internalResult
EndFunction

Function SetPropertyString(string propertyName, string value)
    If propertyName == "text"
        _internalString = value
    Endif
EndFunction

Function ResetMenu()
    isResetting = true
    _internalString = ""
    _internalResult = ""
    isResetting = false
EndFunction

int Function OpenMenu(Form inForm = None, Form akReceiver = None)
    _internalResult = ""

    If !BlockUntilClosed() || !WaitForReset()
        return 0
    Endif

    RegisterForModEvent("UITextEntryMenu_LoadMenu", "OnLoadMenu")
    RegisterForModEvent("UITextEntryMenu_CloseMenu", "OnUnloadMenu")
    RegisterForModEvent("UITextEntryMenu_TextChanged", "OnTextChanged")
    RegisterForModEvent("UITextEntryMenu_ClipboardChanged", "OnClipboardChanged")
    RegisterForModEvent("UITextEntryMenu_LayoutChanged", "OnLayoutChanged")
    RegisterForModEvent("UITextEntryMenu_FontSizeChanged", "OnFontSizeChanged")
    RegisterForModEvent("UITextEntryMenu_BgAlphaChanged", "OnBgAlphaChanged")
    ;RegisterForModEvent("UITextEntryMenu_Debug", "OnDebug")

    Lock()
    UI.OpenCustomMenu("textentrymenu")
    If !WaitLock()
        return 0
    Endif
    return 1
EndFunction

Event OnLoadMenu(string eventName, string strArg, float numArg, Form formArg)
    UpdateTextEntryString()
    UI.InvokeString(ROOT_MENU, MENU_ROOT + "setClipboard", _clipboard)
    ; Restore saved layout
    RestoreLayout()
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
    UnregisterForModEvent("UITextEntryMenu_LoadMenu")
    UnregisterForModEvent("UITextEntryMenu_CloseMenu")
    UnregisterForModEvent("UITextEntryMenu_TextChanged")
    UnregisterForModEvent("UITextEntryMenu_ClipboardChanged")
    UnregisterForModEvent("UITextEntryMenu_LayoutChanged")
    UnregisterForModEvent("UITextEntryMenu_FontSizeChanged")
    UnregisterForModEvent("UITextEntryMenu_BgAlphaChanged")
    ;UnregisterForModEvent("UITextEntryMenu_Debug")
EndEvent

Event OnTextChanged(string eventName, string strArg, float numArg, Form formArg)
    _internalResult = strArg
    Unlock()
EndEvent

Event OnClipboardChanged(string eventName, string strArg, float numArg, Form formArg)
    _clipboard = strArg
EndEvent

Function UpdateTextEntryString()
    UI.InvokeString(ROOT_MENU, MENU_ROOT + "setTextEntryMenuText", _internalString)
EndFunction

Function RestoreLayout()
    ; Restore position, scale, and font size from saved values
    If _menuPosX != 0.0 || _menuPosY != 0.0
        float[] posArgs = new float[2]
        posArgs[0] = _menuPosX
        posArgs[1] = _menuPosY
        UI.InvokeFloatA(ROOT_MENU, MENU_ROOT + "setMenuPosition", posArgs)
    EndIf
    If _menuScale != 100.0 && _menuScale > 0.0
        UI.InvokeFloat(ROOT_MENU, MENU_ROOT + "setMenuScale", _menuScale)
    EndIf
    If _fontSize != 18.0 && _fontSize > 0.0
        UI.InvokeFloat(ROOT_MENU, MENU_ROOT + "setFontSize", _fontSize)
    EndIf
    If _bgAlpha != 100.0 && _bgAlpha >= 0.0
        UI.InvokeFloat(ROOT_MENU, MENU_ROOT + "setBackgroundAlpha", _bgAlpha)
    EndIf
    ; Show menu after layout is restored (menu starts hidden)
    UI.Invoke(ROOT_MENU, MENU_ROOT + "showMenu")
EndFunction

Event OnLayoutChanged(string eventName, string strArg, float numArg, Form formArg)
    ; Parse "posX,posY,scale" format using SKSE StringUtil
    int comma1 = StringUtil.Find(strArg, ",")
    If comma1 >= 0
        string first = StringUtil.Substring(strArg, 0, comma1)
        string rest = StringUtil.Substring(strArg, comma1 + 1)
        int comma2 = StringUtil.Find(rest, ",")
        If comma2 >= 0
            string second = StringUtil.Substring(rest, 0, comma2)
            string third = StringUtil.Substring(rest, comma2 + 1)
            _menuPosX = first as float
            _menuPosY = second as float
            _menuScale = third as float
        EndIf
    EndIf
EndEvent

Event OnFontSizeChanged(string eventName, string strArg, float numArg, Form formArg)
    _fontSize = numArg
EndEvent

Event OnBgAlphaChanged(string eventName, string strArg, float numArg, Form formArg)
    _bgAlpha = numArg
EndEvent

Event OnDebug(string eventName, string strArg, float numArg, Form formArg)
    Debug.Trace("[UITextEntryMenu] " + strArg)
EndEvent