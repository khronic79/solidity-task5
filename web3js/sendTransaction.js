import 'dotenv/config';
import Web3 from 'web3';

// НАСТРОЙКА
const networkUrl = process.env.NETWORK_URL;
const accountAddress = process.env.ACCOUNT_ADDRESS;
const privateKey = process.env.PRIVATE_KEY;
const recipientAddress = process.env.RECIPIENT_ADDRESS;
const amountToSend = 1; // 1 wei
const gasLimit = 21000;

// ИНИЦИАЛИЗАЦИЯ Web3
const web3 = new Web3(new Web3.providers.HttpProvider(networkUrl));

async function sendTransaction() {
    try {
        // Получаем текущую цену на газ.
        const gasPriceWei = await web3.eth.getGasPrice();
        console.log("Текущая цена на газ: " + gasPriceWei + " wei");

        // Преобразуем цену на газ в число (используем BigInt для точности).
        const gasPrice = BigInt(gasPriceWei);

        // Вычисляем максимальную комиссию за газ (gasPrice * gasLimit).
        const maxFee = gasPrice * BigInt(gasLimit);
        console.log("Максимальная комиссия за газ: " + web3.utils.fromWei(maxFee.toString(), 'ether') + " ETH");

        // Баланс используемого аккаунта.
        const addressBalance = await web3.eth.getBalance(recipientAddress);
        console.log("Баланс аккаунта получателя: " + web3.utils.fromWei(addressBalance.toString(), 'ether') + " ETH");

        // Баланс аккаунта получателя.
        const recipientAddressBalance = await web3.eth.getBalance(accountAddress);
        console.log("Баланс аккаунта: " + web3.utils.fromWei(recipientAddressBalance.toString(), 'ether') + " ETH");

        // Формируем объект транзакции.
        const transactionObject = {
            from: accountAddress,
            to: recipientAddress,
            value: amountToSend.toString(),
            gasPrice: gasPriceWei,
            gas: gasLimit
        };

        // 5. Подписываем транзакцию приватным ключом.
        const signedTransaction = await web3.eth.accounts.signTransaction(transactionObject, privateKey);

        // 6. Отправляем подписанную транзакцию.
        console.log("Отправка транзакции...");
        web3.eth.sendSignedTransaction(signedTransaction.rawTransaction)
            .on('transactionHash', (hash) => {
                console.log('Transaction hash:', hash);
            })
            .on('receipt', (receipt) => {
                console.log('Transaction receipt:', receipt);
            })
            .on('error', (error) => {
                console.error('Transaction error:', error);
            });
    } catch (error) {
        console.error("Произошла ошибка:", error);
    }
    
}

sendTransaction();
