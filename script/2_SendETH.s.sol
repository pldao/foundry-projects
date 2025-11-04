// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

// ====================================
// 使用说明：
// 1. 在 .env 中配置 PRIVATE_KEY（发送者私钥）
// 2. 在配置区域设置接收者地址和金额
// 3. 或使用环境变量：RECIPIENT_ADDRESS 和 AMOUNT_ETH
// 4. 运行脚本发送 ETH
// ====================================

/**
 * @title 2_SendETH
 * @notice 发送 ETH 给指定地址的脚本模版
 * @dev 使用方法:
 *      forge script script/2_SendETH.s.sol:SendETH --rpc-url <network> --broadcast
 *
 *      环境变量配置:
 *      - PRIVATE_KEY: 发送者私钥（必需）
 *      - RECIPIENT_ADDRESS: 接收者地址（可选）
 *      - AMOUNT_ETH: 发送金额（单位：ETH）（可选）
 *
 *      示例:
 *      RECIPIENT_ADDRESS=0x... AMOUNT_ETH=0.1 forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast
 */
contract SendETH is Script {
    // ========== 配置区域 - 在这里修改发送参数 ==========

    // TODO: 修改接收者地址（或使用环境变量 RECIPIENT_ADDRESS）
    address constant DEFAULT_RECIPIENT = address(0); // 设置为 address(0) 表示必须使用环境变量

    // TODO: 修改发送金额（或使用环境变量 AMOUNT_ETH）
    uint256 constant DEFAULT_AMOUNT_ETH = 0; // 单位：ETH，设置为 0 表示必须使用环境变量

    // ================================================

    function run() external {
        // 获取发送者私钥和地址
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(senderPrivateKey);

        // 获取接收者地址
        address recipient = getRecipient();
        require(recipient != address(0), "Recipient address cannot be zero");

        // 获取发送金额（转换为 wei）
        uint256 amountWei = getAmountInWei();
        require(amountWei > 0, "Amount must be greater than zero");

        // 检查余额
        uint256 senderBalance = sender.balance;
        require(senderBalance >= amountWei, "Insufficient balance");

        // 显示发送信息
        console2.log("====================================");
        console2.log("Sending ETH");
        console2.log("====================================");
        console2.log("From:", sender);
        console2.log("To:", recipient);
        console2.log("Amount (ETH):", amountWei / 1e18);
        console2.log("Amount (Wei):", amountWei);
        console2.log("Sender Balance (ETH):", senderBalance / 1e18);
        console2.log("Chain ID:", block.chainid);
        console2.log("====================================");

        // 开始广播交易
        vm.startBroadcast(senderPrivateKey);

        // 发送 ETH
        (bool success,) = payable(recipient).call{ value: amountWei }("");
        require(success, "ETH transfer failed");

        vm.stopBroadcast();

        // 显示交易完成信息
        console2.log("\n====================================");
        console2.log("ETH Transfer Complete!");
        console2.log("====================================");
        console2.log("Transaction successful");
        console2.log("Recipient Balance (ETH):", recipient.balance / 1e18);
        console2.log("Sender New Balance (ETH):", sender.balance / 1e18);
        console2.log("====================================\n");
    }

    /**
     * @notice 批量发送 ETH 给多个地址
     * @dev 取消注释并在 run() 中调用此函数来批量发送
     */
    function batchSendETH() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(senderPrivateKey);

        // ========== 配置批量发送列表 ==========
        address[] memory recipients = new address[](3);
        uint256[] memory amounts = new uint256[](3);

        // TODO: 配置接收者地址和金额
        recipients[0] = address(0x1111111111111111111111111111111111111111);
        amounts[0] = 0.1 ether;

        recipients[1] = address(0x2222222222222222222222222222222222222222);
        amounts[1] = 0.2 ether;

        recipients[2] = address(0x3333333333333333333333333333333333333333);
        amounts[2] = 0.3 ether;
        // =====================================

        // 计算总金额
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(sender.balance >= totalAmount, "Insufficient balance for batch transfer");

        console2.log("====================================");
        console2.log("Batch Sending ETH");
        console2.log("====================================");
        console2.log("From:", sender);
        console2.log("Total Recipients:", recipients.length);
        console2.log("Total Amount (ETH):", totalAmount / 1e18);
        console2.log("Sender Balance (ETH):", sender.balance / 1e18);
        console2.log("====================================");

        vm.startBroadcast(senderPrivateKey);

        // 批量发送
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");

            (bool success,) = payable(recipients[i]).call{ value: amounts[i] }("");
            require(success, string(abi.encodePacked("Transfer failed to recipient ", vm.toString(i))));

            console2.log("Sent", amounts[i] / 1e18, "ETH to", recipients[i]);
        }

        vm.stopBroadcast();

        console2.log("\n====================================");
        console2.log("Batch Transfer Complete!");
        console2.log("====================================");
        console2.log("All transfers successful");
        console2.log("====================================\n");
    }

    /**
     * @notice 获取接收者地址
     * @return 接收者地址
     */
    function getRecipient() internal view returns (address) {
        // 优先使用环境变量
        try vm.envAddress("RECIPIENT_ADDRESS") returns (address recipient) {
            return recipient;
        } catch {
            // 使用默认值
            require(
                DEFAULT_RECIPIENT != address(0),
                "Please set RECIPIENT_ADDRESS in .env or modify DEFAULT_RECIPIENT in script"
            );
            return DEFAULT_RECIPIENT;
        }
    }

    /**
     * @notice 获取发送金额（以 wei 为单位）
     * @return 发送金额（wei）
     */
    function getAmountInWei() internal view returns (uint256) {
        // 优先使用环境变量（单位：ETH）
        try vm.envUint("AMOUNT_ETH") returns (uint256 amountEth) {
            return amountEth * 1e18; // 转换为 wei
        } catch {
            // 尝试直接读取 wei 单位
            try vm.envUint("AMOUNT_WEI") returns (uint256 amountWei) {
                return amountWei;
            } catch {
                // 使用默认值
                require(DEFAULT_AMOUNT_ETH > 0, "Please set AMOUNT_ETH in .env or modify DEFAULT_AMOUNT_ETH in script");
                return DEFAULT_AMOUNT_ETH * 1e18;
            }
        }
    }
}
