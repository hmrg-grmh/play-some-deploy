
pods_pardo ()
{
    podskw="${1:-clustertest}" &&
    cmd="${2:-hostname -i}" &&
    parnum="${3:-0}" &&
    kubectl get po |
        awk /"$podskw"/{print\$1} |
        xargs -P"$parnum" -i{x} kubectl exec {x} -- bash -c '
          echo ======== '"'"{x}"'"' ======== >&2 ;
        '"$cmd" ;
} &&

pods_alldo () { pods_pardo "$1" "$2" 0 ; } &&
pods_perdo () { pods_pardo "$1" "$2" 1 ; } &&


# end show message
declare -f $(declare -F | awk /pods_*/) ;
# or
declare -F | awk /pods_*/{print\$0'" ;"'} | xargs echo funcs: >&2 ;


