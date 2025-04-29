import {
  assert,
  describe,
  test,
  clearStore,
  beforeAll,
  afterAll
} from "matchstick-as/assembly/index"
import { Address, BigInt } from "@graphprotocol/graph-ts"
import { ContractPausedEvent } from "../generated/schema"
import { ContractPausedEvent as ContractPausedEventEvent } from "../generated/UsdcDaiTokensExchange/UsdcDaiTokensExchange"
import { handleContractPausedEvent } from "../src/usdc-dai-tokens-exchange"
import { createContractPausedEventEvent } from "./usdc-dai-tokens-exchange-utils"

// Tests structure (matchstick-as >=0.5.0)
// https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

describe("Describe entity assertions", () => {
  beforeAll(() => {
    let paused = "boolean Not implemented"
    let newContractPausedEventEvent = createContractPausedEventEvent(paused)
    handleContractPausedEvent(newContractPausedEventEvent)
  })

  afterAll(() => {
    clearStore()
  })

  // For more test scenarios, see:
  // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

  test("ContractPausedEvent created and stored", () => {
    assert.entityCount("ContractPausedEvent", 1)

    // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
    assert.fieldEquals(
      "ContractPausedEvent",
      "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
      "paused",
      "boolean Not implemented"
    )

    // More assert options:
    // https://thegraph.com/docs/en/developer/matchstick/#asserts
  })
})
