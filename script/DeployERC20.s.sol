// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BaseScript } from "./BaseScript.sol";
import { Erc20 } from "../src/token/Erc20.sol";
import { ERC1967Proxy } from "../src/proxy/ERC1967Proxy.sol";
import { console2 } from "forge-std/console2.sol";

/**
 * @title DeployERC20
 * @notice Script to deploy upgradeable ERC20 token with proxy
 * @dev Usage: forge script script/DeployERC20.s.sol:DeployERC20 --rpc-url <network> --broadcast --verify
 */
contract DeployERC20 is BaseScript {
    function run() external {
        // Load configuration from environment
        string memory tokenName = vm.envOr("TOKEN_NAME", string("MyToken"));
        string memory tokenSymbol = vm.envOr("TOKEN_SYMBOL", string("MTK"));
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(1_000_000 * 10 ** 18));

        address receiptAddress = vm.envOr("RECEIPT_ADDRESS", getDeployerAddress());
        address defaultAdmin = vm.envOr("DEFAULT_ADMIN_ADDRESS", getDeployerAddress());
        address pauser = vm.envOr("PAUSER_ADDRESS", getDeployerAddress());
        address minter = vm.envOr("MINTER_ADDRESS", getDeployerAddress());
        address upgrader = vm.envOr("UPGRADER_ADDRESS", getDeployerAddress());

        // Validate addresses
        validateAddress(receiptAddress, "Receipt");
        validateAddress(defaultAdmin, "Default Admin");
        validateAddress(pauser, "Pauser");
        validateAddress(minter, "Minter");
        validateAddress(upgrader, "Upgrader");

        console2.log("====================================");
        console2.log("Deployment Configuration");
        console2.log("====================================");
        console2.log("Token Name:", tokenName);
        console2.log("Token Symbol:", tokenSymbol);
        console2.log("Initial Supply:", initialSupply);
        console2.log("Receipt Address:", receiptAddress);
        console2.log("Default Admin:", defaultAdmin);
        console2.log("Pauser:", pauser);
        console2.log("Minter:", minter);
        console2.log("Upgrader:", upgrader);
        console2.log("====================================");

        // Deploy implementation and proxy
        (address implementation, address proxy) =
            deployToken(tokenName, tokenSymbol, receiptAddress, initialSupply, defaultAdmin, pauser, minter, upgrader);

        // Log deployments
        logDeployment("ERC20 Implementation", implementation);
        logDeployment("ERC20 Proxy", proxy);

        console2.log("\n====================================");
        console2.log("Deployment Summary");
        console2.log("====================================");
        console2.log("Use the PROXY address for interactions:", proxy);
        console2.log("Implementation address (for reference):", implementation);
        console2.log("====================================\n");
    }

    function deployToken(
        string memory tokenName,
        string memory tokenSymbol,
        address receiptAddress,
        uint256 initialSupply,
        address defaultAdmin,
        address pauser,
        address minter,
        address upgrader
    )
        public
        broadcast
        returns (address implementation, address proxy)
    {
        // Deploy implementation contract
        implementation = address(new Erc20());
        console2.log("Implementation deployed at:", implementation);

        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            Erc20.initialize.selector,
            tokenName,
            tokenSymbol,
            receiptAddress,
            initialSupply,
            defaultAdmin,
            pauser,
            minter,
            upgrader
        );

        // Deploy proxy contract
        proxy = address(new ERC1967Proxy(implementation, initData));
        console2.log("Proxy deployed at:", proxy);

        return (implementation, proxy);
    }
}
