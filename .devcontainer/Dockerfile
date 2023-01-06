FROM mcr.microsoft.com/dotnet/sdk:3.1

RUN apt-get update \
 && apt-get install wget apt-transport-https software-properties-common -y \
 && wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && apt-get update \
 && apt-get install -y powershell \
 && wget https://get.helm.sh/helm-v3.4.1-linux-amd64.tar.gz \
 && tar xvf helm-v3.4.1-linux-amd64.tar.gz \
 && mv linux-amd64/helm /usr/local/bin \
 && rm -rf linux-amd64/ \
 && rm helm-v3.4.1-linux-amd64.tar.gz

RUN git clone https://github.com/springcomp/azure-api-management-devops-resource-kit.git /tmp/apim-templates/ \
 && cd /tmp/apim-templates/src/APIM_ARMTemplate/apimtemplate \
 && git checkout 389909db01d3ca1aeeec75ce011f9bd19aeaf94e \
 && dotnet publish -c Release \
 && dotnet pack -c Release \
 && dotnet tool install -g --add-source ./bin/Release/ apim-templates

SHELL ["/usr/bin/pwsh", "-c"]

RUN Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

RUN New-Item -ItemType Directory -Path /root/.config -EA SilentlyContinue | Out-Null; \
    New-Item -ItemType Directory -Path /root/.config/powershell -EA SilentlyContinue | Out-Null;

COPY ./Microsoft.PowerShell_profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1
 
ENV PATH "$PATH:/root/.dotnet/tools/"

WORKDIR /workspace