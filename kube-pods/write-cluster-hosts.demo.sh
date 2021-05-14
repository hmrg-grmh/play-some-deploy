
# kwd=hdfstest && kubectl get po|awk '/'"$kwd"'/{print$1}'|xargs -P0 -i{x} kubectl exec {x} -- /bin/bash -c 'echo "'"$(kubectl get po|awk '/'"$kwd"'/{print$1}'|xargs -P0 -i{x} kubectl exec {x} -- /bin/bash -c 'echo -n "'{x}' " ; hostname -i'|awk 'BEGIN{print}{print$2,$1}')"'" >> /etc/hosts'

kwd=monoabc &&
kubectl get po |
    awk '/'"$kwd"'/{print$1}' |
    xargs -P0 -i{x} kubectl exec {x} -- /bin/bash -c '
      echo "'"$(
    
  kubectl get po |
      awk '/'"$kwd"'/{print$1}' |
      xargs -P0 -i{x} kubectl exec {x} -- /bin/bash -c '
        echo -n "'{x}' " ;
        hostname -i ;
      ' |
      awk 'BEGIN{print}{print$2,$1}' ;

                )"'" >> /etc/hosts ;
    ' ;

##: 前提: 把 pod 当单节点使用
##: 这里所有名称中带有 monoabc 的 pod 视为一个集群
##: 先并发得到所有节点 pod 的 IP 和 hostname
##: 再并发写入每个节点的 /etc/hosts

##: $()本质是用标准输出拼外层命令的字符串
##: 所以只必要有一次执行的部分只会执行一次

kube_allhosts ()
{
    kwd="$1" &&
    kubectl get po |
        awk '/'"$kwd"'/{print$1}' |
        xargs -P0 -i{x} kubectl exec {x} -- /bin/bash -c '
          echo "'"$(
        
      kubectl get po |
          awk '/'"$kwd"'/{print$1}' |
          xargs -P0 -i{x} kubectl exec {x} -- /bin/bash -c '
            echo -n "'{x}' " ;
            hostname -i ;
          ' |
          awk 'BEGIN{print}{print$2,$1}' ;
        
                    )"'" >> /etc/hosts ;
        ' ;
} ;

### ** 需要做到的功能：在配置生效前打印配置生效的话的样子并询问是否生效。




# -------------------------------- 下面这个更严谨一点点 并且也增加了交互提示（无参使用出现） 小尾巴见最后注释 -------------------------------- #



