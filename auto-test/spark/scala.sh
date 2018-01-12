#!/bin/bash

#=================================================================
#   文件名称：scala.sh
#   创 建 者：tanliqing tanliqing2010@163.com
#   创建日期：2018年01月10日
#   描    述：
#
#================================================================*/

function scala_install(){
    
    if [ ! -d ~/bigdata/spark ];then
        mkdir -p ~/bigdata/spark/ 
    fi 

    cd ~/bigdata/spark

        if [ -d scala-2.12.4 ];then 
            mkdir -p /var/spark 
            rm -f /var/spark/scala 
            ln -s ~/bigdata/spark/scala-2.12.4/ /var/spark/scala 
            return 0
        fi 
    
        if [ ! -f scala-2.12.4.tgz ];then
            wget -c https://downloads.lightbend.com/scala/2.12.4/scala-2.12.4.tgz 
        fi 
        tar -zxf scala-2.12.4.tgz
        mkdir -p /var/spark/ 
        rm -f /var/spark/scala 
        ln -s ~/bigdata/spark/scala-2.12.4/ /var/spark/scala
    cd - 

}

function scala_env_path(){

    grep "SCALA_HOME" ~/.bashrc 
    if [ $? -eq 0 ];then
        sed -i "/SCALA_HOME/"d ~/.bashrc 
    fi 
    echo "export SCALA_HOME=/var/spark/scala" >> ~/.bashrc 
    echo 'export PATH=$PATH:$SCALA_HOME/bin' >> ~/.bashrc 
    source ~/.bashrc > /dev/null 
}


function scala_test_if(){

    cat > if_test.scala<<eof

    object if_test {
    def main(args: Array[String]) {
        var x = 10;
        if( x < 20  ){
           println("if_is_ok");
        }            
    }
}
eof
    scalac if_test.scala 
    if [ $? -eq 0 ];then 
        true
    else 
        false
    fi 
    print_info $? "scalac compile scala file"

    ret=`scala if_test`
    if [ x$ret = x"if_is_ok" ];then
        true
    else
        false
    fi 
    print_info $? "scala if test"
    
}

function scala_test_for(){
    
    cat > for_test.scala<<eof
    
    object for_test{
    
    def main(args: Array[String]){
        var a = 10;
        var b = 0;
        for(a<- 1 to a){
            b=b+1;
        }
        if (b ==10){
            println("for_test_ok")
        }
    }
}
eof

    scalac for_test.scala
    ret=`scala for_test`
    if [ x$ret = x"for_test_ok" ];then
        true
    else
        false
    fi 
    print_info $? "scala for test"

    cat > while_test.scala<<-eof
    object while_test{
    def main(args:Array[String]){
        var a =10;
        var b = 0;
        while(a < 20){
            a = a +1;
            b = b + 1;
        }
        if ( b == 10 ){
            println("while_test_ok")
        }
    }
}

eof
    scalac while_test.scala
    ret=`scala while_test`
    if [ x$ret = x"while_test_ok" ];then
        true
    else
        false
    fi 
    print_info $? "scala while test"


    cat > dowhile_test.scala <<-eof
    object dowhile_test{
    def main(args:Array[String]){
        var a = 10;
        var b = 0;
        do{
            a = a + 1;
            b = b + 1;

        }while(a == 20)

        if(b == 1){
            println("dowhile_test_ok");
        }
    }
}

eof
    scalac dowhile_test.scala 

    ret=`scala dowhile_test`
    if [ x$ret = x"dowhile_test_ok" ];then
        true
    else
        false
    fi 
    print_info $? "scala do while test"


    cat > break_test.scala <<-eof

    import  scala.util.control.Breaks
    object break_test{
    def main(args:Array[String]){
        var a = 10;
        var b = 0 ;
        var loop = new Breaks;
        loop.breakable{
            for(a <- 1 to 10){
                b = b + 1;
                if (b == 5){
                    loop.break;
                }
            }
        }

        if (b == 5){
            println("break_test_ok")
        }
    }   
}

eof
    scalac break_test.scala
    ret=`scala break_test`
    if [ x$ret = x"break_test_ok" ];then
        true
    else
        false
    fi 
    print_info $? "scala break test"


}
 

function scala_test_string(){


    cat > string_test.scala <<-eof

    object string_test{
    def main(args:Array[String]){
        var greeting = "helloworld"
        var greeting2:String = "helloworld"
        if (greeting.length == greeting.size){
            println("string_test_ok")
        }
    }
}

eof
    scalac string_test.scala
    ret=`scala string_test`
    if [ x$ret = x"string_test_ok" ];then
        true
    else
        false
    fi 
    print_info $? "scala string test"


}

function scala_test_collection(){

    cat > list_test.scala <<- eof
    object list_test{
    def main(args:Array[String]){
        var site:List[String] = List("baidu" , "163" , "QQ")
        var num:List[Int] = List(1, 2 ,3)
        var empty:List[Nothing] = List()
        var site1 = "baidu" :: ("163" :: ("QQ" :: Nil))
        if (site == site1){
            println("list_test_ok")
        }
    }
}

eof
    scalac list_test.scala
    ret=`scala list_test`
    if [ x$ret = x"list_test_ok" ];then
        true
    else
        false
    fi 

    print_info $? "scala list test"

}

