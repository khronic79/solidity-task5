import Web3 from 'web3';
import dotenv from 'dotenv';
dotenv.config();

// Инициализация Web3
const web3 = new Web3(process.env.NETWORK_URL);
const account = web3.eth.accounts.privateKeyToAccount('0x' + process.env.PRIVATE_KEY);
web3.eth.accounts.wallet.add(account);

// ABI контрактов
const ExchangeABI = [
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_usdcAmount",
        "type": "uint256"
      }
    ],
    "name": "exchangeUsdcForDai",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "user",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "fromToken",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "fromAmount",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "address",
        "name": "toToken",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "toAmount",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "feeAmount",
        "type": "uint256"
      }
    ],
    "name": "Exchange",
    "type": "event"
  }
];

const ERC20ABI = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "spender",
        "type": "address"
      },
      {
        "internalType": "uint256",
        "name": "value",
        "type": "uint256"
      }
    ],
    "name": "approve",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

// Инициализация контракта для обмена
const exchangeContract = new web3.eth.Contract(
  ExchangeABI, 
  process.env.EXCHANGE_CONTRACT_ADDRESS
);

// Инициализация контракта USDC
const usdc = new web3.eth.Contract(ERC20ABI, process.env.USDC_CONTRACT_ADDRESS);

async function main() {
  try {
    
    console.log('Выдача разрешения на трансфер...');
    // Выдача разрешения контракту на трансфер USDC
    await usdc.methods.approve(process.env.EXCHANGE_CONTRACT_ADDRESS, '10000000')
      .send({ from: account.address });
    
    console.log('Старт обмена...');
    // Выполнение обмена
    const tx = await exchangeContract.methods.exchangeUsdcForDai('10000000')
      .send({ from: account.address });
    
  } catch (error) {
    console.error('Error:', error.message);
  }
}

main();