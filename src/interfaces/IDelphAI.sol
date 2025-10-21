// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

/*
██████╗ ███████╗██╗     ██████╗ ██╗  ██╗ █████╗ ██╗
██╔══██╗██╔════╝██║     ██╔══██╗██║  ██║██╔══██╗██║
██║  ██║█████╗  ██║     ██████╔╝███████║███████║██║
██║  ██║██╔══╝  ██║     ██╔═══╝ ██╔══██║██╔══██║██║
██████╔╝███████╗███████╗██║     ██║  ██║██║  ██║██║
╚═════╝ ╚══════╝╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝

AI-Powered Prediction Market Oracle
https://delphai.io
*/

import {MarketLib} from "../libraries/MarketLib.sol";

/**
 * @title IDelphAI
 * @notice Interface for the DelphAI prediction market oracle
 */
interface IDelphAI {

    // ============================================
    // Market Functions
    // ============================================

    /**
     * @notice Create a new prediction market
     * @param question The market question
     * @param description Additional context/details
     * @param possibleOutcomes Array of possible outcome strings (min 2)
     * @param resolutionTimestamp When the market should be resolved
     * @return marketId The unique identifier for the created market
     */
    function createMarket(
        string memory question,
        string memory description,
        string[] memory possibleOutcomes,
        uint256 resolutionTimestamp
    ) external payable returns (uint256 marketId);

    /**
     * @notice Resolve a market with AI-generated outcome
     * @param marketId The market to resolve
     * @param outcomeIndex Index of the outcome in possibleOutcomes array
     * @param resolutionData AI explanation/proof of resolution
     * @param proofData TEE attestation or cryptographic proof
     */
    function resolveMarket(
        uint256 marketId,
        uint256 outcomeIndex,
        string memory resolutionData,
        bytes memory proofData
    ) external;

    /**
     * @notice Cancel a market (only creator or owner)
     * @param marketId The market to cancel
     */
    function cancelMarket(uint256 marketId) external;

    // ============================================
    // Admin Functions
    // ============================================

    /**
     * @notice Update the market creation fee
     * @param newFee New fee amount in wei
     */
    function setMarketCreationFee(uint256 newFee) external;

    /**
     * @notice Update the resolver address
     * @param newResolver New resolver address
     */
    function setResolver(address newResolver) external;

    /**
     * @notice Withdraw accumulated fees
     * @param to Recipient address
     * @param amount Amount to withdraw in wei
     */
    function withdrawFees(address payable to, uint256 amount) external;

    /**
     * @notice Recover ERC20 tokens sent to the contract by mistake
     * @param token ERC20 token address
     * @param to Recipient address
     * @param amount Amount to recover
     */
    function recoverERC20(address token, address to, uint256 amount) external;

    // ============================================
    // View Functions
    // ============================================

    /**
     * @notice Get market details
     * @param marketId The market identifier
     * @return market The complete market data
     */
    function getMarket(uint256 marketId) external view returns (MarketLib.Market memory market);

    /**
     * @notice Get the current resolver address
     * @return Resolver address
     */
    function resolver() external view returns (address);

    /**
     * @notice Get the market creation fee
     * @return Fee amount in wei
     */
    function marketCreationFee() external view returns (uint256);

    /**
     * @notice Get the total number of markets created
     * @return Total market count
     */
    function marketCounter() external view returns (uint256);

    /**
     * @notice Get the contract's ETH balance
     * @return Balance in wei
     */
    function getContractBalance() external view returns (uint256);
}
