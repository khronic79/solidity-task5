import dotenv from 'dotenv';
import { createWalletClient, http, createPublicClient, parseAbi } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { sepolia } from 'viem/chains';
import mockUSDC from '../artifacts/contracts/test/MockERC20.sol/MockERC20.json';

dotenv.config();
// Конфигурация
const RPC_URL = process.env.NETWORK_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const USDC_ADDRESS = process.env.USDC_CONTRACT_ADDRESS;
const RECIPIENT = process.env.EXCHANGE_CONTRACT_ADDRESS;
const MINT_AMOUNT = 1000n;
const erc20Abi = mockUSDC.abi;

async function mintErc20() {
  try {
    const walletClient = createWalletClient({
      chain: sepolia,
      transport: http(RPC_URL),
    });
    
    const publicClient = createPublicClient({
      chain: sepolia,
      transport: http(RPC_URL),
    });

    const account = privateKeyToAccount(`0x${PRIVATE_KEY}`)

    const decimals = await publicClient.readContract({
      address: USDC_ADDRESS as `0x${string}`,
      abi: erc20Abi,
      functionName: 'decimals',
    }) as number;

    const amount = MINT_AMOUNT * 10n ** BigInt(decimals);

    console.log(`Минтим ${MINT_AMOUNT} токенов для адреса ${RECIPIENT}...`);
    
    const hash = await walletClient.writeContract({
      address: USDC_ADDRESS as `0x${string}`,
      abi: erc20Abi,
      functionName: 'mint',
      args: [RECIPIENT, amount],
      account,
    });

    console.log('Транзакция отправлена, хэш:', hash);

    // 6. Ждем подтверждения транзакции
    const receipt = await publicClient.waitForTransactionReceipt({ hash });
    console.log('Транзакция подтверждена в блоке:', receipt.blockNumber);

    // 7. Проверяем новый баланс получателя
    const newBalance = await publicClient.readContract({
      address: USDC_ADDRESS as `0x${string}`,
      abi: erc20Abi,
      functionName: 'balanceOf',
      args: [RECIPIENT],
    }) as number;

    console.log(
      `Новый баланс получателя: ${formatUnits(BigInt(newBalance), decimals)} токенов`
    );

  } catch (error) {
    console.error('Ошибка при минте токенов:', error);
  }
}

// Вспомогательная функция для форматирования
function formatUnits(value: bigint, decimals: number): string {
  return `${Number(value / 10n ** BigInt(decimals - 2)) / 100}`;
}

mintErc20();