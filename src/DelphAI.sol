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

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IDelphAI} from "./interfaces/IDelphAI.sol";
import {IDelphAIEvents} from "./interfaces/IDelphAIEvents.sol";
import {DelphAIErrors} from "./errors/DelphAIErrors.sol";
import {MarketLib} from "./libraries/MarketLib.sol";

/**
 * @title DelphAI
 * @notice Permissionless AI-powered prediction market oracle
 * @dev Oracles create markets onchain, AI resolvers settle them offchain
 * @author DelphAI Team
 */
contract DelphAI is Ownable, IDelphAI, IDelphAIEvents, DelphAIErrors {
    using MarketLib for MarketLib.Market;
    using SafeERC20 for IERC20;

    // ============================================
    // State Variables
    // ============================================

    /// @notice AI resolver address (offchain component)
    address public resolver;

    /// @notice Fee required to create a market (in native ETH)
    uint256 public marketCreationFee;

    /// @notice Total number of markets created
    uint256 public marketCounter;

    /// @notice Mapping from market ID to market data
    mapping(uint256 => MarketLib.Market) private _markets;

    // ============================================
    // Constructor
    // ============================================

    /**
     * @notice Initialize the DelphAI contract
     * @param _owner Initial contract owner
     * @param _resolver Initial AI resolver address
     * @param _marketCreationFee Initial market creation fee
     */
    constructor(
        address _owner,
        address _resolver,
        uint256 _marketCreationFee
    ) Ownable(_owner) {
        if (_resolver == address(0)) revert Invalid_ZeroAddress();

        resolver = _resolver;
        marketCreationFee = _marketCreationFee;
    }

    // ============================================
    // Modifiers
    // ============================================

    /// @notice Restrict function to resolver only
    modifier onlyResolver() {
        if (msg.sender != resolver) revert Unauthorized_NotResolver();
        _;
    }

    /// @notice Ensure market exists
    modifier marketExists(uint256 marketId) {
        if (!_markets[marketId].exists()) revert Market_DoesNotExist(marketId);
        _;
    }

    // ============================================
    // Market Functions
    // ============================================

    /// @inheritdoc IDelphAI
    function createMarket(
        string memory question,
        string memory description,
        string[] memory possibleOutcomes,
        uint256 resolutionTimestamp
    ) external payable returns (uint256) {
        // Validate fee
        if (msg.value < marketCreationFee) {
            revert Fee_InsufficientCreationFee(msg.value, marketCreationFee);
        }

        // Validate inputs
        if (bytes(question).length == 0) revert Market_QuestionRequired();
        if (possibleOutcomes.length < 2) revert Market_InsufficientOutcomes();
        if (resolutionTimestamp <= block.timestamp) {
            revert Market_ResolutionMustBeInFuture(resolutionTimestamp, block.timestamp);
        }

        // Create market
        marketCounter++;
        uint256 marketId = marketCounter;

        _markets[marketId].id = marketId;
        _markets[marketId].creator = msg.sender;
        _markets[marketId].question = question;
        _markets[marketId].description = description;
        _markets[marketId].possibleOutcomes = possibleOutcomes;
        _markets[marketId].createdAt = block.timestamp;
        _markets[marketId].resolutionTimestamp = resolutionTimestamp;
        _markets[marketId].status = MarketLib.MarketStatus.Open;
        _markets[marketId].outcomeIndex = MarketLib.OUTCOME_NOT_RESOLVED;
        _markets[marketId].resolutionData = "";
        _markets[marketId].proofData = "";
        _markets[marketId].resolvedAt = 0;
        _markets[marketId].resolvedBy = address(0);

        emit MarketCreated(
            marketId,
            msg.sender,
            question,
            description,
            possibleOutcomes,
            block.timestamp,
            resolutionTimestamp
        );

        return marketId;
    }

    /// @inheritdoc IDelphAI
    function resolveMarket(
        uint256 marketId,
        uint256 outcomeIndex,
        string memory resolutionData,
        bytes memory proofData
    ) external onlyResolver marketExists(marketId) {
        MarketLib.Market storage market = _markets[marketId];

        // Validate market status
        if (!market.isOpen()) {
            revert Market_NotOpen(marketId, uint8(market.status));
        }

        // Validate timing
        if (!market.canResolve()) {
            revert Market_TooEarlyToResolve(
                marketId,
                block.timestamp,
                market.resolutionTimestamp
            );
        }

        // Validate outcome index
        if (outcomeIndex >= market.possibleOutcomes.length) {
            revert Market_InvalidOutcomeIndex(outcomeIndex, market.possibleOutcomes.length);
        }

        // Resolve market
        market.status = MarketLib.MarketStatus.Resolved;
        market.outcomeIndex = outcomeIndex;
        market.resolutionData = resolutionData;
        market.proofData = proofData;
        market.resolvedAt = block.timestamp;
        market.resolvedBy = msg.sender;

        emit MarketResolved(
            marketId,
            outcomeIndex,
            market.possibleOutcomes[outcomeIndex],
            msg.sender,
            resolutionData,
            proofData,
            block.timestamp
        );
    }

    /// @inheritdoc IDelphAI
    function cancelMarket(uint256 marketId) external marketExists(marketId) {
        MarketLib.Market storage market = _markets[marketId];

        // Check authorization
        if (msg.sender != market.creator && msg.sender != owner()) {
            revert Unauthorized_NotCreatorOrOwner();
        }

        // Validate market status
        if (!market.isOpen()) {
            revert Market_NotOpen(marketId, uint8(market.status));
        }

        // Cancel market
        market.status = MarketLib.MarketStatus.Cancelled;
        // outcomeIndex stays as OUTCOME_NOT_RESOLVED

        emit MarketCancelled(marketId, msg.sender, block.timestamp);
    }

    // ============================================
    // Admin Functions
    // ============================================

    /// @inheritdoc IDelphAI
    function setMarketCreationFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = marketCreationFee;
        marketCreationFee = newFee;
        emit FeeUpdated(oldFee, newFee);
    }

    /// @inheritdoc IDelphAI
    function setResolver(address newResolver) external onlyOwner {
        if (newResolver == address(0)) revert Invalid_ZeroAddress();
        address oldResolver = resolver;
        resolver = newResolver;
        emit ResolverUpdated(oldResolver, newResolver);
    }

    /// @inheritdoc IDelphAI
    function withdrawFees(address payable to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert Invalid_ZeroAddress();

        uint256 balance = address(this).balance;
        if (amount > balance) {
            revert Fee_InsufficientBalance(amount, balance);
        }

        (bool success, ) = to.call{value: amount}("");
        if (!success) revert Fee_TransferFailed();

        emit FeesWithdrawn(to, amount);
    }

    // ============================================
    // View Functions
    // ============================================

    /// @inheritdoc IDelphAI
    function getMarket(uint256 marketId) external view marketExists(marketId) returns (MarketLib.Market memory) {
        return _markets[marketId];
    }

    /// @inheritdoc IDelphAI
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @inheritdoc IDelphAI
    function recoverERC20(address token, address to, uint256 amount) external onlyOwner {
        if (token == address(0)) revert Invalid_ZeroAddress();
        if (to == address(0)) revert Invalid_ZeroAddress();

        IERC20(token).safeTransfer(to, amount);

        emit TokensRecovered(token, to, amount);
    }

    // ============================================
    // Receive ETH
    // ============================================

    /// @notice Allow contract to receive ETH
    receive() external payable {}

    /// @notice Fallback function to receive ETH
    fallback() external payable {}
}
