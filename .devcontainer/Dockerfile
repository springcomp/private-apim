FROM mcr.microsoft.com/dotnet/sdk:3.1

RUN git clone https://github.com/springcomp/azure-api-management-devops-resource-kit.git /tmp/apim-templates/ \
 && cd /tmp/apim-templates/src/APIM_ARMTemplate/apimtemplate \
 && git checkout 389909db01d3ca1aeeec75ce011f9bd19aeaf94e \
 && dotnet publish -c Release \
 && dotnet pack -c Release \
 && dotnet tool install -g --add-source ./bin/Release/ apim-templates

FROM mcr.microsoft.com/azure-powershell

SHELL ["/usr/bin/pwsh", "-c"]

RUN New-Item -ItemType Directory -Path /root/.config -EA SilentlyContinue | Out-Null; \
    New-Item -ItemType Directory -Path /root/.config/powershell -EA SilentlyContinue | Out-Null;

COPY ./Microsoft.PowerShell_profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1
 
ENV PATH "$PATH:/root/.dotnet/tools/"
COPY --from=0 /usr/share/dotnet/ /usr/share/dotnet/
COPY --from=0 /root/.dotnet/tools/apim-templates /root/.dotnet/tools/
COPY --from=0 /root/.dotnet/tools/.store/ /root/.dotnet/tools/.store/

COPY ./start.sh /start.sh
COPY ./post-start.sh /post-start.sh
COPY ./azdo.sh /azdo.sh
RUN chmod +x /start.sh \
 && chmod +x /post-start.sh \
 && chmod +x /azdo.sh

WORKDIR /workspace