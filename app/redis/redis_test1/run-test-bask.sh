#! /bin/bash 



USERNAME=""
PASSWD=""

test_install_redis () {
    which redis_cli
    if $? -eq 0 ;then
        echo "install sucess"
    else
        echo "redis is not install or install not sucess"
        exit 1
    fi
}

test_redis_key() {
   ret=`redis-cli << EOF
    ping
EOF`
    if [ $ret = "PONG" ] ; then
        echo "redis connect success!"
    else 
        echo "redis connect failed!"
        exit 1
    fi

    cat command_key.txt | redis-cli -a xxx > command_key.result
   # line1=`cat command_key.txt | wc -l`
   # line2=`cat command_key.result | wc -l`
    local isSetOk=true 
    local isGetOk=true 
    local isDelOk=true 
    while read -u3 line1 && read -u4 line2
    do 
        #echo $line1 $line2 
        
        if [ $isSetOk ] &&  [ echo $line1 | grep -i "set" ] && [ echo $line2 | grep -i  "OK" ]  ; then
            echo $line1 $line2 -----success
        else
            isSetOk=false
        fi

        if [ $isGetOk ] && [ echo $line1 | grep -i "get" ] ; then
            key = awk '{print $2}'
            if $key = $line2 ;then
                echo $line1 $line2 -----success
            else
                isGetOk=false
            fi
        fi
        if [ $isDelOk ] && [ echo $line1 | grep -i "del" ];then
            if $line2=1 ;then
                echo $line1 $line2 ------success
            else
                isDelOk=false
            fi 
        fi 

    done 3< command_key.txt 4<command_key.txt

}

test_install_redis
test_redis_key