pods_allho_x ()
{
    podsawkcode="${1:-/hdp-..-test/}" &&
    namespacename="${2:-default}" &&
    timefmt="${3:-%T%::z}" &&
    
    get_pods ()
    {
        cus_col_val="${1:-NAME:.metadata.name,PodIP:.status.podIP,NodesIP:.status.hostIP,NAMESPACE:.metadata.namespace}" &&
        kubectl get po -o custom-columns="$cus_col_val" --namespace "${2:-$namespacename}" |
            awk "${3:-$podsawkcode}" ;
    } &&
    
    (( $# != 0 )) ||
    {
        # x_wrong=0 &&
        # while true ;
        # do
        #     read -p which\ namespace\ ?\ now\ will\ be:\ "${ns_name:-$namespacename}"\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  ns_name &&
        #     read -p which\ pods\ regex\ ?\ now\ will\ be:\ "${awk_codes:-$podsawkcode}"\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  awk_codes &&
        #     ns_name="${ns_name:-$namespacename}" awk_codes="${awk_codes:-$podsawkcode}" &&
        #     
        #     echo '[!] here is pods you just select: ' &&
        #     echo get_pods '' "$ns_name" "$awk_codes" &&
        #     while read -p '[?] is these your pods in one cluster ? [Y|n]: ' choosen ;
        #     do
        #         case "$choosen" in
        #             y|Y) x_wrong=0 ; break ;;
        #             n|N) x_wrong=$((x_wrong+1)) ; break ;;
        #             *) ;;
        #         esac ;
        #     done &&
        #     
        #     (( x_wrong != 0 )) || { break ; } ;
        # done &&
        # pods_allho_x "$awk_codes" "$ns_name" ; return $? ;
        # ----------------------------------------------
        # var in loop is too bad !!!! and too chaos !!!!
        
        in_loop_iter ()
        {
            wrong_times=${1:-0} &&
            
            read -p   \<"$wrong_times"\>\ which\ namespace\ ?\ now\ will\ be:\ "${ns_name:-${2:-$namespacename}}"\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  ns_name &&
            read -p   \<"$wrong_times"\>\ which\ pods\ regex\ ?\ now\ will\ be:\ "${awk_codes:-${3:-$podsawkcode}}"\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  awk_codes &&
            
            echo '[!] here is pods you just select: ' &&
            get_pods '' "${ns_name:-${2:-$namespacename}}" "${awk_codes:-${3:-$podsawkcode}}" &&
            while read -p '[?] is these your pods in one cluster ? [Y|n]: ' choosen ;
            do
                case "$choosen" in
                    y|Y) pods_allho_x "${awk_codes:-${3:-$podsawkcode}}" "${ns_name:-${2:-$namespacename}}" ; return $? ;;
                    n|N) in_loop_iter $((wrong_times+1)) "${ns_name:-${2:-$namespacename}}" "${awk_codes:-${3:-$podsawkcode}}" ; break ;;
                    *) ;;
                esac ;
            done ;
        } &&
        in_loop_iter 0 ; return $? ;
    } ;
    
    get_hostsfile_parnow ()
    {
        timefmt="${1:-%T%::z}"
        get_pods :.metadata.name |
            xargs -P0 -i{x} kubectl exec {x} -- bash -c '
            echo ======== '"$(date +["$timefmt"])"' - '"'"{x}"'"' - "$(date +['"$timefmt"'])" ======== &&
            cat /etc/hosts ;' ;
    } &&
    need_in_hosts="$(get_pods :.status.podIP,:.metadata.name)" &&
    
    while true ;
    do
        echo    '[!] here is things will be append to /etc/hosts :'    >&2 &&
        echo     -----------------------------------------------       >&2 &&
        echo    "$need_in_hosts"      >&2 &&
        echo     ---------------------------------------------------       >&2 &&
        echo    '[!] here is /etc/hosts before written on every pods :'    >&2 &&
        echo    "$(get_hostsfile_parnow "$timefmt")"     >&2 &&
        echo     --------------------------       >&2 &&
        echo -n '[?] is these right ? [Y|n]: '    >&2 &&
        read inputs &&
        case "$inputs" in
            Y|y) break ;;
            n|N) return 31 ;;
            *) ;;
        esac ;
    done &&
    
    
    
    get_pods :.metadata.name |
        
        xargs -P0 -i{x} kubectl exec {x} -- /bin/bash -c '
        echo '"'""$( echo  &&  echo "$need_in_hosts" )""'"' >> /etc/hosts ;
        ' &&
    
    get_hostsfile_parnow "$timefmt" ;
    
} &&

pods_allho ()
{
    (($#!=0)) ||
    {
        read -p which\ namespace\ ?\ input\ new\ or\ just\ \<Enter\>\ to\ use\ default\(see\ declare\ -f\ pods_allho_x\):\  ns_name &&
        read -p which\ pods\ keywords\ ?\ input\ new\ or\ just\ \<Enter\>\ to\ use\ default\(see\ declare\ -f\ pods_allho_x\):\  pods_kws &&
        pods_allho "$pods_kws" "$ns_name" ; return $? ;
    } ;
    
    pods_allho_x   /"${1:-....test}"/   "$2" ;
} ;


### 顺便把提示也加上了。。。但是这个实现总感觉写法很笨。
### 一次性增加的有点多。。。
### 唯一的不足在于，返回码为啥最后选n会变成0？


