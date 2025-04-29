import {
  ContractPausedEvent as ContractPausedEventEvent,
  Exchange as ExchangeEvent,
  FeeUpdated as FeeUpdatedEvent,
  OwnershipTransferred as OwnershipTransferredEvent
} from "../generated/UsdcDaiTokensExchange/UsdcDaiTokensExchange"
import {
  ContractPausedEvent,
  Exchange,
  FeeUpdated,
  OwnershipTransferred
} from "../generated/schema"

export function handleContractPausedEvent(
  event: ContractPausedEventEvent
): void {
  let entity = new ContractPausedEvent(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.paused = event.params.paused

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleExchange(event: ExchangeEvent): void {
  let entity = new Exchange(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.user = event.params.user
  entity.fromToken = event.params.fromToken
  entity.fromAmount = event.params.fromAmount
  entity.toToken = event.params.toToken
  entity.toAmount = event.params.toAmount
  entity.feeAmount = event.params.feeAmount

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleFeeUpdated(event: FeeUpdatedEvent): void {
  let entity = new FeeUpdated(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.newFee = event.params.newFee

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}
