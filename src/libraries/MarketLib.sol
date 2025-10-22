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

/**
 * @title MarketLib
 * @notice Library containing market-related structs and enums
 */
library MarketLib {

    // ============================================
    // Enums
    // ============================================

    /**
     * @notice Market lifecycle status
     * @param Open Market is active and awaiting resolution
     * @param Resolved Market has been resolved by AI
     * @param Cancelled Market was cancelled before resolution
     */
    enum MarketStatus {
        Open,
        Resolved,
        Cancelled
    }

    // ============================================
    // Structs
    // ============================================

    /**
     * @notice Complete market data structure
     * @param id Unique market identifier
     * @param creator Address that created the market
     * @param question The prediction market question
     * @param description Additional context and details
     * @param possibleOutcomes Array of possible outcome strings (e.g., ["Yes", "No"], ["Team A", "Team B", "Draw"])
     * @param createdAt Timestamp when market was created
     * @param resolutionTimestamp When the market should be resolved
     * @param status Current market status
     * @param outcomeIndex Index of the resolved outcome in possibleOutcomes array (type(uint256).max if not resolved)
     * @param resolutionData AI-generated resolution explanation/proof
     * @param resolutionSources Array of source URLs used for resolution
     * @param resolutionConfidence Confidence level of the resolution (0-100)
     * @param proofData TEE attestation or cryptographic proof of AI execution (for future verification)
     * @param resolvedAt Timestamp when market was resolved
     * @param resolvedBy Address that resolved the market
     */
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
        string[] resolutionSources;
        uint8 resolutionConfidence;
        bytes proofData;
        uint256 resolvedAt;
        address resolvedBy;
    }

    /// @notice Constant representing no outcome selected yet
    uint256 constant OUTCOME_NOT_RESOLVED = type(uint256).max;

    // ============================================
    // Helper Functions
    // ============================================

    /**
     * @notice Check if a market exists
     * @param market The market to check
     * @return true if market exists (id > 0)
     */
    function exists(Market storage market) internal view returns (bool) {
        return market.id > 0;
    }

    /**
     * @notice Check if a market is open
     * @param market The market to check
     * @return true if market status is Open
     */
    function isOpen(Market storage market) internal view returns (bool) {
        return market.status == MarketStatus.Open;
    }

    /**
     * @notice Check if a market is resolved
     * @param market The market to check
     * @return true if market status is Resolved
     */
    function isResolved(Market storage market) internal view returns (bool) {
        return market.status == MarketStatus.Resolved;
    }

    /**
     * @notice Check if a market is cancelled
     * @param market The market to check
     * @return true if market status is Cancelled
     */
    function isCancelled(Market storage market) internal view returns (bool) {
        return market.status == MarketStatus.Cancelled;
    }

    /**
     * @notice Check if resolution time has passed
     * @param market The market to check
     * @return true if current time >= resolutionTimestamp
     */
    function canResolve(Market storage market) internal view returns (bool) {
        return block.timestamp >= market.resolutionTimestamp;
    }
}
