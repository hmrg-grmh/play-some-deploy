
pods_pardo_x ()
{
    podsawkcode="${1:-/clustertest/}" &&
    cmd="${2:-hostname -i}" &&
    parnum="${3:-0}" &&
    timefmt="${4:-%T%::z}" &&
    
    namespace_opt="${5:---namespace default}" &&
    shparser="${6:-bash}" &&
    
    kubectl get po -o custom-columns=:.metadata.name   $namespace_opt |
        awk "$podsawkcode" |
        xargs -P"$parnum" -i{x} kubectl exec {x} -- "$shparser" -c '
          echo ======== '"$(date +["$timefmt"])"' - '"'"{x}"'"' - "$(date +['"$timefmt"'])" ======== >&2 ;
        '"$cmd" ;
} &&

pods_def_alldo_x () { pods_pardo_x "$1" "$2" 0 "$3" ; } &&
pods_def_perdo_x () { pods_pardo_x "$1" "$2" 1 "$3" ; } &&
podsns_alldo_x () { pods_pardo_x "$1" "$2" "$3" 0 "$4" ; } &&
podsns_perdo_x () { pods_pardo_x "$1" "$2" "$3" 1 "$4" ; } &&

pods_def_pardo () { pods_pardo_x /"$1"/ "$2" "$3" "$4" ; } &&
pods_def_alldo () { pods_def_pardo "$1" "$2" 0 "$3" ; } &&
pods_def_perdo () { pods_def_pardo "$1" "$2" 1 "$3" ; } &&
podsns_pardo () { pods_pardo_x "$1" /"$2"/ "$3" "$4" "$5" ; } &&
podsns_alldo () { podsns_pardo "$1" "$2" "$3" 0 "$4" ; } &&
podsns_perdo () { podsns_pardo "$1" "$2" "$3" 1 "$4" ; } &&





# end show message
declare -f $(declare -F | awk /pods_*/\&\&\!/_def_/\&\&\!/ns_/) ;
# or
declare -F | awk /pods_*/\&\&\!/_def_/\&\&\!/ns_/{print\$0'" ;"'} | xargs echo [MSG]: to see some defined pods-funcs: >&2 ;


