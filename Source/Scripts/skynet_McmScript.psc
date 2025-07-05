Scriptname skynet_McmScript extends SKI_ConfigBase

int toggleShowWebUi

int useImage

event OnConfigOpen()
    
    Pages = new string[2]

    Pages[0] = "Overview"
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
    
    if page == "Overview"
        DisplayOverview()
    elseif page == "SkyrimNet Status"
        DisplayStatus()
    else
        ; Default to Overview page
        DisplayOverview()
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

function DisplayOverview()

    AddHeaderOption("Overview")
    AddHeaderOption("")

    toggleShowWebUi = AddTextOption("Click here to view Web UI", "")

endfunction

function DisplayStatus()

    AddHeaderOption("SkyrimNet Status")
    AddHeaderOption("")
    
    ; Display build information
    string version = SkyrimNetApi.GetBuildVersion()
    string buildType = SkyrimNetApi.GetBuildType()
    
    AddTextOption("Version:", version)
    AddTextOption("Build Type:", buildType)
    
    ; Add more status information here as needed
    ; For example: uptime, connected status, etc.

endfunction

event OnOptionSelect(int option)

    if option == toggleShowWebUi
        int result = SkyrimNetApi.OpenSkyrimNetUI()
        Debug.Trace("[SkyrimNetInternal] OpenSkyrimNetUI result: " + result)
    endif

endevent