require('dotenv').config();  
const { ethers } = require('ethers');  
const readline = require('readline');  
const fs = require('fs');  

const RPC_URL = "https://testnet-rpc.monad.xyz/";  

// PRIVATE_KEY değişkeninde birden çok anahtar virgülle ayrılarak tanımlanabilir.  
// Örneğin: PRIVATE_KEY=key1,key2,key3  
let privateKeys = [];  
if (process.env.PRIVATE_KEY) {  
    privateKeys = process.env.PRIVATE_KEY.split(',')  
        .map(key => key.trim())  
        .map(key => key.startsWith('0x') ? key : `0x${key}`);  
}  

const provider = new ethers.JsonRpcProvider(RPC_URL);  

const WMON_CONTRACT_ADDRESS = "0x760AfE86e5de5fa0Ee542fc7B7B713e1c5425701";  

const WMON_ABI = [  
    "function deposit() public payable",  
    "function withdraw(uint256 wad) public"  
];  

// 🔹 Terminalden giriş için fonksiyon  
const rl = readline.createInterface({  
    input: process.stdin,  
    output: process.stdout  
});  

async function wrapMON(wallet, amount) {  
    try {  
        const wmonContract = new ethers.Contract(WMON_CONTRACT_ADDRESS, WMON_ABI, wallet);  
        const amountIn = ethers.parseUnits(amount.toFixed(18), 18);  

        console.log(`⏳ Cüzdan ${wallet.address}: ${amount} MON'u WMON'a dönüştürüyor...`);  
        const tx = await wmonContract.deposit({ value: amountIn });  
        console.log(`✅ Cüzdan ${wallet.address}: Dönüştürme başarılı! Tx:`, tx.hash);  

        await tx.wait();  
        console.log(`🎉 Cüzdan ${wallet.address}: WMON arttı!`);  
    } catch (error) {  
        console.error(`❌ Cüzdan ${wallet.address}: Dönüştürme başarısız`, error);  
    }  
}  

async function unwrapWMON(wallet, amount) {  
    try {  
        amount = parseFloat(Math.max(0, amount - 0.001).toFixed(4));  
        const wmonContract = new ethers.Contract(WMON_CONTRACT_ADDRESS, WMON_ABI, wallet);  
        const amountIn = ethers.parseUnits(amount.toString(), 18);  

        console.log(`⏳ Cüzdan ${wallet.address}: ${amount} WMON'u MON'a dönüştürüyor...`);  
        const tx = await wmonContract.withdraw(amountIn);  
        console.log(`✅ Cüzdan ${wallet.address}: Dönüştürme başarılı! Tx:`, tx.hash);  

        await tx.wait();  
        console.log(`🎉 Cüzdan ${wallet.address}: MON arttı!`);  
    } catch (error) {  
        console.error(`❌ Cüzdan ${wallet.address}: Dönüştürme başarısız`, error);  
    }  
}  

async function autoSwap() {  
    const tekrar = Math.floor(Math.random() * (9 - 4 + 1)) + 4;  
    console.log(`\n🔁 İşlem tekrar sayısı: ${tekrar}`);  

    const amount = parseFloat((Math.random() * (0.03 - 0.002) + 0.002).toFixed(4));  
    console.log(`💰 İşlem miktarı: ${amount} MON`);  
    const repeatCount = parseInt(tekrar);  

    for (let i = 1; i <= repeatCount; i++) {  
        console.log(`\n🔄 **Döngü ${i} / ${repeatCount}** 🔄`);  

        for (let key of privateKeys) {  
            const wallet = new ethers.Wallet(key, provider);  

            await wrapMON(wallet, amount);  
            // 2 ile 4 dakika arası rastgele bekle  
            const waitfonarasi = Math.floor(Math.random() * (4 - 2 + 1) + 2) * 60 * 1000;  
            console.log(`⏳ ${waitfonarasi / 60000} dakika bekleniyor...`);  
            await new Promise(resolve => setTimeout(resolve, waitfonarasi));  
            await unwrapWMON(wallet, amount);  

            console.log(`✅ **Döngü ${i} cüzdan ${wallet.address} için tamamlandı**`);  

            // 2 ile 8 dakika arası rastgele bekle  
            const waitTime = Math.floor(Math.random() * (8 - 2 + 1) + 2) * 60 * 1000;  
            console.log(`⏳ ${waitTime / 60000} dakika bekleniyor...`);  
            await new Promise(resolve => setTimeout(resolve, waitTime));  
        }  
    }  
    
    console.log("\n🎉 **Tüm cüzdanlar için tüm işlemler tamamlandı!**");  
}  

async function main() {  
    if (privateKeys.length === 0) {  
        console.log("❌ Hiçbir özel anahtar bulunamadı! Lütfen `.env` dosyasını doldurduğunuzdan emin olun.");  
        return;  
    }  

    await autoSwap();  

    rl.close();  
}  

main();  

// Hata tanımlaması  
function error(message) {  
    return new TypeError(message);  
}  
