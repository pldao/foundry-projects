.PHONY: help install build test clean format format-check deploy-sepolia deploy-mainnet verify upgrade snapshot coverage

# Colors for output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# Default target
help: ## Show this help message
	@echo '${GREEN}Usage:${RESET}'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo '${GREEN}Targets:${RESET}'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  ${YELLOW}%-20s${RESET} %s\n", $$1, $$2}'

install: ## Install dependencies
	@echo "${GREEN}Installing dependencies...${RESET}"
	forge install
	@echo "${GREEN}Dependencies installed successfully!${RESET}"

build: ## Build the project
	@echo "${GREEN}Building contracts...${RESET}"
	forge build
	@echo "${GREEN}Build completed!${RESET}"

test: ## Run tests
	@echo "${GREEN}Running tests...${RESET}"
	forge test -vvv
	@echo "${GREEN}Tests completed!${RESET}"

test-gas: ## Run tests with gas report
	@echo "${GREEN}Running tests with gas report...${RESET}"
	forge test --gas-report
	@echo "${GREEN}Gas report generated!${RESET}"

clean: ## Clean build artifacts
	@echo "${GREEN}Cleaning build artifacts...${RESET}"
	forge clean
	rm -rf cache out
	@echo "${GREEN}Clean completed!${RESET}"

format: ## Format all Solidity files (一键格式化)
	@echo "${GREEN}Formatting Solidity files...${RESET}"
	forge fmt
	@echo "${GREEN}Formatting completed!${RESET}"

format-check: ## Check if files are formatted correctly
	@echo "${GREEN}Checking Solidity formatting...${RESET}"
	forge fmt --check
	@echo "${GREEN}Format check completed!${RESET}"

snapshot: ## Create gas snapshot
	@echo "${GREEN}Creating gas snapshot...${RESET}"
	forge snapshot
	@echo "${GREEN}Snapshot saved to .gas-snapshot${RESET}"

coverage: ## Generate test coverage report
	@echo "${GREEN}Generating coverage report...${RESET}"
	forge coverage
	@echo "${GREEN}Coverage report generated!${RESET}"

coverage-report: ## Generate detailed coverage report (HTML)
	@echo "${GREEN}Generating detailed coverage report...${RESET}"
	forge coverage --report lcov
	@echo "${GREEN}Coverage report saved!${RESET}"

# Deployment targets
deploy-localhost: ## Deploy to local network
	@echo "${GREEN}Deploying to localhost...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url localhost --broadcast
	@echo "${GREEN}Deployment to localhost completed!${RESET}"

deploy-sepolia: ## Deploy to Sepolia testnet
	@echo "${GREEN}Deploying to Sepolia...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url sepolia --broadcast --verify
	@echo "${GREEN}Deployment to Sepolia completed!${RESET}"

deploy-mainnet: ## Deploy to Ethereum mainnet
	@echo "${YELLOW}⚠️  WARNING: Deploying to MAINNET${RESET}"
	@read -p "Are you sure you want to deploy to mainnet? [y/N] " confirm && [ "$$confirm" = "y" ]
	@echo "${GREEN}Deploying to Mainnet...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url mainnet --broadcast --verify
	@echo "${GREEN}Deployment to Mainnet completed!${RESET}"

deploy-bsc: ## Deploy to BSC mainnet
	@echo "${GREEN}Deploying to BSC...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url bsc --broadcast --verify
	@echo "${GREEN}Deployment to BSC completed!${RESET}"

deploy-bsc-testnet: ## Deploy to BSC testnet
	@echo "${GREEN}Deploying to BSC Testnet...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url bsc_testnet --broadcast --verify
	@echo "${GREEN}Deployment to BSC Testnet completed!${RESET}"

deploy-polygon: ## Deploy to Polygon mainnet
	@echo "${GREEN}Deploying to Polygon...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url polygon --broadcast --verify
	@echo "${GREEN}Deployment to Polygon completed!${RESET}"

deploy-polygon-amoy: ## Deploy to Polygon Amoy testnet
	@echo "${GREEN}Deploying to Polygon Amoy...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url polygon_amoy --broadcast --verify
	@echo "${GREEN}Deployment to Polygon Amoy completed!${RESET}"

