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
 * @title DelphAIErrors
 * @notice Custom errors for the DelphAI protocol
 * @dev Using custom errors saves gas compared to require strings
 */
interface DelphAIErrors {

    // ============================================
    // Access Control Errors
    // ============================================

    /// @notice Thrown when caller is not the resolver
    error Unauthorized_NotResolver();

    /// @notice Thrown when caller is not the market creator
    error Unauthorized_NotCreator();

    /// @notice Thrown when caller is not authorized for the action
    error Unauthorized_NotCreatorOrOwner();

    // ============================================
    // Market Errors
    // ============================================

    /// @notice Thrown when market ID does not exist
    /// @param marketId The invalid market ID
    error Market_DoesNotExist(uint256 marketId);

    /// @notice Thrown when market is not in Open status
    /// @param marketId The market ID
    /// @param currentStatus The current status of the market
    error Market_NotOpen(uint256 marketId, uint8 currentStatus);

    /// @notice Thrown when trying to resolve before resolution timestamp
    /// @param marketId The market ID
    /// @param currentTime Current block timestamp
    /// @param resolutionTime Required resolution timestamp
    error Market_TooEarlyToResolve(uint256 marketId, uint256 currentTime, uint256 resolutionTime);

    /// @notice Thrown when resolution timestamp is not in the future
    /// @param resolutionTimestamp The provided timestamp
    /// @param currentTime Current block timestamp
    error Market_ResolutionMustBeInFuture(uint256 resolutionTimestamp, uint256 currentTime);

    /// @notice Thrown when market question is empty
    error Market_QuestionRequired();

    /// @notice Thrown when possibleOutcomes array has less than 2 options
    error Market_InsufficientOutcomes();

    /// @notice Thrown when outcome index is out of bounds
    /// @param index The provided index
    /// @param maxIndex Maximum valid index (length - 1)
    error Market_InvalidOutcomeIndex(uint256 index, uint256 maxIndex);

    /// @notice Thrown when resolution confidence is out of valid range (0-100)
    /// @param confidence The provided confidence value
    error Market_InvalidConfidence(uint8 confidence);

    // ============================================
    // Fee Errors
    // ============================================

    /// @notice Thrown when insufficient fee is provided for market creation
    /// @param provided Amount provided
    /// @param required Amount required
    error Fee_InsufficientCreationFee(uint256 provided, uint256 required);

    /// @notice Thrown when trying to withdraw more than available balance
    /// @param requested Amount requested
    /// @param available Amount available
    error Fee_InsufficientBalance(uint256 requested, uint256 available);

    /// @notice Thrown when fee transfer fails
    error Fee_TransferFailed();

    // ============================================
    // Input Validation Errors
    // ============================================

    /// @notice Thrown when zero address is provided where not allowed
    error Invalid_ZeroAddress();

    /// @notice Thrown when invalid parameter is provided
    /// @param parameter Name of the invalid parameter
    error Invalid_Parameter(string parameter);
}
