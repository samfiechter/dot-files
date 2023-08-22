#echo "${USER}@${HOSTNAME} .bashrc running..."
# ~/.bashrc: executed by bash(1) for every shell
export BASH_SILENCE_DEPRECATION_WARNING=1

#  _____                 _   _
# |  ___|   _ _ __   ___| |_(_) ___  _ __  ___
# | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
# |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
# |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/

# do the next command ignoring the first line of the stream (ex. "body sort -k 3" to skip the headers)
function body {
    (read -r; printf '%s\n' "$REPLY"; "$@")    
}

# remove dups from path...
function unique_path {
    echo $1 | tr ":" "\n" | sort | uniq | tr "\n" ":"
}

function whatsup {
    MASK=$(ifconfig  | awk 'BEGIN { FS = "  *";} /cast/ {print $6}' | sed 's/255/*/')
    CMD="nmap -sP -T5 $MASK"
    echo $CMD
    $CMD
}

function psg {
    if [ "" != "$1" ]
    then
        PRG=$1
	COLS=$(($(tput cols)-(7+13+7+7+9+10)))
	CCOLS=$(($COLS -1 ))
        ps aux | awk -v cmd="$PRG" -v s="%-6.5s %-12.11s %-6.5s %-6.5s %-8.7s %-9.8s %-${COLS}.${CCOLS}s\n" 'BEGIN { FS = "  *"; OFS="\t";  print "Looking for " cmd "...\n";} NR==1 {printf s,$2,$1,$3,$4,$9,$10,$11;} $11 ~ cmd {c = ""; for (i = 11; i <= NF; i++) c = c $i " "; printf s,$2,$1,$3,$4,$9,$10,c;}'
    else
        echo "psg : Program name"
    fi
}
# kill all programs named

function killall {
    if [ "" != "$1" ]
    then
        PRG=$1
        ps aux | awk -v cmd="$PRG" 'BEGIN { FS = "  *"; OFS="\t"; print "looking for " cmd "\n";} NR==1 {print $2,$11;} $11 ~ cmd {print "killing " $11 "..."; system("kill -n 9 " $2);}'

    else
        echo "kill_prg: Name"
    fi
}

#curl a wget

function wget {
    url=$1
    file=`echo $url | sed 's#.*/##g';`
    curl $url -o $file
}

#open in a new terminal window

function new() {
    if [[ $# -eq 0 ]]; then
        open -a "Terminal" "$PWD"
    else
        open -a "Terminal" "$@"
    fi
}




export PATH=`unique_path ":/sbin:/usr/local/bin:/usr/local/sbin:${PATH}:.:${HOME}/bin:"`
#export PERL_MB_OPT="--install_base \"/Users/sam/perl5\""; export PERL_MB_OPT;
#export PERL_MM_OPT="INSTALL_BASE=/Users/sam/perl5"; export PERL_MM_OPT;

#export INCLUDE=`unique_path $INCLUDE:/usr/X11/include`
#export LIBS=`unique_path $LIBS:/usr/X11/lib:`
#export LIBRARY_PATH=${LIBRARY_PATY}:$LIBS
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$LIBS


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


# set variable identifying the chroot you work in (used in the prompt below)
# Chroot is a unix feature that lets you restrict a process to a subtree of the
#     filesystem. One traditional use is FTP servers that chroot to a subset of
#     the filesystem containing only a few utilities and configuration files, plus
#     the files to serve; that way, even if an intruder manages to exploit a bug
#     in the server, they won't be able to access files outside the
#     chroot. Another common use is when you're installing or repairing a unix
#     system and you boot from a different system (such as a live CD): once a
#     basic system is available, you can chroot into it and do more work.
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
    CHROOT_PROMPT= "(${debian_chroot})"
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

if [ "screen" == "$TERM" ] ; then
    # set a fancy prompt (non-color, unless we know we "want" color)
    case "$OLDTERM" in
        xterm*)

            #export TITLEBAR='\[\033k ${USER}@${HOSTNAME}\033\\\]'  ##Unix
            export TITLEBAR="\[\033]0 \w ; \u@\h \007\]"
            #PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
            export color_prompt=yes;
            export GNUTERM=X11;
            export PS1="${TITLEBAR}${CHROOT_PROMPT} \w [\@] "
            export CLICOLOR=cons25;
            ;;
        *)
            export TITLEBAR=''
            export PS1="${CHROOT_PROMPT} \w [\@] "
            ;;
    esac

    export EDITOR=emacs
    export PAGER=less

else
    export PAGER=cat
    export TITLEBAR=''
    export PS1='\w [\t] '
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


#     _    _ _
#    / \  | (_) __ _ ___
#   / _ \ | | |/ _` / __|
#  / ___ \| | | (_| \__ \
# /_/   \_\_|_|\__,_|___/
#


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias port="echo 'use brew, dummy.'"
alias meacs="emacs"
alias eamcs="emacs"
alias emcas="emacs"
alias emasc="emacs"

alias binview="hexdump -C"

alias xeit="exit"
alias eixt="exit"
alias exti="exit"
alias undos="tr '\r' '\n'"

alias gitit='git commit -a -m "`date`"; git push'
alias perlinstall='/usr/local/bin/perl -MCPAN -e shell'
alias ls='/bin/ls -h -G --color=auto'
alias ll='/bin/ls -lha -G --color=auto'
alias la='/bin/ls -ahl -G'
alias rt='ls -a | grep -E "^(\#.*\#|.*~)$" | xargs -n 1 -x rm'

export PATH=`unique_path "${PATH}"`

#  ____                ____                       	
# |  _ \ _   _ _ __   / ___|  ___  _ __ ___   ___ 	
# | |_) | | | | '_ \  \___ \ / _ \| '_ ` _ \ / _ \	
# |  _ <| |_| | | | |  ___) | (_) | | | | | |  __/	
# |_| \_\\__,_|_| |_| |____/ \___/|_| |_| |_|\___|	
                                                	
#   ____                                          _     	
#  / ___|___  _ __ ___  _ __ ___   __ _ _ __   __| |___ 	
# | |   / _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|	
# | |__| (_) | | | | | | | | | | | (_| | | | | (_| \__ \	
#  \____\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/	
                                                      	
                                                     	


uname -v
# df -H | awk 'NR==1 {FS = "  *"; OFS = "\t"; print $1,$2,$4,$9 } /^\/dev\/disk/ { print $1,$2,$4,$9 }' | (read -r ; printf "%s\n" "$REPLY"; sort -k 1,4)
top -l 1 -n 0
