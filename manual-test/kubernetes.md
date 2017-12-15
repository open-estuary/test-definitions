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
       		192.168.1.190  # master节点(etcd,kubernetes-master)
       		192.168.1.254  # node节点(etcd,kubernetes-node,docker,flannel)
		192.168.1.218  # node节点(etcd,kubernetes-node,docker,flannel)
		192.168.1.233  # node节点(etcd,kubernetes-node,docker,flannel)


- **Test:**
    	
  
- **Result:**
      测试上述步骤是否全部通过，若是，则pass；若不是，则fail