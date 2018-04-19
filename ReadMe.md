# Estuary测试用例说明书

## 目录规划

测试工程的目录结构，大致按照linaro的结构层次，需要在auto-test和manual-test下面根据各case的属性再添加一级或者二级目录。
```
test-definitions
├── auto-test
│   ├── apps
│   │   ├── bigdata
│   │   ├── performance
│   │   ├── server
│   │   └── stress
│   ├── bootloaders
│   ├── distributions
│   │   └── distribution
│   ├── hardwareboards
│   ├── kernel
│   ├── middleware
│   │   ├── database
│   │   ├── language
│   │   └── tool
│   ├── peripheral
│   └── virtualization
├── lib
├── list
├── manual-test
│   ├── apps
│   │   ├── e-commerce
│   │   ├── performance
│   │   ├── server
│   │   ├── stress
│   │   └── web
│   ├── bootloaders
│   ├── distributions
│   │   ├── build
│   │   ├── deploy
│   │   └── distribution
│   ├── hardwareboards
│   ├── kernel
│   ├── middleware
│   │   ├── language
│   │   └── tool
│   ├── peripheral
│   │   ├── 82599
│   │   ├── sas
│   │   ├── raid
│   │   ├── ssd
│   │   ├── misc
│   │   └── hns
│   └── virtualization
├── owner
├── plans
├── ReadMe.md
├── toolset
└── utils
```
## 归类依据

测试工程的case根据open-estuary.org网页的[Architecture Overview](http://open-estuary.org/estuary/)蓝图来划分，主要有8个level
```
Typical Apps                      : include webserver,bigdata process,cld storage cld machine
Middle Ware Components            : include apache,nginx,openJDK,hadoop,ceph,spark,mysql,golang,redis
Virtualization Technologies       : include openstack,docker,lxc,qemu,hhvm
Distributions                     : include ubuntu,centos,debian,fedora,opensuse,miniOS,rancherOS
OS/Kernel                         : include kernel,drivers,acpi,odp
Firmware Bootloaders && Secure OS : include grub,uefi,uboot,trustedFW,op-tee
Infrastructure && Hardware Boards : include openlab,remote boards access/management,D03,D05
Peripheral                        : include usb disk,ssd disk,raid card,82599 card
```
现有的Estuary测试case需根据属性归类到这8个level中

## 扩展原则

后续若有新增的case或者特性，则依据它的属性分别添加到对应的目录下
```
例如：新增一个slabtop验证，由于slabtop命令以实时的方式显示内核“slab”缓冲区的细节信息，所以我们把它添加到kernel这个目录下
```

## 其它说明
1. metadata下name项必须是ascii码，不要包含 空格 和 " ' () <> / \ | 等符号
2. 安装步骤如果在sh脚本中，那yaml中install-deps项全部删除
3. metadata新增了level项，代表用例的优先级等级，值范围：【1,2,3,4,5】
   1，优先级最高，必测项；2-4，优先级依次降低；5，优先级最低
   若没写level，则默认为1
4. metadata新增了scope项，指明用例的所属类型，如kernel,virtualization等
5. sh脚本中不能存在阻塞，如cat空文件，ping动作都会使脚本阻塞
6. 所有文件目录都以小写字母命名，若有前缀或者后缀，一律以中划线‘-’标明
7. 测试case的名称，以安装包、模块、特性来命名
