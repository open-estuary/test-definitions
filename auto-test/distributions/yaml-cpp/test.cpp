    #include <iostream>  
    #include <fstream>   
    #include <string>  
    #include "yaml.h"  
      
    using namespace std;  
      
    //最新的yaml-cpp 0.5取消了运算符">>"，但是还是会有好多的旧代码  
    //依旧在使用，所以重载下">>"运算符  
    template<typename T>  
    void operator >> (const YAML::Node& node, T& i)  
    {  
      i = node.as<T>();  
    }  
      
    void configure(const YAML::Node& node);  
    void nodePrint(const YAML::Node& node);  
      
    int main()  
    {  
      YAML::Node config = YAML::LoadFile("../cmd_mux.yaml");    
        
      configure(config["subscribers"]);  
      
      return 0;  
    }  
      
    void configure(const YAML::Node& node)  
    {  
      for (unsigned int i = 0; i < node.size(); i++)  
      {  
        nodePrint(node[i]);  
      }  
    }  
      
    void nodePrint(const YAML::Node& node)  
    {  
      string name;  
      string topic;  
      double timeout;  
      unsigned int priority;  
        
      node["name"]       >> name;  
      node["topic"]      >> topic;  
      node["timeout"]    >> timeout;  
      node["priority"]   >> priority;  
        
      cout<<"    name: "<<name<<endl;  
      cout<<"   topic: "<<topic<<endl;  
      cout<<" timeout: "<<timeout<<" seconds."<<endl;  
      cout<<"priority: "<<priority<<endl;  
    }  
