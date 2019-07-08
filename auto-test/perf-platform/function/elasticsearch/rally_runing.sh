#!/bin/bash
        cd /home/ggjj
	wget 192.168.1.107/liubeijie/rally.tar.gz
        pip3 install esrally==1.0.0 --user
	if [ $? -ne 0 ];then
		echo "PATH=$PATH:$HOME/bin:/usr/local/python3/bin" >> /root/.bash_profile
                source /root/.bash_profile
		pip3 install esrally==1.0.0 --user
	fi
	if [ -d /root/.local ];then
		cp -r /root/.local /home/ggjj
		chown -R ggjj:ggjj /home/ggjj
		chown -R ggjj:ggjj /home/ggjj/.local
	fi
	chown -R ggjj:ggjj /home/ggjj/.local/
	chmod 777  /home/ggjj/.local/

	chmod 777 rally.tar.gz
	chown -R ggjj /home/ggjj/rally.tar.gz
        tar -zvxf rally.tar.gz
        /home/ggjj/.local/bin/esrally
        sed -i 's/datastore.host = /datastore.host = localhost/g' /home/ggjj/.rally/rally.ini
        sed -i 's/datastore.port =/datastore.port = 9200/g' /home/ggjj/.rally/rally.ini
        sed -i 's/datastore.secure =/datastore.secure = false/g' /home/ggjj/.rally/rally.ini
        chown -R ggjj:ggjj /home/ggjj/.rally/

	
