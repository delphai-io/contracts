# 📁 DelphAI Project Structure

```
delphai-contracts/
├── .github/                          # GitHub workflows
├── lib/                              # Dependencies (forge-std, etc.)
├── script/                           # Deployment scripts
│   └── Deploy.s.sol                  # Main deployment script
├── src/                              # Smart contracts
│   ├── DelphAI.sol                   # Main contract implementation
│   ├── errors/                       # Custom error definitions
│   │   └── DelphAIErrors.sol        # Gas-optimized custom errors
│   ├── interfaces/                   # Contract interfaces
│   │   ├── IDelphAI.sol             # Main contract interface
│   │   └── IDelphAIEvents.sol       # Events interface
│   └── libraries/                    # Shared libraries
│       └── MarketLib.sol            # Market structs, enums, helpers
├── test/                             # Test files
│   └── DelphAI.t.sol                # Comprehensive test suite (29 tests)
├── .env.example                      # Environment variables template
├── .gitignore                        # Git ignore file
├── foundry.toml                      # Foundry configuration
├── Makefile                          # Build automation
├── README.md                         # Project documentation
└── STRUCTURE.md                      # This file
```

## 📝 File Descriptions

### Core Contracts

#### `src/DelphAI.sol`
Main contract implementing the prediction market oracle. Features:
- Market creation (permissionless)
- Market resolution (AI resolver only)
- Market cancellation
- Fee management
- Access control

#### `src/errors/DelphAIErrors.sol`
Custom error definitions for gas optimization:
- Access control errors
- Market validation errors
- Fee errors
- Input validation errors

#### `src/interfaces/IDelphAI.sol`
Main contract interface defining all public functions and view methods.

#### `src/interfaces/IDelphAIEvents.sol`
Event definitions for offchain indexing and monitoring.

#### `src/libraries/MarketLib.sol`
Library containing:
- Market struct definition
- MarketStatus and MarketOutcome enums
- Helper functions (exists, isOpen, canResolve, etc.)

### Testing

#### `test/DelphAI.t.sol`
Comprehensive test suite with 29 tests covering:
- Constructor validation
- Market creation (with edge cases)
- Market resolution (with authorization and timing checks)
- Market cancellation
- Admin functions
- Fuzz testing
- Full lifecycle integration tests

### Scripts

#### `script/Deploy.s.sol`
Two deployment scripts:
1. **DeployDelphAI**: Production deployment with env vars
2. **DeployDelphAILocal**: Local Anvil deployment with test values

### Configuration

#### `foundry.toml`
Foundry configuration with:
- Solidity 0.8.20
- Optimizer enabled (200 runs)
- Multiple profiles (default, ci, lite)
- Gas reporting
- Fuzz testing configuration

#### `Makefile`
Build automation with targets for:
- Building, testing, formatting
- Gas reporting and coverage
- Deployment to multiple chains
- Local development with Anvil

## 🔍 Architecture Patterns

### Separation of Concerns
- Business logic in main contract
- Data structures in libraries
- Errors in separate interface
- Events in separate interface

### Gas Optimization
- Custom errors (saves ~50 gas per revert)
- Library usage for helper functions
- Efficient storage layout
- Minimal external calls

### Security Best Practices
- Custom errors with parameters
- Comprehensive input validation
- Access control modifiers
- ReentrancyGuard pattern (where needed)
- Zero address checks

### Testing Strategy
- Unit tests for each function
- Edge case testing
- Access control tests
- Fuzz testing for inputs
- Integration tests for workflows

## 🚀 Development Workflow

1. **Install dependencies**: `make install`
2. **Build contracts**: `make build`
3. **Run tests**: `make test`
4. **Check gas usage**: `make test-gas`
5. **Format code**: `make format`
6. **Deploy locally**: `make deploy-local`
7. **Deploy to testnet**: `make deploy-sepolia`

## 📊 Contract Metrics

- **Solidity Version**: 0.8.20
- **Test Coverage**: 29 tests, 100% pass rate
- **Custom Errors**: 11 gas-optimized errors
- **Events**: 7 comprehensive events
- **Functions**: 15 public/external functions
- **Modifiers**: 3 access control modifiers
