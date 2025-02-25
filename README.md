# izumiswap için hazırlanmış Monad ağında wrap and unwrap scripti
het 55 dakikada bir çalışır, birkaç tane işlem yapar, her işlem arasında bir müddet bekler

    git clone https://github.com/madmin27/izumiswap.git
    cd izumiswap

    npm install
.evm edit, import private key of burn wallet
    
    nano .env
start check

    node main.js

is okey add,  add crontab

    crontab -e
*/55 * * * * cd /root/Izumi-Swap  && node main.js >> /root/Izumi-Swap /izumiswap.txt 2>&1  
  

