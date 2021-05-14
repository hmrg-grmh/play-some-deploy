
pods_pardo_x ()
{
    podskw="${1:-/clustertest/}" &&
    cmd="${2:-hostname -i}" &&
    parnum="${3:-0}" &&
    timefmt="${4:-%T%::z}" &&
    
    kubectl get po |
        awk "$podskw"{print\$1} |
        xargs -P"$parnum" -i{x} kubectl exec {x} -- bash -c '
          echo ======== '"$(date +["$timefmt"])"' - '"'"{x}"'"' - "$(date +['"$timefmt"'])" ======== >&2 ;
        '"$cmd" ;
} &&
pods_alldo_x () { pods_pardo_x "$1" "$2" 0 "$3" ; } &&
pods_perdo_x () { pods_pardo_x "$1" "$2" 1 "$3" ; } &&

pods_pardo () { pods_pardo_x /"$1"/ "$2" "$3" "$4" ; } &&
pods_alldo () { pods_pardo "$1" "$2" 0 "$3" ; } &&
pods_perdo () { pods_pardo "$1" "$2" 1 "$3" ; } &&


# end show message
declare -f $(declare -F | awk /pods_*/\&\&\!/_x/) ;
# or
declare -F | awk /pods_*/\&\&\!/_x/{print\$0'" ;"'} | xargs echo [MSG]: to see some defined pods-funcs: >&2 ;


