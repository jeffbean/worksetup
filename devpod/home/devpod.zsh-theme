# prompt be different in vscode over user ssh terminal. 
# This notable will be for when AI Agents chell out as well. 
# 
# NOTE: this is then joined with setting in vscode json. This ensures we get the shorter prompt with agents shelling out. 
#  "terminal.integrated.env.linux": {
#      "BEAN_CODE_ENABLED": "1",
#  },
#
if [[ -n $VSCODE_INJECTION || -n $BEAN_CODE_ENABLED ]]; then
  PROMPT='[c: %{$fg[cyan]%}%M%{$reset_color%}$(git_prompt_info)]: %{$fg[blue]%}%2~%{$reset_color%} %(!.#.$) '
else
  PROMPT='[dp: %{$fg[blue]%}%M%{$reset_color%} %D{%m-%d-%y %K:%M:%S (%z)}] :%{$fg[blue]%}%~%{$reset_color%}$(git_prompt_info) %(!.#.$) '
fi

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[yellow]%}g:("
ZSH_THEME_GIT_PROMPT_SUFFIX=")%{$reset_color%}"
