Scriptname skynet_McmScript extends SKI_ConfigBase

int toggleShowWebUi

int useImage

event OnConfigOpen()
    
    Pages = new string[2]

    Pages[0] = "Settings"
    Pages[1] = "SkyrimNet Status"

endevent

event OnPageReset(string page)

    SetCursorFillMode(LEFT_TO_RIGHT)
    SetCursorPosition(0)

    if page == ""
        DisplaySplashScreen()
    else
        UnloadCustomContent()
    endif
    
    if page == "Settings"
        DisplaySettings()
    elseif page == "SkyrimNet Status"
        DisplayStatus()
    endif

endevent

function DisplaySplashScreen()

    if useImage == 0
        LoadCustomContent("SkyrimNet/Skyrimnet1.dds")
        useImage = 1
    else
        LoadCustomContent("SkyrimNet/Skyrimnet2.dds")
        useImage = 0
    endif

endfunction

function DisplaySettings()

    AddHeaderOption("Settings")
    AddHeaderOption("")

    toggleShowWebUi = AddTextOption("Click here to view Web UI", "")

endfunction

function DisplayStatus()

    AddHeaderOption("SkyrimNet Status")
    AddHeaderOption("")

endfunction

event OnOptionSelect(int option)

    if option == toggleShowWebUi
        int result = SkyrimNetApi.OpenSkyrimNetUI()
        Debug.Trace("[SkyrimNetInternal] OpenSkyrimNetUI result: " + result)
    endif

endevent