deploy-arbitrum: ## Deploy to Arbitrum mainnet
	@echo "${GREEN}Deploying to Arbitrum...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url arbitrum --broadcast --verify
	@echo "${GREEN}Deployment to Arbitrum completed!${RESET}"

deploy-optimism: ## Deploy to Optimism mainnet
	@echo "${GREEN}Deploying to Optimism...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url optimism --broadcast --verify
	@echo "${GREEN}Deployment to Optimism completed!${RESET}"

deploy-base: ## Deploy to Base mainnet
	@echo "${GREEN}Deploying to Base...${RESET}"
	forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url base --broadcast --verify
	@echo "${GREEN}Deployment to Base completed!${RESET}"

# Upgrade targets
upgrade-sepolia: ## Upgrade contract on Sepolia
	@echo "${GREEN}Upgrading on Sepolia...${RESET}"
	@test -n "$(PROXY_ADDRESS)" || (echo "${YELLOW}Error: PROXY_ADDRESS not set${RESET}" && exit 1)
	forge script script/UpgradeERC20.s.sol:UpgradeERC20 --rpc-url sepolia --broadcast
	@echo "${GREEN}Upgrade on Sepolia completed!${RESET}"

upgrade-mainnet: ## Upgrade contract on mainnet
	@echo "${YELLOW}⚠️  WARNING: Upgrading on MAINNET${RESET}"
	@test -n "$(PROXY_ADDRESS)" || (echo "${YELLOW}Error: PROXY_ADDRESS not set${RESET}" && exit 1)
	@read -p "Are you sure you want to upgrade on mainnet? [y/N] " confirm && [ "$$confirm" = "y" ]
	@echo "${GREEN}Upgrading on Mainnet...${RESET}"
	forge script script/UpgradeERC20.s.sol:UpgradeERC20 --rpc-url mainnet --broadcast
	@echo "${GREEN}Upgrade on Mainnet completed!${RESET}"

# Verification
verify-sepolia: ## Verify contract on Sepolia
	@test -n "$(CONTRACT_ADDRESS)" || (echo "${YELLOW}Error: CONTRACT_ADDRESS not set${RESET}" && exit 1)
	@echo "${GREEN}Verifying contract on Sepolia...${RESET}"
	forge verify-contract $(CONTRACT_ADDRESS) src/token/Erc20.sol:Erc20 --chain sepolia
	@echo "${GREEN}Verification completed!${RESET}"

verify-mainnet: ## Verify contract on mainnet
	@test -n "$(CONTRACT_ADDRESS)" || (echo "${YELLOW}Error: CONTRACT_ADDRESS not set${RESET}" && exit 1)
	@echo "${GREEN}Verifying contract on Mainnet...${RESET}"
	forge verify-contract $(CONTRACT_ADDRESS) src/token/Erc20.sol:Erc20 --chain mainnet
	@echo "${GREEN}Verification completed!${RESET}"

# Development tools
anvil: ## Start local Anvil node
	@echo "${GREEN}Starting Anvil local node...${RESET}"
	anvil

flatten: ## Flatten contracts for verification
	@echo "${GREEN}Flattening contracts...${RESET}"
	forge flatten src/token/Erc20.sol > flattened/Erc20_flat.sol
	forge flatten src/proxy/ERC1967Proxy.sol > flattened/ERC1967Proxy_flat.sol
	@echo "${GREEN}Contracts flattened!${RESET}"

size: ## Check contract sizes
	@echo "${GREEN}Checking contract sizes...${RESET}"
	forge build --sizes
	@echo "${GREEN}Size check completed!${RESET}"

# Setup
setup: ## Initial project setup (copy .env and install dependencies)
	@echo "${GREEN}Setting up project...${RESET}"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "${YELLOW}Created .env file from .env.example${RESET}"; \
		echo "${YELLOW}⚠️  Please update .env with your actual values${RESET}"; \
	else \
		echo "${YELLOW}.env file already exists${RESET}"; \
	fi
	@$(MAKE) install
	@echo "${GREEN}Setup completed!${RESET}"

# Check environment
check-env: ## Check if .env file exists and is configured
	@echo "${GREEN}Checking environment configuration...${RESET}"
	@if [ ! -f .env ]; then \
		echo "${YELLOW}⚠️  .env file not found!${RESET}"; \
		echo "Run 'make setup' to create it from .env.example"; \
		exit 1; \
	fi
	@echo "${GREEN}Environment file exists${RESET}"
