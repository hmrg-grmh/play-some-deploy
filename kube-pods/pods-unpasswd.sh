pods_unpswd ()
{
    cluster_kws="${1:-}" &&
    pswd="${2:-zz/Z}" &&
    
    expect_unpswd ()
    {
        iphost="$1"  pswd="$2" ;
        { pswde () { echo "$pswd" ; } ; pswde ; pswde ; } | passwd ;
        expect -c 'spawn ssh-keygen -t rsa ; expect "Enter" {send "\r";exp_continue} "Overwrite" {send "y\r";exp_continue}' &&
        expect -c 'spawn ssh-copy-id -i root@'"$iphost"';expect "yes/no" {send "yes\r";exp_continue} "password" {send "'"$pswd"'\r"};expect eof' ;
    } &&
    
`#     (kubectl get po -o custom-columns=:.status.podIP,:.metadata.name --namespace default | awk /"$cluster_kws"/\{print\$1\}) |
#         xargs -P0 -i -- kubectl exec -ti cdh-0514-master-85bc5c87f9-qxd6b -- bash -c "$(declare -f expect_unpswd) && $(echo expect_unpswd  "'"{}"'"  "'""$pswd""'")" ;`
    
    (kubectl get po -o custom-columns=:.metadata.name --namespace default | awk /"$cluster_kws"/) |
        xargs -P0 -i{x} -- kubectl exec {x} -- sh -c "$(declare -f expect_unpswd)"' ;
        echo ======== '"$(date +["$timefmt"])"' - '"'"{x}"'"' - "$(date +['"$timefmt"'])" ======== >&2 ;
        echo '"'""$(
            kubectl get po -o custom-columns=:.status.podIP,:.metadata.name --namespace default | 
                awk /"$cluster_kws"/\{print\$1\})""'"' |
            xargs -P0 -i -- sh -c "$(declare -f expect_unpswd)"'"'"" $(echo  '&&'  expect_unpswd  "'"'"'"'"'"'"'"{}"'"'"'"'"'"'"'"  "'"'"'"'"'"'"'""$pswd""'"'"'"'"'"'"'")""'"' ;' ;
} ;
