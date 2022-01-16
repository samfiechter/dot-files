#
#.bash_profile is read and executed when Bash is invoked as an interactive login shell, while .bashrc is executed for an interactive non-login shell.
#
# Use .bash_profile to run commands that should run only once, such as customizing the $PATH environment variable .
#
#Put the commands that should run every time you launch a new shell in the .bashrc file. This include your aliases and functions , custom prompts, history customizations , and so on.
#
#

if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

if [ "screen" != "$TERM" ] ; then
    case $TERM in
        dumb*)
	    echo "Dumb Term..."
	    export PAGER=cat
            TITLEBAR=''
            PS1='\w [\t] '
#	    . $HOME/bin/motd.sh
            ;;
        *)
	    export EDITOR=emacs
	    export PAGE=less
            export OLDTERM=$TERM
            screen -A -d -R -S $TERM  || screen -r
            exit
            logout
            ;;
    esac
fi



