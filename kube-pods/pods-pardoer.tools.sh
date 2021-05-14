
pods_pardo_x ()
{
    namespacename="${1:-default}" &&
    case $# in
        5)  shift ;;
        4)  ;;
        *)  echo plz use these two: &&
            echo \ pods_pardo_x '<'namespacename'|'"''"'>' '<'podsawkcode'|'"''"'>' '<'cmd'|'"''"'>' '<'parnum'|'"''"'>' '<'timefmt'|'"''"'>' \; &&
            echo \ pods_pardo_x  '<'podsawkcode'|'"''"'>' '<'cmd'|'"''"'>' '<'parnum'|'"''"'>' '<'timefmt'|'"''"'>' \; &&
            return 45 ;;
    esac &&
    podsawkcode="${1:-/clustertest/}" &&
    cmd="${2:-hostname -i}" &&
    parnum="${3:-0}" &&
    timefmt="${4:-%T%::z}" &&
    
    kubectl get po -o custom-columns=:.metadata.name --namespace "$namespacename" |
        awk "$podsawkcode"{print\$1} |
        xargs -P"$parnum" -i{x} kubectl exec {x} -- bash -c '
          echo ======== '"$(date +["$timefmt"])"' - '"'"{x}"'"' - "$(date +['"$timefmt"'])" ======== >&2 ;
        '"$cmd" ;
} &&



pods_def_alldo_x () { pods_pardo_x "$1" "$2" 0 "$3" ; } &&
pods_def_perdo_x () { pods_pardo_x "$1" "$2" 1 "$3" ; } &&

pods_ns_alldo_x () { pods_pardo_x "$1" "$2" "$3" 0 "$4" ; } &&
pods_ns_perdo_x () { pods_pardo_x "$1" "$2" "$3" 1 "$4" ; } &&

pods_alldo_x () { pods_pardo_x "$1" "$2" "$3" 0 "$4" ; } &&
pods_perdo_x () { pods_pardo_x "$1" "$2" "$3" 1 "$4" ; } &&



pods_def_pardo () { pods_pardo_x /"$1"/ "$2" "$3" "$4" ; } &&
pods_def_alldo () { pods_pardo "$1" "$2" 0 "$3" ; } &&
pods_def_perdo () { pods_pardo "$1" "$2" 1 "$3" ; } &&

pods_ns_pardo () { pods_pardo_x "$1" /"$2"/ "$3" "$4" "$5" ; } &&
pods_ns_alldo () { pods_pardo "$1" "$2" "$3" 0 "$4" ; } &&
pods_ns_perdo () { pods_pardo "$1" "$2" "$3" 1 "$4" ; } &&

pods_alldo () { pods_pardo "$1" "$2" "$3" 0 "$4" ; } &&
pods_perdo () { pods_pardo "$1" "$2" "$3" 1 "$4" ; } &&




# end show message
declare -f $(declare -F | awk /pods_*/\&\&\!/_x/\&\&\!/_def_/\&\&\!/_ns_/) ;
# or
declare -F | awk /pods_*/\&\&\!/_x/\&\&\!/_def_/\&\&\!/_ns_/{print\$0'" ;"'} | xargs echo [MSG]: to see some defined pods-funcs: >&2 ;


