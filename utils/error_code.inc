# Note:  return success
SUCCESS_CODE=0              #operate success

ERROR_PATH_NOT_EXIST=81     #direcotry is not exist
ERROR_BACKUP_FAILURE=82     #OS backup failure
ERROR_BACKUP_TIMEOUT=83     #OS backup timeout
ERROR_IP_INVALID=87         #invalid IP address
ERROR_SCP=88                #scp failure
ERR_INSTALL=89              #install failure

#common class error code
ERR_MKDIR=92                #create dirctory failure
ERR_EXECSHELL=93            #run the 3rd program failure
ERR_FILEISNULL=94           #the content of file is null
ERR_USERINFO=95             #user or password failure
ERR_PWDSAME=96              #the old password is the same as the new password
ERR_PWDCOMPLEX=99           #password complexity failure
ERR_EXECSYS=100             #run OS command failure
ERR_FILEEXIST=101           #the file is not exist
ERROR_PARAM=102             #the pamameters is not match requiring
ERR_TIMEOUT=103             #run program timeout
ERR_IPREACH=104             #the IP is not reachable
ERR_DECODE=105              #convert file coding failure
ERR_DECOMPRESS=106          #uncompress failure
ERR_RIGHT=107               #right filure
ERR_SSH=108                 #run ssh command failure
ERR_COMPRESS=109            #compress failure
ERR_DIRECTORY=110           #direcotry is not exist or has no permission to enter
ERR_DISKSPACE=111           #the disk space is not enough 
ERROR_NETWORK=112           #network is unreachable
ERROR_DEVICE=113            #no such device
ERR_REBOOT=118              #reboot OS failure
ERR_GETMAC=120              #get MAC address failure



#Oracle install or maintain errorcode
ERR_INST=140                #install DB failure
ERR_CHKSYS=141              #the prechecking for installing DB is failure
ERR_CONFIG=142              #configure DB failure
ERR_SERVICE=143             #the service of DB is abnormal

#modify blade IP errorcode
ERR_IPUSED=145              #the IP is used
ERR_BONDIP=146              #Failed to change the bond IP address
ERR_CHECKNICSTATUS=147      #the network card is not connected
ERR_CHECK_NSID=148          #can not configure IP in the same network
ERR_BONDSED=149             #the bond is used



#diskarray install or maintain errorcode
ERR_INCOMPATIBLE=159        #The firmware version of the disk array is low
ERR_DALINK=160              #FC link path or HBA port abnormal
ERROR_CLI_FAILED=161        #run diskarray cli failure
ERROR_CLI_GETID=162         #run getting object ID command for diskarray CLI failure
ERR_DAOBJECT_NOT_EXIST=163  #object is not exist
ERR_DADEL_LUN=164           #del lun failure
ERR_DADEL_RAID=165          #del raidgroup failure
ERR_DAUSEREXIST=166         #the diskarray user is exist or the password is not the configuring password
ERR_DASTATUSABNORMAL=167    #the status of diskarray is not abnormal
ERR_DAHOSTPORT=168          #del host port failure


#network operate errorcode 
ERR_IPNOTMATCH=191          #the IP resource of local node is online ,but the ip address is not match the local node ip address
ERR_SETROUTE=192            #set routing failure
ERR_CHECKROUTE=193          #the information of routing is not exist


#create tablespace errorcode 
ERR_ORATABLEEXIST=200       #the tablespace needed to create is exist
ERR_ORACREATETABLE=201      #create tablespace failure
ERR_ORACREATEUSER=202       #create the user of tablespace failure
ERR_ORAEXPENDFILE=203       #get the data file for extending tablespace failure
ERR_ORAGETSPACE=204         #get the size for extending tablespace failure
ERR_ORAEXPEND=205           #extending tablespace size failure

#create volume errorcode 
ERR_VOLCONFLICT=220         #the volume name conflict
ERR_VOLCREATE=221           #create volume failure
ERR_VOLDISKGROUPCREATE=222  #create disk group failure
ERR_VOLNOTEXIST=223         #the volume is not exist
ERR_VOLDISKGROUPNOTEXIST=223 #the disk group is not exist
ERR_VOLDELETE=224           #del the volume failure
ERR_VOLDISKGROUPDELETE=225  #del the disk group failure
ERR_VGCONFLICT=226          #the disk group conflict




