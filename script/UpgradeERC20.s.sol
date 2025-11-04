// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { BaseScript } from "./BaseScript.sol";
import { Erc20 } from "../src/token/Erc20.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import { console2 } from "forge-std/console2.sol";

/**
 * @title UpgradeERC20
 * @notice Script to upgrade ERC20 implementation
 * @dev Usage: PROXY_ADDRESS=0x... forge script script/UpgradeERC20.s.sol:UpgradeERC20 --rpc-url <network> --broadcast
 */
contract UpgradeERC20 is BaseScript {
    function run() external {
        address proxyAddress = vm.envAddress("PROXY_ADDRESS");
        validateAddress(proxyAddress, "Proxy");

        console2.log("====================================");
        console2.log("Upgrading ERC20 Proxy");
        console2.log("====================================");
        console2.log("Proxy Address:", proxyAddress);

        address newImplementation = upgradeToken(proxyAddress);

        logDeployment("New ERC20 Implementation", newImplementation);

        console2.log("\n====================================");
        console2.log("Upgrade Complete");
        console2.log("====================================");
        console2.log("Proxy continues at:", proxyAddress);
        console2.log("New implementation:", newImplementation);
        console2.log("====================================\n");
    }

    function upgradeToken(address proxyAddress) public broadcast returns (address newImplementation) {
        // Deploy new implementation
        newImplementation = address(new Erc20());
        console2.log("New implementation deployed at:", newImplementation);

        // Upgrade proxy to new implementation
        Erc20(proxyAddress).upgradeToAndCall(newImplementation, "");
        console2.log("Proxy upgraded successfully");

        return newImplementation;
    }
}
