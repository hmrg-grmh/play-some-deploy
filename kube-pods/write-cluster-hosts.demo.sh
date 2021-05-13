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
}

### ** 需要做到的功能：在配置生效前打印配置生效的话的样子并询问是否生效。


