# izumiswap için hazırlanmış Monad ağında wrap and unwrap scripti
het 55 dakikada bir çalışır, birkaç tane işlem yapar, her işlem arasında bir müddet bekler

    git clone https://github.com/madmin27/Monad-izumi.git
    cd Monad-izumi

    npm install
.evm edit, import private key of burn wallet
    
    nano .env
start check

    node izumiMonad.js

is okey add,  add crontab

    crontab -e
*/55 * * * * cd /root/Monad-izumi && node izumiMonad.js >> /root/Monad-izumi/izumiswap.txt 2>&1
  
  

