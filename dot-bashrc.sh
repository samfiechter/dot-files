# ~/.bashrc: executed by bash(1) for non-logisn shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
#~ [09:37:51] ln -s src/dot-bash/bashrc.sh .bashrc


# remove dups from path...
function unique_path {
    echo $1 | tr ":" "\n" | sort | uniq | tr "\n" ":"
}


export PATH=`unique_path "/sbin:/usr/local/bin:/usr/local/sbin:${PATH}:.:${HOME}/bin"`

#export INCLUDE=`unique_path $INCLUDE:/usr/X11/include`
#export LIBS=`unique_path $LIBS:/usr/X11/lib:`
#export LIBRARY_PATH=${LIBRARY_PATY}:$LIBS
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$LIBS

# for examples

if [ "screen" == "$TERM" ] ; then
    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    if [ -n "$force_color_prompt" ]; then
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
            # We have color support; assume it's compliant with Ecma-48
            # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
            # a case would tend to support setf rather than setaf.)
            color_prompt=yes
        else
            color_prompt=
        fi
        color_prompt=yes;

    else
        unset color_prompt force_color_prompt
    fi
    
    # set a fancy prompt (non-color, unless we know we "want" color)
    case "$OLDTERM" in
        xterm*)
            export color_prompt=yes;
            export GNUTERM=X11;
            PS1='${TITLEBAR}\[\033k ${USER}@${HOSTNAME}\033\\\] \w [\t] '
	    export CLICOLOR=cons25;
            ;;
        *)
            TITLEBAR=''
            PS1='\w [\t] '
            ;;
    esac
    . $HOME/bin/motd.sh
else
    case $TERM in
        dumb*)
            export PAGER=cat
            TITLEBAR=''
            PS1='\w [\t] '
	    . $HOME/bin/motd.sh
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

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

# enable color support of ls and also add handy aliases
unset LANG


alias eamcs="emacs"
alias emcas="emacs"

#alias pi="lpr -H 192.168.100.2 -o raw ~scf/bin/sihp1000.img"
alias undos="tr '\r' '\n'"
alias whatsup="nmap -sP -T5 `ifconfig | grep "Bcast:"| sed 's/.*Bcast:\([^ ]*\).*/\1/' | sed 's/255/*/'`"
#alias gsp="gs -q -r600 -g4736x6817 -sDEVICE=pbmraw -sOutputFile=- -dNOPAUSE -dBATCH"
function kill_prg {
if [ "" != "$1"]
then 
    ps aux | grep $1 | grep -v grep | tr -s " " | cut -s -f 2 -d " " | xargs -n 1 -x kill
else 
    echo "kill_prg: Name"
fi
}

alias gitit='git commit -a -m "`date`"; git push'
alias perlinstall='perl -MCPAN -e shell'
alias ls='/bin/ls -h -G'
alias ll='/bin/ls -lha -G'
alias la='/bin/ls -ahl -G'
alias rt='ls -a | grep -E "(\#.*\#|.*~)" | xargs -n 1 -x rm'

weather(){ wget -q -O- "http://api.wunderground.com/auto/wui/geo/ForecastXML/index.xml?query=19807"|perl -ne '/<title>([^<]+)/&&printf "%s: ",$1;/<fcttext>([^<]+)/&&print $1,"\n"';}


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert

    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


