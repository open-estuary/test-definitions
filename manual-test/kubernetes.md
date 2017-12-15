---
kubernetes.md - 测试v500对kubernetes的兼容性及其基本功能
Hardware platform: D05，D03
Software Platform: CentOS
Author: Liu Caili <liu_caili@hoperun.com>  
Date: 2017-12-13 9:45:00 
Categories: Estuary Documents  
Remark:
---

- **Dependency:**
    测试环境搭建
       	准备4台服务器：
       		192.168.1.190  # master节点
       		192.168.1.254  # node1节点
		192.168.1.218  # node2节点
		192.168.1.233  # node3节点


- **Test:**
    	1. 检查服务器之间是否网络互通
        2. 依次给每台服务器安装etcd
        3. 修改master的etcd配置文件，并取名为etcd1，具体配置如下：
        	ETCD_NAME=etcd1
		ETCD_DATA_DIR="/var/lib/etcd/etcd1.etcd"
		ETCD_LISTEN_PEER_URLS="http://192.168.1.190:2380"
		ETCD_LISTEN_CLIENT_URLS="http://192.168.1.190:2379,http://127.0.0.1:2379"
		ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.190:2380"
		ETCD_INITIAL_CLUSTER="etcd1=http://192.168.1.190:2380,etcd2=http://192.168.1.254:2380,etcd3=http://192.168.1.218:2380,etcd4=http://192.168.1.233:2380"
		ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.190:2379"
        4. 修改node1的etcd配置文件，并取名为etcd2
          	ETCD_NAME=etcd2
		ETCD_DATA_DIR="/var/lib/etcd/etcd2.etcd"
		ETCD_LISTEN_PEER_URLS="http://192.168.1.254:2380"
		ETCD_LISTEN_CLIENT_URLS="http://192.168.1.254:2379,http://127.0.0.1:2379"
		ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.254:2380"
		ETCD_INITIAL_CLUSTER="etcd1=http://192.168.1.190:2380,etcd2=http://192.168.1.254:2380,etcd3=http://192.168.1.218:2380,etcd4=http://192.168.1.233:2380"
		ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.190:2379"
        5. 修改node2的etcd配置文件，并取名为etcd3
        	ETCD_NAME=etcd3
		ETCD_DATA_DIR="/var/lib/etcd/etcd3.etcd"
		ETCD_LISTEN_PEER_URLS="http://192.168.1.218:2380"
		ETCD_LISTEN_CLIENT_URLS="http://192.168.1.218:2379,http://127.0.0.1:2379"
		ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.218:2380"
		ETCD_INITIAL_CLUSTER="etcd1=http://192.168.1.190:2380,etcd2=http://192.168.1.254:2380,etcd3=http://192.168.1.218:2380,etcd4=http://192.168.1.233:2380"
		ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.190:2379"
        6. 修改node3的etcd配置文件，并取名为etcd4
        ETCD_NAME=etcd4
		ETCD_DATA_DIR="/var/lib/etcd/etcd1.etcd"
		ETCD_LISTEN_PEER_URLS="http://192.168.1.190:2380"
		ETCD_LISTEN_CLIENT_URLS="http://192.168.1.190:2379,http://127.0.0.1:2379"
		ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.1.190:2380"
		ETCD_INITIAL_CLUSTER="etcd1=http://192.168.1.190:2380,etcd2=http://192.168.1.254:2380,etcd3=http://192.168.1.218:2380,etcd4=http://192.168.1.233:2380"
		ETCD_ADVERTISE_CLIENT_URLS="http://192.168.1.190:2379"
		
	7. 启动etcd服务
	    systemctl start etcd
	    
	8. 查看etcd集群状态
	    etcdctl cluster-health
	    
	9. 各节点安装ntp
	
	10. 各节点启动ntpd服务
	
	11. master安装kubernetes
	
	12. 其余节点安装kubernetes flannel
	
	13. 查看kubernetes是否安装的源来自estuary
	
	14. 查看kubernetes版本是否为 1.6.4
	
	15. 各节点卸载 kubernetes / flannel
	
	16. 各节点卸载 ntp
	
	17. 各节点卸载etcd 
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail