## How to use nginx as a reverse proxy in a linux docker image hosting a dotnet asp core web app
This is some sample code to create a dotnet core web app, install nginx, configure nginx as a reverse proxy and provide a warmup script so the container is not added to the Azure web app load balancer until the application is warmed up.  This application will not have a long warm up since it is just a sample.  To understand Azure and site warm-ups please read reference this: https://github.com/AdamPaternostro/Azure-Tomcat-Web-App-Container

![alt tag](https://raw.githubusercontent.com/AdamPaternostro/azure-web-app-nginx-reverse-proxy-dotnet-core-linux/master/nginx-reverse-proxy.png)

### How to run this sample
```
Software:             Install Docker
Software:             Install .NET Core 2.1.5
Create directory:     mkdir azure-web-app-nginx-reverse-proxy-dotnet-core-linux
Change directory:     cd azure-web-app-nginx-reverse-proxy-dotnet-core-linux
Create directory:     mkdir nginxproxy
Change directory:     cd nginxproxy
Create .NET code:     dotnet new mvc
Restore Packages:     dotnet restore
Change file:          Add .UseUrls("http://*:5000/") to the Program.cs
                      WebHost.CreateDefaultBuilder(args)
                        .UseUrls("http://*:5000/")
                        .UseStartup<Startup>();
Build:                dotnet build
Run locally:          dotnet run
                      Open a browser and view: http://localhost:5000/
                      Ctrl+C to quit the dotnet run
Publish locally:      dotnet publish  
Change directory:     cd ..
Download Files:       By hand or wget these 3 files (Dockerfile, start-server.sh, azurewebsites.net)
                      wget https://raw.githubusercontent.com/AdamPaternostro/azure-web-app-nginx-reverse-proxy-dotnet-core-linux/master/Dockerfile
                      wget https://raw.githubusercontent.com/AdamPaternostro/azure-web-app-nginx-reverse-proxy-dotnet-core-linux/master/start-server.sh
                      wget https://raw.githubusercontent.com/AdamPaternostro/azure-web-app-nginx-reverse-proxy-dotnet-core-linux/master/azurewebsites.net
Build Image:          docker build -t nginxreverseproxydotnetcorelinux .
Run Image Locally:    docker run --rm -it -p 80:80 nginxreverseproxydotnetcorelinux
Edit Hosts file:      When you go to localhost you will see nginx default page
                      Mac: /private/etc/hosts 
                      Windows: C:\windows\system32\drivers\etc\hosts
                      ADD: 127.0.0.1   docker.azurewebsites.net
                      Now load docker.azurewebsites.net and you should see your app
                      Ctrl+C to stop
Clean Up Docker:      docker stop $(docker ps -aq) | docker rm $(docker ps -aq)
Upload to Azure ACR:
Login Registry:       docker login REMOVED.azurecr.io --username REMOVED --password <<REMOVED>>
Tag:                  docker tag nginxreverseproxydotnetcorelinux:latest REMOVED.azurecr.io/nginxreverseproxydotnetcorelinux:latest 
Push:                 docker push REMOVED.azurecr.io/nginxreverseproxydotnetcorelinux:latest
```

### What I changed in the "dotnet new web" app
In the file nginxproxy.csproj make sure your Target Framework is 2.1
```
<PropertyGroup>
<TargetFramework>netcoreapp2.1</TargetFramework>
</PropertyGroup>
```

In the program.cs make sure you have the UseUrls line:
```
WebHost.CreateDefaultBuilder(args)
   .UseStartup<Startup>()
   .UseUrls("http://*:5000/")
   .Build();
```  

### Notes
Since your application name will be different you will mostlikely need to change:
* You will need to change line 4 in start-server.sh
* You will need to change line 10 in start-server.sh
* Publish release mode: (dotnet publish --configuration Release)
  * You will probably build in Release mode so you will need to change line 60 in the Dockerfile
