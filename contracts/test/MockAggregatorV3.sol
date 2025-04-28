// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MockAggregatorV3 {
    uint8 public decimals;
    int256 public price;

    constructor(uint8 decimals_, int256 price_) {
        decimals = decimals_;
        price = price_;
    }

    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    ) {
        return (0, price, 0, block.timestamp, 0);
    }

    function setPrice(int256 price_) external {
        price = price_;
    }
}