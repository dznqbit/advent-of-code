#!/bin/sh
SESSION_NAME=aoc
WINDOW_NAME=advent-of-code

EXISTING_SESSION=`tmux ls | grep $SESSION_NAME`

if [ -z $EXISTING_SESSION ]; then
  tmux new -s $SESSION_NAME -d
  tmux rename-window -t $SESSION_NAME $WINDOW_NAME

  tmux split-window -t $SESSION_NAME -h
  tmux send-keys -t $SESSION_NAME.1 "tmux resize-pane -t 1 -x 100; clear" Enter
fi

tmux attach -t $SESSION_NAME.0
