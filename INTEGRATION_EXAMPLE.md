# DelphAI Integration Example

Quick integration guide for prediction market platforms.

## 📦 Installation

```bash
npm install @openzeppelin/contracts
```

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IDelphAI.sol";

contract PredictionMarket {
    IDelphAI public immutable delphAI;

    // Market ID mapping to your internal market data
    mapping(uint256 => uint256) public delphAIMarketIds;

    constructor(address _delphAI) {
        delphAI = IDelphAI(_delphAI);
    }

    /// @notice Create a new prediction market with AI resolution
    function createMarket(
        string memory question,
        string memory description,
        string[] memory outcomes,
        uint256 resolutionTimestamp
    ) external payable returns (uint256 marketId) {
        // Get the creation fee from DelphAI
        uint256 creationFee = delphAI.marketCreationFee();
        require(msg.value >= creationFee, "Insufficient fee");

        // Create market on DelphAI
        marketId = delphAI.createMarket{value: creationFee}(
            question,
            description,
            outcomes,
            resolutionTimestamp
        );

        // Store the market ID for later use
        delphAIMarketIds[marketId] = marketId;

        // Your custom market logic here...
        // e.g., create betting pools, set odds, etc.

        return marketId;
    }

    /// @notice Listen for market resolution and trigger payouts
    function onMarketResolved(uint256 marketId) external {
        // Get the resolved market data
        MarketLib.Market memory market = delphAI.getMarket(marketId);

        require(market.status == MarketLib.MarketStatus.Resolved, "Not resolved");

        // Get the winning outcome
        string memory winningOutcome = market.possibleOutcomes[market.outcomeIndex];

        // Your payout logic here...
        // e.g., distribute winnings to correct bettors

        // Access AI resolution data and proof
        // market.resolutionData - AI explanation
        // market.proofData - TEE attestation (future)
    }
}
```

## 🎯 Simple Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IDelphAI {
    function createMarket(
        string memory question,
        string memory description,
        string[] memory possibleOutcomes,
        uint256 resolutionTimestamp
    ) external payable returns (uint256);

    function marketCreationFee() external view returns (uint256);
}

contract SimplePredictionMarket {
    IDelphAI public delphAI;

    constructor(address _delphAI) {
        delphAI = IDelphAI(_delphAI);
    }

    function createYesNoMarket(
        string memory question,
        uint256 resolutionTime
    ) external payable returns (uint256) {
        // Setup Yes/No outcomes
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        // Create market with AI resolution
        return delphAI.createMarket{value: msg.value}(
            question,
            "AI will resolve this market",
            outcomes,
            resolutionTime
        );
    }
}
```

## 🔥 Frontend Integration (ethers.js)

```javascript
import { ethers } from 'ethers';

// Contract addresses (update with your deployment)
const DELPHAI_ADDRESS = "0x...";
const DELPHAI_ABI = [...]; // Import from your artifacts

// Initialize
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();
const delphAI = new ethers.Contract(DELPHAI_ADDRESS, DELPHAI_ABI, signer);

// Create a market
async function createMarket() {
    const question = "Will BNB reach $1000 by end of 2025?";
    const description = "Resolves YES if BNB >= $1000 on any major exchange";
    const outcomes = ["Yes", "No"];
    const resolutionTime = Math.floor(new Date('2025-12-31').getTime() / 1000);

    // Get creation fee
    const creationFee = await delphAI.marketCreationFee();

    // Create market
    const tx = await delphAI.createMarket(
        question,
        description,
        outcomes,
        resolutionTime,
        { value: creationFee }
    );

    const receipt = await tx.wait();

    // Parse event to get market ID
    const event = receipt.events.find(e => e.event === 'MarketCreated');
    const marketId = event.args.marketId;

    console.log(`Market created with ID: ${marketId}`);
    return marketId;
}

// Listen for market resolution
delphAI.on('MarketResolved', (marketId, outcomeIndex, outcome, resolver, resolutionData, proofData, resolvedAt) => {
    console.log(`Market ${marketId} resolved to: ${outcome}`);
    console.log(`AI reasoning: ${resolutionData}`);

    // Trigger your payout logic here
});

// Get market details
async function getMarket(marketId) {
    const market = await delphAI.getMarket(marketId);

    return {
        id: market.id.toString(),
        question: market.question,
        description: market.description,
        outcomes: market.possibleOutcomes,
        status: market.status, // 0=Open, 1=Resolved, 2=Cancelled
        winningOutcome: market.status === 1 ? market.possibleOutcomes[market.outcomeIndex] : null,
        aiExplanation: market.resolutionData,
        createdAt: new Date(market.createdAt.toNumber() * 1000),
        resolvedAt: market.resolvedAt.toNumber() > 0 ? new Date(market.resolvedAt.toNumber() * 1000) : null
    };
}
```

## 🎨 React Hook Example

```typescript
import { useContract, useContractEvent, useContractRead } from 'wagmi';
import DelphAIABI from './DelphAI.json';

const DELPHAI_ADDRESS = '0x...';

export function useDelphAI() {
    const contract = useContract({
        address: DELPHAI_ADDRESS,
        abi: DelphAIABI,
    });

    // Get creation fee
    const { data: creationFee } = useContractRead({
        address: DELPHAI_ADDRESS,
        abi: DelphAIABI,
        functionName: 'marketCreationFee',
    });

    // Listen for new markets
    useContractEvent({
        address: DELPHAI_ADDRESS,
        abi: DelphAIABI,
        eventName: 'MarketCreated',
        listener: (marketId, creator, question, description, outcomes, createdAt, resolutionTimestamp) => {
            console.log('New market created:', { marketId, question });
        },
    });

    // Listen for resolutions
    useContractEvent({
        address: DELPHAI_ADDRESS,
        abi: DelphAIABI,
        eventName: 'MarketResolved',
        listener: (marketId, outcomeIndex, outcome, resolver, resolutionData) => {
            console.log('Market resolved:', { marketId, outcome });
            // Trigger UI update / payouts
        },
    });

    return { contract, creationFee };
}

// Usage in component
function CreateMarketButton() {
    const { contract, creationFee } = useDelphAI();

    const createMarket = async () => {
        const tx = await contract.createMarket(
            "Will BNB reach $1000?",
            "Resolves on Dec 31, 2025",
            ["Yes", "No"],
            Math.floor(Date.now() / 1000) + 86400 * 365,
            { value: creationFee }
        );
        await tx.wait();
    };

    return <button onClick={createMarket}>Create Market</button>;
}
```

## 📊 Key Benefits

- ✅ **Zero Resolution Costs**: AI resolves markets for free
- ✅ **Permissionless**: Anyone can create markets
- ✅ **Flexible Outcomes**: Not limited to Yes/No
- ✅ **AI Explanations**: Get detailed resolution reasoning
- ✅ **Future TEE Support**: Cryptographic proof of AI execution
- ✅ **GraphQL Ready**: All data emitted in events for easy indexing

## 🔗 Resources

- **Contract**: `0x...` (Update with your deployment)
- **Docs**: [https://delphai.io/docs](https://delphai.io/docs)
- **GitHub**: [https://github.com/delphai/contracts](https://github.com/delphai/contracts)

---

Built with ❤️ by DelphAI
