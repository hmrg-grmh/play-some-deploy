# 0

# kubectl get po | awk /clustertest/{print\$1} | xargs -P0 -i{x} kubectl exec {x} -- bash -c 'echo ======== '"'"{x}"'"' ======== >&2 ; ''hostname'
# kube_alldo () { podskw="${1:-clustertest}"  cmd="${2:-hostname -i}"  parnum="${3:-0}" && kubectl get po | awk /"$podskw"/{print\$1} | xargs -P"$parnum" -i{x} kubectl exec {x} -- bash -c 'echo ======== '"'"{x}"'"' ======== >&2 ; '"$cmd" ; }

kube_alldo ()
{
    podskw="${1:-clustertest}" &&
    cmd="${2:-hostname -i}" &&
    parnum="${3:-0}" &&
    kubectl get po |
        awk /"$podskw"/{print\$1} |
        xargs -P"$parnum" -i{x} kubectl exec {x} -- bash -c '
          echo ======== '"'"{x}"'"' ======== >&2 ;
        '"$cmd" ;
} ;

# 1

(please wait ...)
