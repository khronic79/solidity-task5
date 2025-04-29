import { newMockEvent } from "matchstick-as"
import { ethereum, Address, BigInt } from "@graphprotocol/graph-ts"
import {
  ContractPausedEvent,
  Exchange,
  FeeUpdated,
  OwnershipTransferred
} from "../generated/UsdcDaiTokensExchange/UsdcDaiTokensExchange"

export function createContractPausedEventEvent(
  paused: boolean
): ContractPausedEvent {
  let contractPausedEventEvent = changetype<ContractPausedEvent>(newMockEvent())

  contractPausedEventEvent.parameters = new Array()

  contractPausedEventEvent.parameters.push(
    new ethereum.EventParam("paused", ethereum.Value.fromBoolean(paused))
  )

  return contractPausedEventEvent
}

export function createExchangeEvent(
  user: Address,
  fromToken: Address,
  fromAmount: BigInt,
  toToken: Address,
  toAmount: BigInt,
  feeAmount: BigInt
): Exchange {
  let exchangeEvent = changetype<Exchange>(newMockEvent())

  exchangeEvent.parameters = new Array()

  exchangeEvent.parameters.push(
    new ethereum.EventParam("user", ethereum.Value.fromAddress(user))
  )
  exchangeEvent.parameters.push(
    new ethereum.EventParam("fromToken", ethereum.Value.fromAddress(fromToken))
  )
  exchangeEvent.parameters.push(
    new ethereum.EventParam(
      "fromAmount",
      ethereum.Value.fromUnsignedBigInt(fromAmount)
    )
  )
  exchangeEvent.parameters.push(
    new ethereum.EventParam("toToken", ethereum.Value.fromAddress(toToken))
  )
  exchangeEvent.parameters.push(
    new ethereum.EventParam(
      "toAmount",
      ethereum.Value.fromUnsignedBigInt(toAmount)
    )
  )
  exchangeEvent.parameters.push(
    new ethereum.EventParam(
      "feeAmount",
      ethereum.Value.fromUnsignedBigInt(feeAmount)
    )
  )

  return exchangeEvent
}

export function createFeeUpdatedEvent(newFee: BigInt): FeeUpdated {
  let feeUpdatedEvent = changetype<FeeUpdated>(newMockEvent())

  feeUpdatedEvent.parameters = new Array()

  feeUpdatedEvent.parameters.push(
    new ethereum.EventParam("newFee", ethereum.Value.fromUnsignedBigInt(newFee))
  )

  return feeUpdatedEvent
}

export function createOwnershipTransferredEvent(
  previousOwner: Address,
  newOwner: Address
): OwnershipTransferred {
  let ownershipTransferredEvent =
    changetype<OwnershipTransferred>(newMockEvent())

  ownershipTransferredEvent.parameters = new Array()

  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam(
      "previousOwner",
      ethereum.Value.fromAddress(previousOwner)
    )
  )
  ownershipTransferredEvent.parameters.push(
    new ethereum.EventParam("newOwner", ethereum.Value.fromAddress(newOwner))
  )

  return ownershipTransferredEvent
}
