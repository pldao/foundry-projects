// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

/**
 * @title BaseScript
 * @notice Base script with helper functions for deployments
 */
abstract contract BaseScript is Script {
    // Deployment addresses will be logged here
    mapping(string => address) public deployedContracts;

    modifier broadcast() {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        _;
        vm.stopBroadcast();
    }

    function getDeployerAddress() internal view returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        return vm.addr(deployerPrivateKey);
    }

    function logDeployment(string memory name, address contractAddress) internal {
        deployedContracts[name] = contractAddress;
        console2.log("====================================");
        console2.log("Contract:", name);
        console2.log("Address:", contractAddress);
        console2.log("====================================");
    }

    function validateAddress(address addr, string memory name) internal pure {
        require(addr != address(0), string(abi.encodePacked(name, " address cannot be zero")));
    }
}
