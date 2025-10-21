# 🔮 DelphAI

**Permissionless AI-powered prediction market oracle**

DelphAI is a decentralized oracle system that allows anyone to create prediction markets onchain, which are then resolved by AI agents running offchain. The protocol is permissionless for market creation and uses configurable fees in native BNB.

## 🎯 Features

- **Permissionless Market Creation**: Anyone can create prediction markets by paying a fee
- **AI-Powered Resolution**: Offchain AI agents resolve markets with verifiable data (free resolution)
- **Dynamic Outcomes**: Flexible outcome options (not limited to Yes/No)
- **TEE Support**: Future-ready for Trusted Execution Environment attestation
- **Configurable Fees**: Owner-controlled market creation fee
- **Role-Based Access**: Separate roles for owner and AI resolver (OpenZeppelin Ownable)
- **Full Market Lifecycle**: Create, resolve, or cancel markets
- **Gas Optimized**: Custom errors and efficient data structures
- **GraphQL Friendly**: Comprehensive events for offchain indexing

## 📁 Project Structure

```
delphai-contracts/
├── src/
│   ├── DelphAI.sol                 # Main contract
│   ├── interfaces/
│   │   ├── IDelphAI.sol            # Main interface
│   │   └── IDelphAIEvents.sol      # Events interface
│   ├── libraries/
│   │   └── MarketLib.sol           # Market structs and helpers
│   └── errors/
│       └── DelphAIErrors.sol       # Custom errors
├── test/
│   └── DelphAI.t.sol               # Comprehensive test suite
├── script/
│   └── Deploy.s.sol                # Deployment scripts
└── foundry.toml                    # Foundry configuration
```

## 🏗️ Architecture

### Core Components

#### Market Structure
```solidity
struct Market {
    uint256 id;
    address creator;
    string question;
    string description;
    string[] possibleOutcomes;      // Dynamic outcome options
    uint256 createdAt;
    uint256 resolutionTimestamp;
    MarketStatus status;
    uint256 outcomeIndex;           // Index in possibleOutcomes array
    string resolutionData;
    bytes proofData;                // TEE attestation
    uint256 resolvedAt;
    address resolvedBy;
}
```

#### Market States
- **Open**: Market is active and awaiting resolution
- **Resolved**: AI has resolved the market
- **Cancelled**: Market was cancelled before resolution

#### Dynamic Outcomes
Markets support flexible outcomes defined at creation time:
- **Yes/No Markets**: `["Yes", "No"]`
- **Multiple Choice**: `["Team A", "Team B", "Team C", "Draw"]`
- **Custom Options**: Any array of 2+ string outcomes
- **Resolution**: Uses `outcomeIndex` to select from `possibleOutcomes[]`

### Roles

- **Owner**: Can configure fees, change resolver, withdraw fees
- **Resolver**: AI agent that resolves markets after resolution timestamp
- **Creators**: Anyone can create markets (permissionless)

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

```bash
# Clone repository
git clone https://github.com/yourusername/delphai-contracts
cd delphai-contracts

# Install dependencies
forge install

# Build
forge build

# Run tests
forge test

# Run tests with gas reporting
forge test --gas-report

# Run tests with verbosity
forge test -vvv
```

### Testing

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test test_CreateMarket

# Run tests with coverage
forge coverage

# Run fuzz tests
forge test --fuzz-runs 10000
```

## 📝 Usage

### Deploy

```bash
# Local deployment (Anvil)
forge script script/Deploy.s.sol:DeployDelphAILocal --fork-url http://localhost:8545 --broadcast

# BSC Testnet deployment
forge script script/Deploy.s.sol:DeployDelphAI \
  --rpc-url $BSC_TESTNET_RPC_URL \
  --broadcast \
  --verify \
  --etherscan-api-key $BSCSCAN_API_KEY

# BSC Mainnet deployment
forge script script/Deploy.s.sol:DeployDelphAI \
  --rpc-url $BSC_RPC_URL \
  --broadcast \
  --verify \
  --etherscan-api-key $BSCSCAN_API_KEY
```

### Environment Variables

Create a `.env` file:

```bash
PRIVATE_KEY=your_private_key
OWNER_ADDRESS=0x... # Contract owner (optional, defaults to deployer)
RESOLVER_ADDRESS=0x... # AI resolver address (optional, defaults to deployer)
CREATION_FEE=1000000000000000 # 0.001 BNB in wei (optional, defaults to 0.001)

# RPC URLs
BSC_RPC_URL=https://bsc-dataseed.binance.org/
BSC_TESTNET_RPC_URL=https://data-seed-prebsc-1-s1.binance.org:8545/

# Block Explorer
BSCSCAN_API_KEY=your_bscscan_api_key
```

### Creating a Market

```solidity
// Define possible outcomes
string[] memory outcomes = new string[](2);
outcomes[0] = "Yes";
outcomes[1] = "No";

// Pay the creation fee and create a market
uint256 marketId = delphAI.createMarket{value: creationFee}(
    "Will BNB reach $1000 by EOY 2025?",
    "Market resolves YES if BNB >= $1000 on any exchange by Dec 31, 2025",
    outcomes,
    1767225600 // Dec 31, 2025 timestamp
);
```

### Resolving a Market (AI Resolver Only)

```solidity
// AI resolver resolves the market after resolution timestamp (FREE - no fee)
delphAI.resolveMarket(
    marketId,
    0, // outcomeIndex (0 = "Yes" in this example)
    "BNB reached $1,042 on Binance at Dec 30, 2025 14:32 UTC",
    "" // proofData (empty for now, future TEE attestation)
);
```

### Cancelling a Market

```solidity
// Creator or owner can cancel
delphAI.cancelMarket(marketId);
```

## 🔐 Security

### Custom Errors

Gas-efficient custom errors instead of require strings:

```solidity
error Unauthorized_NotResolver();
error Fee_InsufficientCreationFee(uint256 provided, uint256 required);
error Market_TooEarlyToResolve(uint256 marketId, uint256 currentTime, uint256 resolutionTime);
error Market_InvalidOutcomeIndex(uint256 index, uint256 maxIndex);
```

### Access Control

- **Owner-only functions**: fee configuration, resolver management, withdrawals (OpenZeppelin Ownable)
- **Resolver-only functions**: market resolution (free, no fee)
- **Creator/owner functions**: market cancellation

### Validation

- Fee validation on market creation (minimum 2 outcomes required)
- Timestamp validation (resolution must be in future)
- Market state validation before operations
- Outcome index bounds checking
- Zero address checks

## 📊 Gas Optimization

- Custom errors instead of require strings
- Efficient storage layout
- Library usage for helper functions
- Minimal external calls

## 🧪 Test Coverage

Comprehensive test suite including:

- ✅ Constructor tests
- ✅ Market creation tests
- ✅ Market resolution tests
- ✅ Market cancellation tests
- ✅ Admin function tests
- ✅ Access control tests
- ✅ Fee validation tests
- ✅ Fuzz tests
- ✅ Integration tests
- ✅ Full lifecycle tests

Run coverage:
```bash
forge coverage
```

## 📄 License

BUSL-1.1 (Business Source License 1.1)

## 🤝 Contributing

Contributions are welcome! Please open an issue or PR.

## 📞 Contact

- Twitter: [@delphai_io](https://twitter.com/delphai_io)
- Website: [delphai.io](https://delphai.io)

---

Built with ❤️ by the DelphAI team
