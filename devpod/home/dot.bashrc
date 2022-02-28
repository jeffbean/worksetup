export EDITOR='vim'

alias mtest='gazelle && bazel test //src/code.uber.internal/infra/metal/...'
alias ms='gazelle && bazel test //src/code.uber.internal/infra/metal/... && bazel build --nobuild //src/code.uber.internal/infra/metal/... && bazel test //src/code.uber.internal/infra/collettore/...'
alias sgg='~/go-code/config/infra/starlark/scripts/stargen.sh'
alias bhd='bazel run //src/code.uber.internal/infra/bhd/cmd/cli --'
alias bpit='bazel build --platforms //:linux-amd64 //src/code.uber.internal/infra/metal/pitstop/cmd:pitstop-cmd'

function fr() {
    rg -l "$1" | xargs perl -p -i -e "s#$1#$2#g"
}


