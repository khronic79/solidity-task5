import { createWalletClient, http, createPublicClient, defineChain } from 'viem';
import { sepolia } from 'viem/chains';
import { privateKeyToAccount } from 'viem/accounts';
import dotenv from 'dotenv';
import UsdcDaiTokensExchange from '../artifacts/contracts/UsdcDaiTokensExchange.sol/UsdcDaiTokensExchange.json';
import MockUSDC from '../artifacts/contracts/test/MockERC20.sol/MockERC20.json';
import MockDAI from '../artifacts/contracts/test/MockERC20.sol/MockERC20.json';
import MockPriceFeed from '../artifacts/contracts/test/MockAggregatorV3.sol/MockAggregatorV3.json';

dotenv.config();

const RPC_URL = process.env.NETWORK_URL;
const privateKey = '0x' + process.env.PRIVATE_KEY;

const walletClient = createWalletClient({
  chain: sepolia,
  transport: http(RPC_URL),
});

const publicClient = createPublicClient({
  chain: sepolia,
  transport: http(RPC_URL),
});

const account = privateKeyToAccount(privateKey as `0x${string}`);

async function deployMockContracts() {
  const usdcHash = await walletClient.deployContract({
    abi: MockUSDC.abi,
    bytecode: MockUSDC.bytecode as `0x${string}`,
    account,
    args: ['Mock USDC', 'USDC', 6],
  });
  
  const usdcReceipt = await publicClient.waitForTransactionReceipt({ hash: usdcHash });
  const usdcAddress = usdcReceipt.contractAddress;
  if (!usdcAddress) throw new Error('Ошибка деплоя Mock USDC');

  const daiHash = await walletClient.deployContract({
    abi: MockDAI.abi,
    bytecode: MockDAI.bytecode as `0x${string}`,
    account,
    args: ['Mock DAI', 'DAI', 18],
  });
  
  const daiReceipt = await publicClient.waitForTransactionReceipt({ hash: daiHash });
  const daiAddress = daiReceipt.contractAddress;
  if (!daiAddress) throw new Error('Ошибка деплоя Mock DAI');

  const usdcPriceFeedHash = await walletClient.deployContract({
    abi: MockPriceFeed.abi,
    bytecode: MockPriceFeed.bytecode as `0x${string}`,
    account,
    args: [8, 1e8],
  });
  
  const usdcPriceFeedReceipt = await publicClient.waitForTransactionReceipt({ hash: usdcPriceFeedHash })
  const usdcPriceFeedAddress = usdcPriceFeedReceipt.contractAddress
  if (!usdcPriceFeedAddress) throw new Error('Ошибка деплоя USDC Price Feed')

  const daiPriceFeedHash = await walletClient.deployContract({
    abi: MockPriceFeed.abi,
    bytecode: MockPriceFeed.bytecode as `0x${string}`,
    account,
    args: [8, 1e8],
  });
  
  const daiPriceFeedReceipt = await publicClient.waitForTransactionReceipt({ hash: daiPriceFeedHash });
  const daiPriceFeedAddress = daiPriceFeedReceipt.contractAddress;
  if (!daiPriceFeedAddress) throw new Error('Ошибка деплоя DAI Price Feed');

  return {
    usdcAddress,
    daiAddress,
    usdcPriceFeedAddress,
    daiPriceFeedAddress
  };
}

async function deployExchangeContract(mockAddresses: {
  usdcAddress: `0x${string}`,
  daiAddress: `0x${string}`,
  usdcPriceFeedAddress: `0x${string}`,
  daiPriceFeedAddress: `0x${string}`
}) {
  
  const exchangeHash = await walletClient.deployContract({
    abi: UsdcDaiTokensExchange.abi,
    bytecode: UsdcDaiTokensExchange.bytecode as `0x${string}`,
    account,
    args: [
      mockAddresses.usdcPriceFeedAddress,
      mockAddresses.daiPriceFeedAddress,
      mockAddresses.usdcAddress,
      mockAddresses.daiAddress
    ],
  });

  const exchangeReceipt = await publicClient.waitForTransactionReceipt({ hash: exchangeHash });
  const exchangeAddress = exchangeReceipt.contractAddress;
  if (!exchangeAddress) throw new Error('Ошибка деплоя контракта обмена');

  return exchangeAddress;
}

async function main() {
  try {
    const mockAddresses = await deployMockContracts();
    
    const exchangeAddress = await deployExchangeContract(mockAddresses);
    
    console.log('Контракт обмена:', exchangeAddress);
    console.log('Mock USDC:', mockAddresses.usdcAddress);
    console.log('Mock DAI:', mockAddresses.daiAddress);
    console.log('Mock USDC Price Feed:', mockAddresses.usdcPriceFeedAddress);
    console.log('Mock DAI Price Feed:', mockAddresses.daiPriceFeedAddress);
    
  } catch (error) {
    console.error('Ошибка при деплое:', error);
    process.exit(1);
  }
}

main();