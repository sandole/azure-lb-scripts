group=azure-load-balancer
az group create --name $group --location canadacentral
username=adminuser
password='P@ssw0rd1234'
az network vnet create \
    --resource-group $group \
    --name myVnet \
    --location canadacentral \
    --address-prefix '192.168.0.0/16' \
    --subnet-name mySubnet \
    --subnet-prefix '192.168.1.0/24'

az vm availability-set create \
    --resource-group $group \
    --name myAvailabilitySet \
    --location canadacentral \
    --platform-fault-domain-count 2 \
    --platform-update-domain-count 2

for NUM in 1 2 3
do
  az vm create \
    --name vm-eu-0$NUM \
    --resource-group $group \
    --location canadacentral \
    --availability-set myAvailabilitySet \
    --vnet-name myVnet \
    --subnet mySubnet \
    --image Win2019Datacenter \
    --admin-username $username \
    --admin-password $password \
    --nsg vm-nsg \
    --public-ip-address ""
done

for NUM in 1 2 3
do
  az vm open-port --port 80 --resource-group $group --name vm-eu-0$NUM
done

for NUM in 1 2 3
do
  az vm extension set \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name vm-eu-0$NUM \
    --resource-group $group \
    --settings '{"CommandToExecute":"powershell Add-WindowsFeature Web-Server; powershell Add-Content -Path C:\\inetpub\\wwwroot\\Default.htm -Value `\"<h1>VM-EU-0'$NUM'</h1>`\""}'
done