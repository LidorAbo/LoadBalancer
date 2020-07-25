# LoadBalancer
Three virtual machines(loadbalancer and two web servers) that built with Vagrant, VirtualBox and Puppet.

 **Features**
 - Loadbalancer server that runs HAPROXY(listrning in port 80) as  a service and acts as a monitoring server that runs Prometheus(listening in port 9090):

    - Sending notification to my email when CPU/RAM is higher than 80 percentage

    - Sending notification to my email when one of the VMS not responding to HTTP request 
 - Two web servers that runs NGINX(port 80) as a service when each webserver with html page that print "Hello World!"

  **Requierements**
  - VirtualBox
  - Vagrant
  
  **VMS**
    
  - haproxy &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;10.0.0.2
  - webserver1  10.0.0.3
  - webserver2  10.0.0.4

   **Running**
```bash
 vagrant up
```

**👉After you running the above command you can access the above servers from 
```bash
 vagrant ssh               
``` 
command or from url in the following format IP:PORT to one of the webservers page or prometheous console.