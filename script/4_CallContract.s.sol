// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

// ====================================
// 使用说明：
// 1. 在 .env 中配置 PRIVATE_KEY（调用者私钥）
// 2. 配置 CONTRACT_ADDRESS（目标合约地址）
// 3. 在配置区域设置要调用的函数和参数
// 4. 运行脚本调用合约方法
// ====================================

/**
 * @title 4_CallContract
 * @notice 调用任意合约的任意方法的脚本模版
 * @dev 使用方法:
 *      forge script script/4_CallContract.s.sol:CallContract --rpc-url <network> --broadcast
 *
 *      环境变量配置:
 *      - PRIVATE_KEY: 调用者私钥（写入操作必需）
 *      - CONTRACT_ADDRESS: 目标合约地址（必需）
 *      - VALUE_ETH: 发送的ETH数量（可选，用于payable函数）
 *
 *      示例:
 *      CONTRACT_ADDRESS=0x... forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia --broadcast
 */
contract CallContract is Script {
    // ========== 配置区域 - 在这里修改调用参数 ==========

    // TODO: 修改目标合约地址（或使用环境变量 CONTRACT_ADDRESS）
    address constant DEFAULT_CONTRACT_ADDRESS = address(0);

    // TODO: 修改发送的 ETH 数量（仅用于 payable 函数）
    uint256 constant DEFAULT_VALUE_ETH = 0;

    // ================================================

    function run() external {
        // 获取合约地址
        address contractAddress = getContractAddress();
        require(contractAddress != address(0), "Contract address cannot be zero");

        console2.log("====================================");
        console2.log("Calling Contract Method");
        console2.log("====================================");
        console2.log("Contract Address:", contractAddress);
        console2.log("Chain ID:", block.chainid);
        console2.log("====================================");

        // TODO: 选择要调用的函数
        // 取消注释以下任一方法，或添加自己的调用逻辑

        // 示例 1: 调用只读函数（view/pure）
        // callViewFunction(contractAddress);

        // 示例 2: 调用写入函数
        // callWriteFunction(contractAddress);

        // 示例 3: 调用带参数的函数
        // callFunctionWithParameters(contractAddress);

        // 示例 4: 调用 payable 函数
        // callPayableFunction(contractAddress);

        console2.log("\nPlease uncomment the function you want to call in run()");
    }

    // ========== 示例 1: 调用只读函数 ==========

    /**
     * @notice 调用只读函数示例
     * @dev 不需要发送交易，不消耗 Gas
     */
    function callViewFunction(address contractAddress) public view {
        console2.log("\n=== Calling View Function ===");

        // 示例 1: 调用无参数的 view 函数
        // 例如：totalSupply()
        (bool success, bytes memory returnData) = contractAddress.staticcall(abi.encodeWithSignature("totalSupply()"));

        if (success) {
            uint256 result = abi.decode(returnData, (uint256));
            console2.log("Total Supply:", result);
        } else {
            console2.log("Call failed");
        }

        // 示例 2: 调用带参数的 view 函数
        // 例如：balanceOf(address)
        address account = address(0x1234567890123456789012345678901234567890);
        (bool success2, bytes memory returnData2) =
            contractAddress.staticcall(abi.encodeWithSignature("balanceOf(address)", account));

        if (success2) {
            uint256 balance = abi.decode(returnData2, (uint256));
            console2.log("Balance of", account, ":", balance);
        }
    }

    // ========== 示例 2: 调用写入函数 ==========

    /**
     * @notice 调用写入函数示例
     * @dev 需要发送交易，消耗 Gas
     */
    function callWriteFunction(address contractAddress) public {
        console2.log("\n=== Calling Write Function ===");

        uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
        address caller = vm.addr(callerPrivateKey);

        console2.log("Caller:", caller);

        vm.startBroadcast(callerPrivateKey);

        // 示例 1: 调用简单的写入函数
        // 例如：pause()
        (bool success,) = contractAddress.call(abi.encodeWithSignature("pause()"));

        if (success) {
            console2.log("Pause function called successfully");
        } else {
            console2.log("Pause function call failed");
        }

        vm.stopBroadcast();

        console2.log("Transaction complete");
    }

    // ========== 示例 3: 调用带参数的函数 ==========

    /**
     * @notice 调用带参数的函数示例
     */
    function callFunctionWithParameters(address contractAddress) public {
        console2.log("\n=== Calling Function with Parameters ===");

        uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
        address caller = vm.addr(callerPrivateKey);

        console2.log("Caller:", caller);

        // 示例 1: 调用 transfer(address,uint256)
        address recipient = address(0x9876543210987654321098765432109876543210);
        uint256 amount = 100 * 10 ** 18;

        console2.log("Recipient:", recipient);
        console2.log("Amount:", amount);

        vm.startBroadcast(callerPrivateKey);

        (bool success,) = contractAddress.call(abi.encodeWithSignature("transfer(address,uint256)", recipient, amount));

        vm.stopBroadcast();

        if (success) {
            console2.log("Transfer successful");
        } else {
            console2.log("Transfer failed");
        }

        // 示例 2: 调用多参数函数
        // 例如：approve(address,uint256)
        vm.startBroadcast(callerPrivateKey);

        (bool success2,) = contractAddress.call(abi.encodeWithSignature("approve(address,uint256)", recipient, amount));

        vm.stopBroadcast();

        if (success2) {
            console2.log("Approval successful");
        }
    }

    // ========== 示例 4: 调用 Payable 函数 ==========

    /**
     * @notice 调用 payable 函数示例
     * @dev 可以在调用时发送 ETH
     */
    function callPayableFunction(address contractAddress) public {
        console2.log("\n=== Calling Payable Function ===");

        uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
        address caller = vm.addr(callerPrivateKey);

        // 获取要发送的 ETH 数量
        uint256 valueWei = getValueInWei();

        console2.log("Caller:", caller);
        console2.log("Value (ETH):", valueWei / 1e18);
        console2.log("Value (Wei):", valueWei);

        vm.startBroadcast(callerPrivateKey);

        // 示例：调用 deposit() 函数并发送 ETH
        (bool success,) = contractAddress.call{ value: valueWei }(abi.encodeWithSignature("deposit()"));

        vm.stopBroadcast();

        if (success) {
            console2.log("Deposit successful");
        } else {
            console2.log("Deposit failed");
        }
    }

    // ========== 示例 5: 调用复杂参数的函数 ==========

    /**
     * @notice 调用带复杂参数的函数示例
     * @dev 展示如何传递数组、结构体等复杂类型
     */
    function callFunctionWithComplexParameters(address contractAddress) public {
        console2.log("\n=== Calling Function with Complex Parameters ===");

        uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(callerPrivateKey);

        // 示例 1: 传递地址数组
        address[] memory addresses = new address[](3);
        addresses[0] = address(0x1111111111111111111111111111111111111111);
        addresses[1] = address(0x2222222222222222222222222222222222222222);
        addresses[2] = address(0x3333333333333333333333333333333333333333);

        // 示例 2: 传递 uint256 数组
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100 * 10 ** 18;
        amounts[1] = 200 * 10 ** 18;
        amounts[2] = 300 * 10 ** 18;

        // 调用函数：batchTransfer(address[],uint256[])
        (bool success,) =
            contractAddress.call(abi.encodeWithSignature("batchTransfer(address[],uint256[])", addresses, amounts));

        vm.stopBroadcast();

        if (success) {
            console2.log("Batch transfer successful");
        }
    }

    // ========== 示例 6: 使用接口调用（类型安全）==========

    /**
     * @notice 使用接口调用合约方法
     * @dev 提供类型安全和更好的代码可读性
     */
    function callUsingInterface(address contractAddress) public {
        // 如果你有合约的接口，可以这样调用
        // 例如：使用 IERC20 接口

        // import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
        // IERC20 token = IERC20(contractAddress);

        uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
        address caller = vm.addr(callerPrivateKey);

        console2.log("\n=== Calling Using Interface ===");
        console2.log("Caller:", caller);

        vm.startBroadcast(callerPrivateKey);

        // 类型安全的调用
        // token.transfer(recipient, amount);

        vm.stopBroadcast();
    }

    // ========== 示例 7: 批量调用多个函数 ==========

    /**
     * @notice 批量调用多个函数
     * @dev 在一个交易中执行多个操作
     */
    function batchCall(address contractAddress) public {
        console2.log("\n=== Batch Calling Functions ===");

        uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(callerPrivateKey);

        // 调用多个函数
        // 1. 授权
        (bool success1,) = contractAddress.call(
            abi.encodeWithSignature(
                "approve(address,uint256)", address(0x1111111111111111111111111111111111111111), 1000 * 10 ** 18
            )
        );
        console2.log("Approve:", success1 ? "Success" : "Failed");

        // 2. 转账
        (bool success2,) = contractAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)", address(0x2222222222222222222222222222222222222222), 100 * 10 ** 18
            )
        );
        console2.log("Transfer:", success2 ? "Success" : "Failed");

        vm.stopBroadcast();
    }

    // ========== 辅助函数 ==========

    /**
     * @notice 获取合约地址
     */
    function getContractAddress() internal view returns (address) {
        try vm.envAddress("CONTRACT_ADDRESS") returns (address contractAddress) {
            return contractAddress;
        } catch {
            require(
                DEFAULT_CONTRACT_ADDRESS != address(0),
                "Please set CONTRACT_ADDRESS in .env or modify DEFAULT_CONTRACT_ADDRESS in script"
            );
            return DEFAULT_CONTRACT_ADDRESS;
        }
    }

    /**
     * @notice 获取发送的 ETH 数量（以 wei 为单位）
     */
    function getValueInWei() internal view returns (uint256) {
        try vm.envUint("VALUE_ETH") returns (uint256 valueEth) {
            return valueEth * 1e18;
        } catch {
            try vm.envUint("VALUE_WEI") returns (uint256 valueWei) {
                return valueWei;
            } catch {
                return DEFAULT_VALUE_ETH * 1e18;
            }
        }
    }

    /**
     * @notice 调用并解析返回值
     * @dev 通用的调用函数，可以处理各种返回类型
     */
    function callAndDecodeReturn(
        address contractAddress,
        bytes memory callData
    )
        internal
        view
        returns (bool success, bytes memory returnData)
    {
        (success, returnData) = contractAddress.staticcall(callData);

        if (success) {
            console2.log("Call successful");
            console2.logBytes(returnData);
        } else {
            console2.log("Call failed");
        }

        return (success, returnData);
    }
}
