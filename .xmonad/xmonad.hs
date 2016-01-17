import XMonad
import XMonad.Config.Azerty
import XMonad.Util.EZConfig
import XMonad.Actions.CycleWS
import XMonad.Layout.FixedColumn
import XMonad.Layout.ShowWName
import XMonad.Layout.PerWorkspace
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.NoBorders
import XMonad.Prompt
import XMonad.Prompt.XMonad
import XMonad.Prompt.Shell
import XMonad.Layout.Monitor
import XMonad.Layout.LayoutModifier
import XMonad.Hooks.Script
import System.Exit

-- Define the colors that will be used.
backColor = "#202020"
selColor = "#4b6983"
popupColor = "#7ec0ee"

-- The Mod key will be rebound to the Windows key.
myModMask = mod4Mask

-- The default key binding will be modified for AZERTY keyboards.
myKeys = azertyKeys <+> keys defaultConfig

-- The following font will be used for dmenu.
dmenuFont = "Inconsolata-26"

-- The following font will be used for displaying the workspace names.
showWNameFont = "-*-lucidatypewriter-*-*-*-*-26-*-*-*-*-*-*-*"

-- Specific options will be applied to dmenu (the -b option causes dmenu to
-- show up at the bottom of the screen instead of at the top).
dmenuOptions = "-b -fn " ++ dmenuFont ++ " -nb '" ++ backColor ++ "' -nf '"
    ++ selColor ++ "' -sb '" ++ backColor ++ "' -sf '" ++ popupColor ++ "'"
dmenuCommand = "exe=`dmenu_run " ++ dmenuOptions ++ "` && eval \"exec $exe\""

-- Some key bindings will be added to allow the user to cycle through the
-- non-empty workspaces (using Mod key + left/right arrow).
-- The mod-p binding will be modified to apply the dmenu options.
-- The mod-space binding will be modified. If it is not modified, cycling
-- through the layouts won't work.
-- The mod-x binding will be added to start the shell prompt.
-- The mod-shift-q and mod-q bindings will be modified to start a "system" menu
-- (Shutdown / Reboot / Exit / Lock / Restart XMonad).
-- The mod-shift-m binding will be added to show the title currently played by
-- moc.
systemPromptCmds = [
        ("Shutdown", spawn "sudo poweroff"),
        ("Reboot", spawn "sudo reboot"),
        ("Exit", io $ exitWith ExitSuccess),
        ("Lock", spawn "xtrlock -b"),
        ("Restart", restart "xmonad" True)
    ]
mocMessageCmd = "xmessage -geometry 1300x68+300+600 "
    ++ "$(mocp -i|grep ^Title|"
    ++ "sed 's/^Title:\\s*[0-9]\\+\\s*//')"
newKeys = [
        ((myModMask, xK_Right), moveTo Next NonEmptyWS),
        ((myModMask, xK_Left), moveTo Prev NonEmptyWS),
        ((myModMask, xK_p), spawn dmenuCommand),
        ((myModMask, xK_space), sendMessage ToggleLayout),
        ((myModMask, xK_x), shellPrompt defaultXPConfig),
        ((myModMask .|. shiftMask, xK_q),
            xmonadPromptC systemPromptCmds defaultXPConfig),
        ((myModMask, xK_q),
            xmonadPromptC systemPromptCmds defaultXPConfig),
        ((myModMask .|. shiftMask, xK_m),
            spawn mocMessageCmd)
    ]

-- The color of the window borders will be modified.
myFocusedBorderColor = selColor
myNormalBorderColor  = backColor

-- The width of the window borders will be modified.
myBorderWidth = 3

-- Every one of the nine workspaces will have a name.
myWorkSpaces = [
        "1:mail",
        "2:web",
        "3:chat",
        "4:image1",
        "5:image2",
        "6:edit1",
        "7:edit2",
        "8:edit3",
        "9:edit4"
    ]

-- If running, dclock will be displayed in the upper right corner of the
-- screen, assuming a 1920 pixel wide screen.
screenWidth = 1920
clockWidth = 92
clockHeight = 44
clockLeft = fromIntegral (screenWidth - clockWidth)
clockTop = 0
clockMonitor = monitor {
        prop = ClassName "Dclock",
        rect = Rectangle clockLeft clockTop clockWidth clockHeight,
        name = "dclock"
    }

-- Some applications will be automatically moved to particular workspaces when
-- they are launched. Moreover, GIMP and xmessage are moved to the floating
-- layer.
myManageHook = composeAll [
        className =? "Claws-mail" --> doShift (myWorkSpaces !! 0),
        className =? "Gajim" --> doShift  (myWorkSpaces !! 2),
        className =? "Gimp" --> doShift (myWorkSpaces !! 4),
        className =? "Gimp" --> doFloat,
        className =? "Xzgv" --> doShift (myWorkSpaces !! 3),
        className =? "Iceweasel" --> doShift (myWorkSpaces !! 1),
        className =? "Xmessage" --> doFloat
   ] <+> manageMonitor clockMonitor

-- The name of the destination workspace will be briefly displayed when
-- switching between workspaces.
myShowWName = showWName' defaultSWNConfig {
    swn_color = popupColor,
    swn_font = showWNameFont,
    swn_fade = 0.5
}

-- In all the edit workspaces, the master pane will be 163 columns wide (163
-- is the number of columns used by Vim when the Vim window is vertically split
-- in two editing windows, separated by the split separator (one column wide),
-- and with foldcolumn set to 1). In the other workspaces, the master pane
-- will be 80 columns wide. In every workspace, it will be possible to switch
-- to the Full layout (without window border).
myLayout = myShowWName (ModifiedLayout clockMonitor
        $ toggleLayouts (noBorders Full) perWorkspace)
    where
        perWorkspace =
            onWorkspace (myWorkSpaces !! 5) master163ColLayout
            $ onWorkspace (myWorkSpaces !! 6) master163ColLayout
            $ onWorkspace (myWorkSpaces !! 7) master163ColLayout
            $ onWorkspace (myWorkSpaces !! 8) master163ColLayout
            $ master80ColLayout

        master80ColLayout = FixedColumn 1 0 80 8

        master163ColLayout = FixedColumn 1 0 163 16

-- The script .xmonad/hooks will be executed on startup. It launches:
-- - dclock,
-- - claws-mail,
-- - iceweasel.
-- If these applications are not installed or already run by the run, they are
-- not launched by the script.
-- If you don't want one or all of these applications to be launched, please
-- run the script .xmonad/hooks with the --help option to see how to prevent
-- the applications from being launched (through environment variables
-- definitions).
myStartupHook = execScriptHook "startup"

-- Apply the changes.
main = xmonad $ defaultConfig {
    modMask = myModMask,
    workspaces = myWorkSpaces,
    keys = myKeys,
    borderWidth = myBorderWidth,
    focusedBorderColor = myFocusedBorderColor,
    normalBorderColor = myNormalBorderColor,
    layoutHook = myLayout,
    manageHook = myManageHook,
    startupHook = myStartupHook
} `additionalKeys` newKeys
