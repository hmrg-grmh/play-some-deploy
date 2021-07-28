
### add hosts & passwd
### need: expect

## def
pods_clusterz_x ()
{
    podsawkcode="${1:-/pode-[0-9]-test-01/}" &&
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
        looping_quest_iter ()
        {
            wrong_times=${1:-0} &&
            
            read -p   \<"$wrong_times"\>\ which\ namespace\ ?\ now\ will\ be:\ "${ns_name:-${2:-$namespacename}}"\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  ns_name &&
            read -p   \<"$wrong_times"\>\ which\ pods\ regex\ ?\ now\ will\ be:\ "${awk_codes:-${3:-$podsawkcode}}"\ \(just\ \<Enter\>\ to\ use\ this\ or\ input\ new\ one\):\  awk_codes &&
            
            echo '[!] here is pods you just select: ' &&
            get_pods '' "${ns_name:-${2:-$namespacename}}" "${awk_codes:-${3:-$podsawkcode}}" &&
            while read -p '[?] is these your pods in one cluster ? [Y|n]: ' choosen ;
            do
                case "$choosen" in
                    y|Y) pods_clusterz_x "${awk_codes:-${3:-$podsawkcode}}" "${ns_name:-${2:-$namespacename}}" ; return $? ;;
                    n|N) looping_quest_iter $((wrong_times+1)) "${ns_name:-${2:-$namespacename}}" "${awk_codes:-${3:-$podsawkcode}}" ; return $? ;;
                    *) ;;
                esac ;
            done ;
        } &&
        looping_quest_iter 0 ; return $? ;
    } ;
    
    get_hostsfile_parnow ()
    {
        timefmt="${1:-%T%::z}"
        get_pods :.metadata.name |
            xargs -P0 -i{x} kubectl exec -n "$namespacename" {x} -- /bin/sh -c '
            echo ======== '"$(date +["$timefmt"])"' - '"'"{x}"'"' - "$(date +['"$timefmt"'])" ======== &&
            cat /etc/hosts ;' ;
    } &&
    
    need_in_hosts="$(
        # get_pods :.status.podIP,:.metadata.name &&
        get_pods :.metadata.name | xargs -i -- kubectl exec -n "$namespacename" {} -- /bin/sh -c 'echo "`hostname -i` $HOSTNAME"' )" &&
    
    
    q_set_hosts ()
    {
        hosts_cleaner ()
        {
            echo 'hosts_tidier () { awk '"'"'{for(i=2;i<=NF;i++){ordinalof_hostname++;ip_name_ordinalseqseq[$1][$i]=ip_name_ordinalseqseq[$1][$i]==""?ordinalof_hostname:(ordinalof_hostname<ip_name_ordinalseqseq[$1][$i]?ordinalof_hostname:ip_name_ordinalseqseq[$1][$i])};ip_firstlinenum[$1]=ip_firstlinenum[$1]==""?NR:(NR<ip_firstlinenum[$1]?NR:ip_firstlinenum[$1])}END{PROCINFO["sorted_in"]="@ind_num_asc";for(ip in ip_name_ordinalseqseq){for(name in ip_name_ordinalseqseq[ip]){ip_ord_namesetseq[ip][ip_name_ordinalseqseq[ip][name]]=name};for(ord in ip_ord_namesetseq[ip]){ip_namesortedsetseq[ip]=ip_namesortedsetseq[ip]" "ip_ord_namesetseq[ip][ord]}};for(ip in ip_firstlinenum){nr_ip[ip_firstlinenum[ip]]=ip};for(nr in nr_ip){print nr_ip[nr],ip_namesortedsetseq[nr_ip[nr]]}}'"'"' "${1:-/dev/stdin}" ; } && hosts_tidy_uppn () { hosts_tidier /etc/hosts > /etc/.hosts.tidy-uppn"${1:-}" && ls -a /etc/hosts /etc/.hosts* ; } && q_hosts_tidier () { cp -p /etc/hosts /etc/hosts.bak && hosts_tidier /etc/hosts.bak > /etc/hosts && mv /etc/hosts.bak /etc/hosts.bak"`date +%s%3N`" ; } ;' > /etc/profile.d/hosts-tidier.fn.sh && . /etc/profile.d/hosts-tidier.fn.sh && q_hosts_tidier 
        } &&
        
        
        get_pods :.metadata.name |
            
            xargs -P0 -i{x} kubectl exec -n "$namespacename" {x} -- /bin/sh -c '
            echo '"'""$( echo  && echo "$need_in_hosts" &&  echo )""'"' >> /etc/hosts &&
            '"$(declare -f hosts_cleaner)"' && hosts_cleaner ;
            ' &&
        
        echo '[:] look, now the hosts:' &&
        get_hostsfile_parnow "$timefmt" &&
        
        echo '[!] Hosts Set Done ! <<<<'
    } &&
    
    
    q_unpswd ()
    {
        cluster_podawk="${1:-$podsawkcode}" &&
        ns="${2:-$namespacename}"
        pswd_def="${3:-zz/Z}" &&
        
        read -p '[-] set the passwd or black to use ['"$pswd_def"']: ' pswd_ans &&
        pswd="${pswd_ans:-$pswd_def}" &&
        
        expect_unpswd ()
        {
            iphost="$1"  pswd="$2" ;
            { pswde () { echo "$pswd" ; } ; pswde ; pswde ; } | passwd ;
            expect -c 'spawn ssh-keygen -t rsa ; expect "Enter" {send "\r";exp_continue} "Overwrite" {send "y\r";exp_continue}' &&
            expect -c 'spawn ssh-copy-id -i root@'"$iphost"';expect "yes/no" {send "yes\r";exp_continue} "password" {send "'"$pswd"'\r"};expect eof' ;
        } &&
        
    `
    #     (kubectl get po -o custom-columns=:.status.podIP,:.metadata.name --namespace "$ns" | awk /"$cluster_kws"/\{print\$1\}) |
    #         xargs -P0 -i -- kubectl exec -ti cdh-0514-master-85bc5c87f9-qxd6b -- bash -c "$(declare -f expect_unpswd) && $(echo expect_unpswd  "'"{}"'"  "'""$pswd""'")" ;
    `
        
        (kubectl get po -o custom-columns=:.metadata.name --namespace "$ns" | awk "$cluster_podawk") |
            xargs -P0 -i{x} -- kubectl exec {x} -n "$ns" -- sh -c "$(declare -f expect_unpswd)"' ;
            echo '"'""$(
                kubectl get po -o custom-columns=:.status.podIP,:.metadata.name --namespace "$ns" | 
                    awk "$cluster_podawk"\{print\$1\})""'"' |
                xargs -P0 -i -- sh -c "$(declare -f expect_unpswd)"'"'"" $(echo  '&&'  expect_unpswd  "'"'"'"'"'"'"'"'{}'"'"'"'"'"'"'"'"  "'"'"'"'"'"'"'""$pswd""'"'"'"'"'"'"'"  '&>.expect-passwd.log'  '&&' echo ok: "'"'"'"'"'"'"'"'{x}'"'"'"'"'"'"'"'" ::to:: "'"'"'"'"'"'"'"'{}'"'"'"'"'"'"'"'" '||' echo fail: "'"'"'"'"'"'"'"'{x}'"'"'"'"'"'"'"'" ::to:: "'"'"'"'"'"'"'"'{}'"'"'"'"'"'"'"'" )""'"' ;' ;
    } ;
    
    
    quest_loopiter ()
    {
        times_to_look="${1:-0}" &&
        
        echo          '[!] here is things will be append to /etc/hosts :'        &&
        echo           -----------------------------------------------           &&
        echo          "$need_in_hosts"      &&
        echo           ---------------------------------------------------       &&
        echo          '[!] here is /etc/hosts before written on every pods :'    &&
        echo          "$(get_hostsfile_parnow "$timefmt")"      &&
        echo           ----------------------------        &&
        while read -p '[?] is these right ? [Y|n|r] 'r:\<"$times_to_look"\>' : '     inputs ;
        do
            case "$inputs" in
                Y|y|[yY]es) q_set_hosts ; return 0 ;;
                n|N|[nN]o) return 3 ;;
                r|R|[rR]etry ) quest_loopiter $((times_to_look + 1)) ; return $? ;;
                *) ;;
            esac ;
        done ;
    } &&
    
    pswds_ask ()
    {
        echo '[:] And You Maybe Need to set a unpasswd to the Nodes in your Cluster ::::' &&
        while read -p '[?] make a upasswd inner cluster ? [Y|n]: ' answer
        do
            case "$answer" in
                Y|y|[yY]es) q_unpswd ; return $? ;;
                n|N|[nN]o) break ;;
                *) ;;
            esac ;
        done ;
    } &&
    
    quest_loopiter 0 && pswds_ask ; return $? ;
    
} && pods_clusterz () { pods_clusterz_x ; } ;



## usage: 
pods_clusterz



### use mysql be metadb

## def:
addin_meta_mysql ()
{
    out_sql_md () { echo 'create database if not exists `{}` ;' && echo 'grant all on `{}`.* to "{}"@"%" identified by "{}-pass&" ;' && echo 'show grants for "{}"@"%" ;' ; } &&
    (echo "$@" | xargs -n1) |
        xargs -i -P0 -- /usr/bin/sh -c "$(declare -f out_sql_md)"' && out_sql_md | mysql -uroot -p123456' ;
} ;

## usg:
addin_meta_mysql  hive am oozie hue spark hbase 



