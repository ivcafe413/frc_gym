#!/bin/sh
echo -ne '\033c\033]0;Crescendo_OpenGym_2\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/frc_run.x86_64" "$@"
