import { createPublicClient, http, formatEther, parseAbi, Address, Abi } from 'viem'
import { mainnet } from 'viem/chains'
import ExchContr from '../artifacts/contracts/UsdcDaiTokensExchange.sol/UsdcDaiTokensExchange.json';
import dotenv from 'dotenv';

dotenv.config();

// 1. Создаем публичный клиент
const client = createPublicClient({
  chain: mainnet, // или другая сеть
  transport: http(process.env.NETWORK_URL)
})

type ContractAbi = Abi | readonly []

// 2. Функция оценки стоимости газа для вызова контракта
export async function estimateGasCost(params: {
  contractAddress: `0x${string}`
  abi: ContractAbi
  functionName: string
  args: any[]
  fromAddress: `0x${string}`
}) {
  try {
    // Получаем текущие цены газа
    const { maxFeePerGas, maxPriorityFeePerGas } = await client.estimateFeesPerGas()
    
    // Оцениваем количество газа для операции
    const gasEstimate = await client.estimateContractGas({
      address: params.contractAddress,
      abi: params.abi,
      functionName: params.functionName,
      args: params.args,
      account: params.fromAddress
    })

    // Рассчитываем стоимость
    const maxCost = gasEstimate * maxFeePerGas
    const priorityCost = gasEstimate * maxPriorityFeePerGas

    return {
      gasLimit: gasEstimate,
      maxFeePerGas,
      maxPriorityFeePerGas,
      estimatedMaxCost: maxCost,
      estimatedPriorityCost: priorityCost,
      formatted: {
        gasLimit: gasEstimate.toString(),
        maxFeePerGas: formatEther(maxFeePerGas),
        maxPriorityFeePerGas: formatEther(maxPriorityFeePerGas),
        estimatedMaxCost: formatEther(maxCost),
        estimatedPriorityCost: formatEther(priorityCost)
      }
    }
  } catch (error) {
    console.error('Gas estimation failed:', error)
    throw error
  }
}

// 3. Пример использования
async function exampleUsage() {
  const estimation = await estimateGasCost({
    contractAddress: process.env.EXCHANGE_CONTRACT_ADDRESS as Address,
    abi: ExchContr.abi as Abi,
    functionName: 'exchangeUsdcForDai',
    args: [100n],
    fromAddress: process.env.ACCOUNT_ADDRESS as Address
  })

  console.log('Gas Estimation Results:')
  console.log('-----------------------')
  console.log('Gas Limit:', estimation.formatted.gasLimit)
  console.log('Max Fee Per Gas:', estimation.formatted.maxFeePerGas, 'ETH')
  console.log('Max Priority Fee:', estimation.formatted.maxPriorityFeePerGas, 'ETH')
  console.log('Estimated Max Cost:', estimation.formatted.estimatedMaxCost, 'ETH')
  console.log('Estimated Priority Cost:', estimation.formatted.estimatedPriorityCost, 'ETH')
}

exampleUsage()