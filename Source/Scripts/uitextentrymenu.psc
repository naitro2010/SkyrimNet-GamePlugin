Scriptname UITextEntryMenu extends UIMenuBase

string property		ROOT_MENU		= "CustomMenu" autoReadonly
string Property 	MENU_ROOT		= "_root.textEntry." autoReadonly

string _internalString = ""
string _internalResult = ""
string _clipboard = ""

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
EndEvent

Event OnUnloadMenu(string eventName, string strArg, float numArg, Form formArg)
    UnregisterForModEvent("UITextEntryMenu_LoadMenu")
    UnregisterForModEvent("UITextEntryMenu_CloseMenu")
    UnregisterForModEvent("UITextEntryMenu_TextChanged")
    UnregisterForModEvent("UITextEntryMenu_ClipboardChanged")
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