
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


pods_alldo_x () { pods_pardo_x "$1" "$2" 0 "$3" ; } &&
pods_perdo_x () { pods_pardo_x "$1" "$2" 1 "$3" ; } &&

pods_pardo () { pods_pardo_x /"$1"/ "$2" "$3" "$4" ; } &&
pods_alldo () { pods_pardo "$1" "$2" 0 "$3" ; } &&
pods_perdo () { pods_pardo "$1" "$2" 1 "$3" ; } &&





# end show message
declare -f $(declare -F | awk /pods_*/\&\&\!/_def_/\&\&\!/ns_/) ;
# or
declare -F | awk /pods/\&\&/par/\&\&\!/_def_/\&\&\!/ns_/{print\$0'" ;"'} | xargs echo [MSG]: to see some defined pods-funcs: >&2 ;




# ------------------------------------ NEW ------------------------------------ #:





pods_all_do_x ()
{
    podsawkcode="${1:-/some-poname-rgx/}" &&
    cmd="${2:-hostname -i}" &&
    parnum="${3:-0}" &&
    timefmt="${4:-%T%::z}" &&
    namespace_opt="${5:---namespace default}" &&
    shparser="${6:-bash}" &&
    
    get_pods ()
    {
        cus_col_val="${1:-NAME:.metadata.name,PodIP:.status.podIP,NodesIP:.status.hostIP,NAMESPACE:.metadata.namespace}" &&
        kubectl get po -o custom-columns="$cus_col_val" ${2:-$namespace_opt} |
            awk "${3:-$podsawkcode}" ;
    } &&
    
    (( $# != 0 )) ||
    {
        chg_code="${PODS_ALL_DO_CHG_RTCODE:-209}" &&
        
        pods_all_do_cmder ()
        {
            podsawkcode="${1:-$podsawkcode}" &&
            namespace_opt="${2:-$namespace_opt}" &&
            sh_parser="${3:-$shparser}" &&
            par_lev="${4:-$parnum}" &&
            tfmt=""${5:-$timefmt}""
            
            echo '[!] now, you can run some simple cmds for pods (!q to quit): ' &&
            while read -p '[:]? ('"${namespace_opt#* }"'):<'"$podsawkcode"'> - ['"$sh_parser"','"$par_lev"']:('"$(date +"$tfmt")"')-:> ' cmd ;
            do
                case "$cmd" in
                    ''|'# '*) ;;
                    '!'[qQ]) echo 'Bye!' ':)' ; break ;;
                    '!'[cC]) return $chg_code ;;
                    '!'[hH]) echo '[@] !q to quit , !c to change opts , and !h get help .' ;;
                    ['#''!']*) echo "$cmd" ;;
                    *) pods_all_do_x "$podsawkcode" "$cmd" "$par_lev" "$tfmt" "$namespace_opt" "$sh_parser" ;;
                esac ;
            done ;
        } &&
        
        looping_quest_iter ()
        {
            looped_tims=${1:-0} &&
            
            read -p   \<"$looped_tims"\>\ what\'s\ your\ namespace\ option\ ?\ now\ will\ be:\ \["${ns_opt:-${2:-$namespace_opt}}"\]\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  ns_opt &&
            read -p   \<"$looped_tims"\>\ which\ pods\ regex\ ?\ now\ will\ be:\ \["${awk_codes:-${3:-$podsawkcode}}"\]\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  awk_codes &&
            
            read -p   \<"$looped_tims"\>\ which\ shell\ parser\ you\ wans\ to\ choose\ ?\ now\ will\ be:\ \["${sh_parser:-${4:-$shparser}}"\]\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  sh_parser &&
            read -p   \<"$looped_tims"\>\ what\ the\ parallel\ level\ you\ wans\ to\ choose\ ?\ now\ will\ be:\ \["${par_level:-${5:-$parnum}}"\]\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  par_level &&
            read -p   \<"$looped_tims"\>\ which\ time\ show'-'format\ you\ need\ to\ choose\ ?\ now\ will\ be:\ \["${time_fmt:-${6:-$timefmt}}"\]\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  time_fmt &&
            
            echo '[!] here is pods you just select: ' &&
            get_pods '' "${ns_opt:-${2:-$namespace_opt}}" "${awk_codes:-${3:-$podsawkcode}}" &&
            echo '[!] and the other choosen: ' &&
            echo 'parser you just chose: '\["${sh_parser:-${4:-$shparser}}"\] &&
            echo 'parallel-level you just chose: '\["${par_level:-${5:-$parnum}}"\] &&
            echo 'example time-show-format you just chose: '\["$(date +"${time_fmt:-${6:-$timefmt}}")"\] &&
            while read -p '[?] needs to change your choosen ? [N|y]: ' chg_choosen ;
            do
                case "$chg_choosen" in
                    n|N) 
                        pods_all_do_cmder "${awk_codes:-${3:-$podsawkcode}}" "${ns_opt:-${2:-$namespace_opt}}" "${sh_parser:-${4:-$shparser}}" "${par_level:-${5:-$parnum}}" "${time_fmt:-${6:-$timefmt}}" ; case $? in "$chg_code") ;; *) return $? ;; esac ;;
                    y|Y) 
                        looping_quest_iter $((looped_tims+1)) "${ns_opt:-${2:-$namespace_opt}}" "${awk_codes:-${3:-$podsawkcode}}" "${sh_parser:-${4:-$shparser}}" "${par_level:-${5:-$parnum}}" "${time_fmt:-${6:-$timefmt}}" ; return $? ;;
                    *) ;;
                esac ;
            done ;
        } &&
        looping_quest_iter 0 ; return $? ;
    } &&
    
    
    kubectl get po -o custom-columns=:.metadata.name $namespace_opt |
        awk "$podsawkcode" |
        xargs -P"$parnum" -i{x} kubectl exec {x} -- "$shparser" -c '
        echo ======== '"$(date +["$timefmt"])"' - '"'"{x}"'"' - "$(date +['"$timefmt"'])" ======== >&2 ;
        '"$cmd" ;
} &&
export -f pods_all_do_x &&
pods_all_do () { sh -c pods_all_do_x ; } ;

### ???????????????????????????????????????????????????????????????????????????????????? pod ??????????????????
### ????????????????????????????????????????????????????????????????????????????????????
### ??????????????????????????????????????????????????????????????????????????????????????????????????????
