LOCATION=`echo $XDG_DATA_DIRS | cut -d ':' -f 1`
ln -s ~/.dotfiles/.theme-script/go-dark.sh $LOCATION/dark-mode.d/go-dark.sh
ln -s ~/.dotfiles/.theme-script/go-light.sh $LOCATION/light-mode.d/go-light.sh
systemctl --user enable --now darkman.service
