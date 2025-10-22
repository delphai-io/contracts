// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {DelphAI} from "../src/DelphAI.sol";
import {MarketLib} from "../src/libraries/MarketLib.sol";
import {DelphAIErrors} from "../src/errors/DelphAIErrors.sol";

contract DelphAITest is Test, DelphAIErrors {
    DelphAI public delphAI;

    address public owner;
    address public resolver;
    address public user1;
    address public user2;

    uint256 constant CREATION_FEE = 0.001 ether;

    event MarketCreated(
        uint256 indexed marketId,
        address indexed creator,
        string question,
        string description,
        string[] possibleOutcomes,
        uint256 createdAt,
        uint256 resolutionTimestamp
    );

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

    event MarketCancelled(
        uint256 indexed marketId,
        address indexed cancelledBy,
        uint256 cancelledAt
    );

    // Helper to create simple Yes/No market
    function createYesNoMarket(string memory question, string memory description) internal returns (uint256) {
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";
        return delphAI.createMarket{value: CREATION_FEE}(
            question,
            description,
            outcomes,
            block.timestamp + 1 days
        );
    }

    function setUp() public {
        owner = address(this);
        resolver = makeAddr("resolver");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(resolver, 10 ether);

        delphAI = new DelphAI(owner, resolver, CREATION_FEE);
    }

    // ============================================
    // Constructor Tests
    // ============================================

    function test_Constructor() public {
        assertEq(delphAI.owner(), owner);
        assertEq(delphAI.resolver(), resolver);
        assertEq(delphAI.marketCreationFee(), CREATION_FEE);
        assertEq(delphAI.marketCounter(), 0);
    }

    function test_Constructor_RevertsOnZeroResolver() public {
        vm.expectRevert(Invalid_ZeroAddress.selector);
        new DelphAI(owner, address(0), CREATION_FEE);
    }

    // ============================================
    // Market Creation Tests
    // ============================================

    function test_CreateMarket() public {
        vm.startPrank(user1);

        string memory question = "Will ETH reach $5000?";
        string memory description = "YES if >= $5000";
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = delphAI.createMarket{value: CREATION_FEE}(
            question,
            description,
            outcomes,
            block.timestamp + 1 days
        );

        assertEq(marketId, 1);
        MarketLib.Market memory market = delphAI.getMarket(marketId);
        assertEq(market.possibleOutcomes.length, 2);
        assertEq(market.possibleOutcomes[0], "Yes");
        assertEq(market.outcomeIndex, MarketLib.OUTCOME_NOT_RESOLVED);

        vm.stopPrank();
    }

    function test_CreateMarket_RevertsOnInsufficientFee() public {
        vm.startPrank(user1);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        vm.expectRevert(
            abi.encodeWithSelector(
                Fee_InsufficientCreationFee.selector,
                CREATION_FEE - 1,
                CREATION_FEE
            )
        );

        delphAI.createMarket{value: CREATION_FEE - 1}(
            "Question?",
            "Description",
            outcomes,
            block.timestamp + 1 days
        );

        vm.stopPrank();
    }

    function test_CreateMarket_RevertsOnEmptyQuestion() public {
        vm.startPrank(user1);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        vm.expectRevert(Market_QuestionRequired.selector);

        delphAI.createMarket{value: CREATION_FEE}(
            "",
            "Description",
            outcomes,
            block.timestamp + 1 days
        );

        vm.stopPrank();
    }

    function test_CreateMarket_RevertsOnInsufficientOutcomes() public {
        vm.startPrank(user1);

        string[] memory outcomes = new string[](1);
        outcomes[0] = "Only One";

        vm.expectRevert(Market_InsufficientOutcomes.selector);

        delphAI.createMarket{value: CREATION_FEE}(
            "Question?",
            "Description",
            outcomes,
            block.timestamp + 1 days
        );

        vm.stopPrank();
    }

    // ============================================
    // Market Resolution Tests
    // ============================================

    function test_ResolveMarket() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Will it rain?", "YES if rain");

        vm.warp(block.timestamp + 1 days);

        vm.prank(resolver);
        string[] memory sources = new string[](1);
        sources[0] = "https://weather.com/data";
        delphAI.resolveMarket(marketId, 0, "AI verified: It rained", sources, 95, "");

        MarketLib.Market memory market = delphAI.getMarket(marketId);
        assertTrue(market.status == MarketLib.MarketStatus.Resolved);
        assertEq(market.outcomeIndex, 0);
    }

    function test_ResolveMarket_RevertsOnUnauthorized() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Question?", "Desc");

        vm.warp(block.timestamp + 1 days);

        vm.startPrank(user2);
        vm.expectRevert(Unauthorized_NotResolver.selector);

        string[] memory sources = new string[](0);
        delphAI.resolveMarket(marketId, 0, "Data", sources, 50, "");

        vm.stopPrank();
    }

    function test_ResolveMarket_RevertsOnTooEarly() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Question?", "Desc");

        vm.startPrank(resolver);
        vm.expectRevert(
            abi.encodeWithSelector(
                Market_TooEarlyToResolve.selector,
                marketId,
                block.timestamp,
                block.timestamp + 1 days
            )
        );

        string[] memory sources = new string[](0);
        delphAI.resolveMarket(marketId, 0, "Data", sources, 50, "");

        vm.stopPrank();
    }

    function test_ResolveMarket_RevertsOnInvalidIndex() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Question?", "Desc");

        vm.warp(block.timestamp + 1 days);

        vm.startPrank(resolver);
        vm.expectRevert(
            abi.encodeWithSelector(Market_InvalidOutcomeIndex.selector, 5, 2)
        );

        string[] memory sources = new string[](0);
        delphAI.resolveMarket(marketId, 5, "Data", sources, 50, "");

        vm.stopPrank();
    }

    // ============================================
    // Market Cancellation Tests
    // ============================================

    function test_CancelMarket_ByCreator() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Question?", "Desc");

        vm.prank(user1);
        delphAI.cancelMarket(marketId);

        MarketLib.Market memory market = delphAI.getMarket(marketId);
        assertTrue(market.status == MarketLib.MarketStatus.Cancelled);
    }

    function test_CancelMarket_ByOwner() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Question?", "Desc");

        delphAI.cancelMarket(marketId);

        MarketLib.Market memory market = delphAI.getMarket(marketId);
        assertTrue(market.status == MarketLib.MarketStatus.Cancelled);
    }

    function test_CancelMarket_RevertsOnUnauthorized() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Question?", "Desc");

        vm.startPrank(user2);
        vm.expectRevert(Unauthorized_NotCreatorOrOwner.selector);

        delphAI.cancelMarket(marketId);

        vm.stopPrank();
    }

    // ============================================
    // Admin Function Tests
    // ============================================

    function test_SetMarketCreationFee() public {
        uint256 newFee = 0.002 ether;
        delphAI.setMarketCreationFee(newFee);
        assertEq(delphAI.marketCreationFee(), newFee);
    }

    function test_SetMarketCreationFee_RevertsOnUnauthorized() public {
        vm.startPrank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        delphAI.setMarketCreationFee(0.002 ether);
        vm.stopPrank();
    }

    function test_TransferOwnership() public {
        address newOwner = makeAddr("newOwner");
        delphAI.transferOwnership(newOwner);
        assertEq(delphAI.owner(), newOwner);
    }

    function test_SetResolver() public {
        address newResolver = makeAddr("newResolver");
        delphAI.setResolver(newResolver);
        assertEq(delphAI.resolver(), newResolver);
    }

    function test_SetResolver_RevertsOnZeroAddress() public {
        vm.expectRevert(Invalid_ZeroAddress.selector);
        delphAI.setResolver(address(0));
    }

    function test_WithdrawFees() public {
        vm.prank(user1);
        createYesNoMarket("Test?", "Desc");

        uint256 balance = delphAI.getContractBalance();
        assertEq(balance, CREATION_FEE);

        address payable recipient = payable(makeAddr("recipient"));
        delphAI.withdrawFees(recipient, balance);

        assertEq(recipient.balance, CREATION_FEE);
        assertEq(delphAI.getContractBalance(), 0);
    }

    function test_WithdrawFees_RevertsOnInsufficientBalance() public {
        address payable recipient = payable(makeAddr("recipient"));

        vm.expectRevert(
            abi.encodeWithSelector(Fee_InsufficientBalance.selector, 1 ether, 0)
        );

        delphAI.withdrawFees(recipient, 1 ether);
    }

    // ============================================
    // Full Lifecycle Test
    // ============================================

    function test_FullMarketLifecycle() public {
        vm.prank(user1);
        uint256 marketId = createYesNoMarket("Will BTC reach $100k?", "YES if >= $100k");

        vm.warp(block.timestamp + 1 days);

        vm.prank(resolver);
        string[] memory sources = new string[](2);
        sources[0] = "https://coinmarketcap.com";
        sources[1] = "https://coingecko.com";
        delphAI.resolveMarket(marketId, 0, "BTC reached $105k", sources, 99, "");

        MarketLib.Market memory market = delphAI.getMarket(marketId);
        assertTrue(market.status == MarketLib.MarketStatus.Resolved);
        assertEq(market.outcomeIndex, 0);
        assertEq(market.possibleOutcomes[0], "Yes");

        uint256 totalFees = CREATION_FEE;
        assertEq(delphAI.getContractBalance(), totalFees);

        address payable recipient = payable(makeAddr("recipient"));
        delphAI.withdrawFees(recipient, totalFees);
        assertEq(recipient.balance, totalFees);
    }
}
