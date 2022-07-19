
#echo ".bash_profile running..."
#.bash_profile is read and executed when Bash is invoked as an interactive login shell, while .bashrc is executed for an interactive non-login shell.
#
# Use .bash_profile to run commands that should run only once, such as customizing the $PATH environment variable .
#
#Put the commands that should run every time you launch a new shell in the .bashrc file. This include your aliases and functions , custom prompts, history customizations , and so on.
#


if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

eval "$(/opt/homebrew/bin/brew shellenv)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/samfiechter/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/samfiechter/miniforge3/etc/profile.d/conda.sh" ]; then
#         . "/Users/samfiechter/miniforge3/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/samfiechter/miniforge3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# <<< conda initialize <<<




case $TERM in
    dumb*)
	echo "Dumb Term..."	    
	#	    . $HOME/bin/motd.sh
        ;;
    screen*)
	#shouldn't run .bash_profile, just .bashrc
	;;
    *)
	#change user@host in screen hardstatus
	export OLDTERM=$TERM
        screen -A -d -R -S $TERM  || screen -r
        exit
        logout
        ;;
    
esac

