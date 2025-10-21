// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// DelphAI Integration Example - Copy & Paste Ready

interface IDelphAI {
    function createMarket(
        string memory question,
        string memory description,
        string[] memory possibleOutcomes,
        uint256 resolutionTimestamp
    ) external payable returns (uint256);

    function getMarket(uint256 marketId) external view returns (Market memory);
    function marketCreationFee() external view returns (uint256);
}

struct Market {
    uint256 id;
    address creator;
    string question;
    string description;
    string[] possibleOutcomes;
    uint256 createdAt;
    uint256 resolutionTimestamp;
    MarketStatus status;
    uint256 outcomeIndex;
    string resolutionData;
    bytes proofData;
    uint256 resolvedAt;
    address resolvedBy;
}

enum MarketStatus { Open, Resolved, Cancelled }

contract MyPredictionMarket {
    IDelphAI public immutable delphAI;

    constructor(address _delphAI) {
        delphAI = IDelphAI(_delphAI);
    }

    // Create a Yes/No market
    function createYesNoMarket(
        string memory question,
        string memory description,
        uint256 resolutionTime
    ) external payable returns (uint256) {
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        return delphAI.createMarket{value: msg.value}(
            question,
            description,
            outcomes,
            resolutionTime
        );
    }

    // Create a multi-choice market
    function createMultiChoiceMarket(
        string memory question,
        string memory description,
        string[] memory outcomes,
        uint256 resolutionTime
    ) external payable returns (uint256) {
        require(outcomes.length >= 2, "Need at least 2 outcomes");

        return delphAI.createMarket{value: msg.value}(
            question,
            description,
            outcomes,
            resolutionTime
        );
    }

    // Get the winning outcome after resolution
    function getWinningOutcome(uint256 marketId) external view returns (string memory) {
        Market memory market = delphAI.getMarket(marketId);
        require(market.status == MarketStatus.Resolved, "Not resolved yet");

        return market.possibleOutcomes[market.outcomeIndex];
    }

    // Get AI resolution explanation
    function getAIExplanation(uint256 marketId) external view returns (string memory) {
        Market memory market = delphAI.getMarket(marketId);
        return market.resolutionData;
    }
}
