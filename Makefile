# Include .env file if it exists
-include .env

.PHONY: all test clean install update build format snapshot gas anvil deploy verify

# Default target
all: clean install build test

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@forge clean

# Install dependencies
install:
	@echo "Installing dependencies..."
	@forge install

# Update dependencies
update:
	@echo "Updating dependencies..."
	@forge update

# Build contracts
build:
	@echo "Building contracts..."
	@forge build

# Format code
format:
	@echo "Formatting code..."
	@forge fmt

# Run tests
test:
	@echo "Running tests..."
	@forge test -vvv

# Run tests with gas report
test-gas:
	@echo "Running tests with gas report..."
	@forge test --gas-report

# Run tests with coverage
coverage:
	@echo "Running coverage..."
	@forge coverage

# Create gas snapshot
snapshot:
	@echo "Creating gas snapshot..."
	@forge snapshot

# Run local Anvil node
anvil:
	@echo "Starting Anvil..."
	@anvil

# Deploy to local Anvil
deploy-local:
	@echo "Deploying to local Anvil..."
	@forge script script/Deploy.s.sol:DeployDelphAILocal \
		--fork-url http://localhost:8545 \
		--broadcast

# Deploy to Sepolia testnet
deploy-sepolia:
	@echo "Deploying to Sepolia..."
	@forge script script/Deploy.s.sol:DeployDelphAI \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ETHERSCAN_API_KEY)

# Deploy to Arbitrum
deploy-arbitrum:
	@echo "Deploying to Arbitrum..."
	@forge script script/Deploy.s.sol:DeployDelphAI \
		--rpc-url $(ARBITRUM_RPC_URL) \
		--broadcast \
		--verify \
		--etherscan-api-key $(ARBISCAN_API_KEY)

# Deploy to Optimism
deploy-optimism:
	@echo "Deploying to Optimism..."
	@forge script script/Deploy.s.sol:DeployDelphAI \
		--rpc-url $(OPTIMISM_RPC_URL) \
		--broadcast \
		--verify \
		--etherscan-api-key $(OPTIMISTIC_ETHERSCAN_API_KEY)

# Deploy to Base
deploy-base:
	@echo "Deploying to Base..."
	@forge script script/Deploy.s.sol:DeployDelphAI \
		--rpc-url $(BASE_RPC_URL) \
		--broadcast \
		--verify \
		--etherscan-api-key $(BASESCAN_API_KEY)

# Run slither static analysis (if installed)
slither:
	@echo "Running Slither..."
	@slither .

# Help
help:
	@echo "Available targets:"
	@echo "  all              - Clean, install, build, and test"
	@echo "  clean            - Remove build artifacts"
	@echo "  install          - Install dependencies"
	@echo "  update           - Update dependencies"
	@echo "  build            - Build contracts"
	@echo "  format           - Format code"
	@echo "  test             - Run tests"
	@echo "  test-gas         - Run tests with gas report"
	@echo "  coverage         - Run coverage report"
	@echo "  snapshot         - Create gas snapshot"
	@echo "  anvil            - Run local Anvil node"
	@echo "  deploy-local     - Deploy to local Anvil"
	@echo "  deploy-sepolia   - Deploy to Sepolia testnet"
	@echo "  deploy-arbitrum  - Deploy to Arbitrum"
	@echo "  deploy-optimism  - Deploy to Optimism"
	@echo "  deploy-base      - Deploy to Base"
	@echo "  slither          - Run Slither static analysis"
