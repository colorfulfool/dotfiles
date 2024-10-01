if [ -z $1 ]; then 
	echo "Usage: migrate.sh nvim"
	exit 1 
fi

mv $1 $1-inner
mkdir -p $1/.config
mv $1-inner $1/.config/$1

stow -Rvn $1

read -p "Okay to run that? [y/n] " answer
if [[ answer == "y" ]]; then
	stow -Rv $1
fi
