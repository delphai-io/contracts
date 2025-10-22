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
 * @title IDelphAIEvents
 * @notice Events emitted by the DelphAI protocol
 */
interface IDelphAIEvents {

    // ============================================
    // Market Events
    // ============================================

    /**
     * @notice Emitted when a new market is created
     * @param marketId The unique market identifier
     * @param creator Address that created the market
     * @param question The market question
     * @param description Additional context/details
     * @param possibleOutcomes Array of possible outcome strings
     * @param createdAt Block timestamp when created
     * @param resolutionTimestamp When the market should be resolved
     */
    event MarketCreated(
        uint256 indexed marketId,
        address indexed creator,
        string question,
        string description,
        string[] possibleOutcomes,
        uint256 createdAt,
        uint256 resolutionTimestamp
    );

    /**
     * @notice Emitted when a market is resolved by the AI
     * @param marketId The market identifier
     * @param outcomeIndex Index of the resolved outcome in possibleOutcomes array
     * @param outcome The actual outcome string that was selected
     * @param resolver Address that resolved the market
     * @param resolutionData AI explanation/proof
     * @param resolutionSources Array of source URLs used for resolution
     * @param resolutionConfidence Confidence level of the resolution (0-100)
     * @param proofData TEE attestation or cryptographic proof
     * @param resolvedAt Block timestamp when resolved
     */
    event MarketResolved(
        uint256 indexed marketId,
        uint256 outcomeIndex,
        string outcome,
        address indexed resolver,
        string resolutionData,
        string[] resolutionSources,
        uint8 resolutionConfidence,
        bytes proofData,
        uint256 resolvedAt
    );

    /**
     * @notice Emitted when a market is cancelled
     * @param marketId The market identifier
     * @param cancelledBy Address that cancelled the market
     * @param cancelledAt Block timestamp when cancelled
     */
    event MarketCancelled(
        uint256 indexed marketId,
        address indexed cancelledBy,
        uint256 cancelledAt
    );

    // ============================================
    // Admin Events
    // ============================================

    /**
     * @notice Emitted when the market creation fee is updated
     * @param oldFee Previous fee amount
     * @param newFee New fee amount
     */
    event FeeUpdated(
        uint256 oldFee,
        uint256 newFee
    );

    /**
     * @notice Emitted when the resolver is changed
     * @param oldResolver Previous resolver address
     * @param newResolver New resolver address
     */
    event ResolverUpdated(
        address indexed oldResolver,
        address indexed newResolver
    );

    /**
     * @notice Emitted when fees are withdrawn
     * @param to Recipient address
     * @param amount Amount withdrawn
     */
    event FeesWithdrawn(
        address indexed to,
        uint256 amount
    );

    /**
     * @notice Emitted when ERC20 tokens are recovered
     * @param token ERC20 token address
     * @param to Recipient address
     * @param amount Amount recovered
     */
    event TokensRecovered(
        address indexed token,
        address indexed to,
        uint256 amount
    );
}
