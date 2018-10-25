# Software:             Install Docker
# Software:             Install .NET Core 2.1.5
# Create directory:     mkdir azure-web-app-nginx-reverse-proxy-dotnet-core-linux
# Change directory:     cd azure-web-app-nginx-reverse-proxy-dotnet-core-linux
# Create directory:     mkdir nginxproxy
# Change directory:     cd nginxproxy
# Create .NET code:     dotnet new mvc
# Restore Packages:     dotnet restore
# Change file:          Add .UseUrls("http://*:5000/") to the Program.cs
#                       WebHost.CreateDefaultBuilder(args)
#                         .UseUrls("http://*:5000/")
#                         .UseStartup<Startup>();
# Build:                dotnet build
# Run locally:          dotnet run
#                       Open a browser and view: http://localhost:5000/
#                       Ctrl+C to quit the dotnet run
# Change directory:     cd ..
# Download Files:       By hand or wget
#                       wget https://raw.githubusercontent.com/AdamPaternostro/azure-web-app-nginx-reverse-proxy-dotnet-core-linux/master/Dockerfile
#                       wget https://raw.githubusercontent.com/AdamPaternostro/azure-web-app-nginx-reverse-proxy-dotnet-core-linux/master/start-server.sh
#                       wget https://raw.githubusercontent.com/AdamPaternostro/azure-web-app-nginx-reverse-proxy-dotnet-core-linux/master/azurewebsites.net
# Publish locally:      dotnet publish  
# Change directory:     cd ..
# Build Image:          docker build -t nginxreverseproxydotnetcorelinux .
# Run Image Locally:    docker run --rm -it -p 80:80 nginxreverseproxydotnetcorelinux
# Edit Hosts file:      When you go to localhost you will see nginx default page
#                       Mac: /private/etc/hosts 
#                       Windows: C:\windows\system32\drivers\etc\hosts
#                       ADD: 127.0.0.1   docker.azurewebsites.net
#                       Now load docker.azurewebsites.net and you should see your app
#                       Ctrl+C to stop
# Clean Up Docker:      docker stop $(docker ps -aq) | docker rm $(docker ps -aq)
# Upload to Azure ACR:
# Login Registry:       docker login REMOVED.azurecr.io --username REMOVED --password REMOVED
# Tag:                  docker tag nginxreverseproxydotnetcorelinux:latest REMOVED.azurecr.io/nginxreverseproxydotnetcorelinux:latest 
# Push:                 docker push REMOVED.azurecr.io/nginxreverseproxydotnetcorelinux:latest

# References:
# https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-2.1&tabs=aspnetcore2x
# https://github.com/dotnet/dotnet-docker
# https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/
# https://www.nginx.com/resources/wiki/start/topics/examples/server_blocks/

##############################
# START: Copied from https://github.com/dotnet/dotnet-docker/blob/master/2.1/aspnetcore-runtime/stretch-slim/amd64/Dockerfile
##############################
FROM microsoft/dotnet:2.1-runtime-deps-stretch-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install ASP.NET Core
ENV ASPNETCORE_VERSION 2.1.5

RUN curl -SL --output aspnetcore.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/aspnetcore/Runtime/$ASPNETCORE_VERSION/aspnetcore-runtime-$ASPNETCORE_VERSION-linux-x64.tar.gz \
    && aspnetcore_sha512='3326963ba0a431ca430d8f1a7940487e516952ec560da563f03662b71b2ac8b5d9904b0e1422212e452b49f563349d10fea34241f4d5e4811d0aedc02c557029' \
    && echo "$aspnetcore_sha512  aspnetcore.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -zxf aspnetcore.tar.gz -C /usr/share/dotnet \
    && rm aspnetcore.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
##############################
# End: Copied from https://github.com/dotnet/dotnet-docker/blob/master/2.1/aspnetcore-runtime/stretch-slim/amd64/Dockerfile
##############################

##############################
# This is application specific
##############################
# Install nginx
RUN apt-get update && apt-get install -y nginx 

# copy the website for nginx
COPY azurewebsites.net /etc/nginx/sites-available/azurewebsites.net
RUN ln -s /etc/nginx/sites-available/azurewebsites.net /etc/nginx/sites-enabled/

# Copy and make the start script executable
COPY start-server.sh /publish/start-server.sh
RUN chmod +x /publish/start-server.sh 

# copy the locally compiled .net core code
COPY nginxproxy/bin/Debug/netcoreapp2.1/publish/ /publish

EXPOSE 80/tcp

ENTRYPOINT ["/publish/start-server.sh"]
