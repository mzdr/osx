#!/usr/bin/env bash
# Thanks to https://mths.be/macos

count=1

# Script's color palette
reset="\033[0m"
highlight="\033[41m\033[97m"
dot="\033[33m▸ $reset"
dim="\033[2m"
bold="\033[1m"

# Current working directory
cwd=$(pwd)

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

headline() {
    printf "${highlight} %s ${reset}\n" "$@"
}

chapter() {
    echo -e "${highlight} $((count++)).) $@ ${reset}\n"
}

# Prints out a step, if last parameter is true then without an ending newline
step() {
    if [ $# -eq 1 ]
    then echo -e "${dot}$@"
    else echo -ne "${dot}$@"
    fi
}

run() {
    echo -e "${dim}▹ $@ $reset"
    eval $@
    echo ""
}


# Just a little welcome screen
echo ""
headline "                                                "
headline "        We are about to pimp your  Mac!        "
headline "     Follow the prompts and you’ll be fine.     "
headline "                                                "
echo ""

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
if [ $(sudo -n uptime 2>&1|grep "load"|wc -l) -eq 0 ]
then
    step "Some of these settings are system-wide, therefore we need your permission."
    sudo -v
    echo ""
fi

chapter "Adjusting general settings"

step "Setting your computer name (as done via System Preferences → Sharing)."
echo -ne "  What would you like it to be? $bold"
read computer_name
echo -e "$reset"
run sudo scutil --set ComputerName "'$computer_name'"
run sudo scutil --set HostName "'$computer_name'"
run sudo scutil --set LocalHostName "'$computer_name'"
run sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "'$computer_name'"

step "Disable OS X Gate Keeper?"
echo -n "  (You’ll be able to install any app you want from here on, not just Mac App Store apps) [Y/n]: "
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run sudo spctl --master-disable
        run sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
        ;;
esac

step "Disable the “Are you sure you want to open this application?” dialog? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.LaunchServices LSQuarantine -bool false
        ;;
esac

chapter "Adjusting HDD/SSD specific settings"

step "Disable the sudden motion sensor?"
echo -n "  (It’s not useful for SSDs) [Y/n]: "
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run sudo pmset -a sms 0
        ;;
esac

chapter "Adjusting input device settings"

step "Enable tap to click for this user and for the login screen? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
        run defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        run defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        ;;
esac

step "Enable full keyboard access for all controls?"
echo -n "  (e.g. enable Tab in modal dialogs) [Y/n]: "
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
        ;;
esac

step "Use scroll gesture with the Ctrl (^) modifier key to zoom? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
        run defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
        ;;
esac

step "Disable press-and-hold for keys in favor of key repeat? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
        ;;
esac

step "Set a blazingly fast keyboard repeat rate? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain KeyRepeat -int 1
        run defaults write NSGlobalDomain InitialKeyRepeat -int 10
        ;;
esac

step "Disable auto-correct? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
        ;;
esac

step "Stop iTunes from responding to the keyboard media keys? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null
        ;;
esac

chapter "Adjusting screen settings"

step "Disable shadow in screenshots? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.screencapture disable-shadow -bool true
        ;;
esac

chapter "Adjusting Finder settings"

step "Set Downloads as the default location for new Finder windows? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.finder NewWindowTarget -string '"PfLo"'
        run defaults write com.apple.finder NewWindowTargetPath -string "'file://${HOME}/Downloads/'"
        ;;
esac

step "Show icons for hard drives, servers, and removable media on the desktop? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
        run defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
        run defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
        run defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
        ;;
esac

step "Show all filename extensions? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
        ;;
esac

step "Keep folders on top when sorting by name? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.finder _FXSortFoldersFirst -bool true
        ;;
esac

step "Disable the warning when changing a file extension? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
        ;;
esac

step "Use list view in all Finder windows by default? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.finder FXPreferredViewStyle -string '"Nlsv"'
        ;;
esac

step "Enable AirDrop over Ethernet and on unsupported Macs running Lion? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true
        ;;
esac

step "Show the ~/Library folder? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run chflags nohidden ~/Library
        ;;
esac

step "Show the /Volumes folder? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run sudo chflags nohidden /Volumes
        ;;
esac

chapter "Adjusting Dock, Dashboard, and hot corners"

step "Set the icon size of Dock items to 36 pixels? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.dock tilesize -int 36
        ;;
esac

step "Automatically hide and show the Dock? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.dock autohide -bool true
        ;;
esac

step "Make Dock icons of hidden applications translucent? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.dock showhidden -bool true
        ;;
esac

chapter "Adjusting Mac App Store settings"

step "Enable the automatic update check? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
        ;;
esac

step "Check for software updates daily, not just once per week? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
        ;;
esac

step "Download newly available updates in background? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
        ;;
esac

step "Install System data files & security updates? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
        ;;
esac

step "Turn on app auto-update? [Y/n]: " ""
case $(read choice; echo $choice) in
    [nN] )
        echo ""
        ;;
    [yY] | * )
        echo ""
        run defaults write com.apple.commerce AutoUpdate -bool true
        ;;
esac

chapter "Restoring app settings"

step "Linking dotfiles"
run ln -sfv $cwd/.zshrc ~
run ln -sfv $cwd/.zpreztorc ~
run ln -sfv $cwd/.gitconfig ~
run mkdir ~/.atom
run ln -sfv $cwd/.atom/config.cson ~/.atom
run ln -sfv $cwd/.atom/keymap.cson ~/.atom
run ln -sfv $cwd/.atom/snippets.cson ~/.atom
run ln -sfv $cwd/.atom/toolbar.cson ~/.atom
run ln -sfv $cwd/.atom/styles.less ~/.atom
run ln -sfv $cwd/.iTerm2 ~

chapter "Installing…"

step "Homebrew"
run '/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

step "CLI apps"

run brew install \
    composer \
    git \
    mas \
    node \
    z

step "Desktop apps"

run cask install \
    1clipboard \
    atom \
    dropbox \
    enpass \
    firefox \
    google-chrome \
    harvest \
    iterm2 \
    opera \
    sequel-pro \
    shiori \
    slack \
    spectacle \
    vlc

step "Fonts"

run brew tap caskroom/fonts
run cask install \
    font-fira-code \
    font-camingocode \
    font-inconsolata \
    font-anonymous-pro

# step "(Web) Development setup"
# run brew tap homebrew/php
# run brew install nginx mysql php71
# run sudo cp -vR $cwd/etc/nginx /etc

step "Atom packages/themes"

run apm install \
    emmet \
    file-icons \
    docblockr \
    sort-lines \
    todo-show \
    pigments \
    color-picker \
    highlight-selected \
    html-head-snippets \
    pretty-json \
    tool-bar \
    git-control \
    native-ui \
    colornamer \
    project-manager \
    flex-tool-bar
