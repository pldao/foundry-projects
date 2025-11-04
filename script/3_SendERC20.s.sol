// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// ====================================
// 使用说明：
// 1. 在 .env 中配置 PRIVATE_KEY（发送者私钥）
// 2. 配置 TOKEN_ADDRESS（ERC20 代币合约地址）
// 3. 配置 RECIPIENT_ADDRESS（接收者地址）
// 4. 配置 AMOUNT（代币数量，注意精度）
// 5. 运行脚本发送 ERC20 代币
// ====================================

/**
 * @title 3_SendERC20
 * @notice 发送 ERC20 代币给指定地址的脚本模版
 * @dev 使用方法:
 *      forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url <network> --broadcast
 *
 *      环境变量配置:
 *      - PRIVATE_KEY: 发送者私钥（必需）
 *      - TOKEN_ADDRESS: ERC20 代币合约地址（必需）
 *      - RECIPIENT_ADDRESS: 接收者地址（必需）
 *      - AMOUNT: 代币数量（需要考虑精度）（必需）
 *      - TOKEN_DECIMALS: 代币精度（可选，默认 18）
 *
 *      示例:
 *      TOKEN_ADDRESS=0x... RECIPIENT_ADDRESS=0x... AMOUNT=100 \
 *      forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia --broadcast
 */
contract SendERC20 is Script {
    // ========== 配置区域 - 在这里修改发送参数 ==========

    // TODO: 修改代币合约地址（或使用环境变量 TOKEN_ADDRESS）
    address constant DEFAULT_TOKEN_ADDRESS = address(0);

    // TODO: 修改接收者地址（或使用环境变量 RECIPIENT_ADDRESS）
    address constant DEFAULT_RECIPIENT = address(0);

    // TODO: 修改发送数量（或使用环境变量 AMOUNT）
    uint256 constant DEFAULT_AMOUNT = 0; // 注意：这个数量需要乘以 10^decimals

    // 默认代币精度
    uint256 constant DEFAULT_DECIMALS = 18;

    // ================================================

    function run() external {
        // 获取发送者私钥和地址
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(senderPrivateKey);

        // 获取代币合约地址
        address tokenAddress = getTokenAddress();
        require(tokenAddress != address(0), "Token address cannot be zero");

        // 获取接收者地址
        address recipient = getRecipient();
        require(recipient != address(0), "Recipient address cannot be zero");

        // 创建代币合约接口
        IERC20 token = IERC20(tokenAddress);

        // 获取代币信息
        uint256 decimals = getDecimals(tokenAddress);
        uint256 amount = getAmount(decimals);
        require(amount > 0, "Amount must be greater than zero");

        // 检查发送者余额
        uint256 senderBalance = token.balanceOf(sender);
        require(senderBalance >= amount, "Insufficient token balance");

        // 显示发送信息
        console2.log("====================================");
        console2.log("Sending ERC20 Token");
        console2.log("====================================");
        console2.log("Token Address:", tokenAddress);
        console2.log("From:", sender);
        console2.log("To:", recipient);
        console2.log("Amount:", amount);
        console2.log("Amount (with decimals):", amount / (10 ** decimals));
        console2.log("Sender Balance:", senderBalance);
        console2.log("Sender Balance (with decimals):", senderBalance / (10 ** decimals));
        console2.log("Decimals:", decimals);
        console2.log("Chain ID:", block.chainid);
        console2.log("====================================");

        // 开始广播交易
        vm.startBroadcast(senderPrivateKey);

        // 发送 ERC20 代币
        bool success = token.transfer(recipient, amount);
        require(success, "Token transfer failed");

        vm.stopBroadcast();

        // 显示交易完成信息
        console2.log("\n====================================");
        console2.log("ERC20 Transfer Complete!");
        console2.log("====================================");
        console2.log("Transaction successful");
        console2.log("Recipient Balance:", token.balanceOf(recipient));
        console2.log("Recipient Balance (with decimals):", token.balanceOf(recipient) / (10 ** decimals));
        console2.log("Sender New Balance:", token.balanceOf(sender));
        console2.log("Sender New Balance (with decimals):", token.balanceOf(sender) / (10 ** decimals));
        console2.log("====================================\n");
    }

    /**
     * @notice 批量发送 ERC20 代币给多个地址
     * @dev 取消注释并在 run() 中调用此函数来批量发送
     */
    function batchSendERC20() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(senderPrivateKey);

        // 获取代币地址
        address tokenAddress = getTokenAddress();
        IERC20 token = IERC20(tokenAddress);
        uint256 decimals = getDecimals(tokenAddress);

        // ========== 配置批量发送列表 ==========
        address[] memory recipients = new address[](3);
        uint256[] memory amounts = new uint256[](3);

        // TODO: 配置接收者地址和数量
        recipients[0] = address(0x1111111111111111111111111111111111111111);
        amounts[0] = 100 * (10 ** decimals); // 100 代币

        recipients[1] = address(0x2222222222222222222222222222222222222222);
        amounts[1] = 200 * (10 ** decimals); // 200 代币

        recipients[2] = address(0x3333333333333333333333333333333333333333);
        amounts[2] = 300 * (10 ** decimals); // 300 代币
        // =====================================

        // 计算总数量
        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(token.balanceOf(sender) >= totalAmount, "Insufficient token balance for batch transfer");

        console2.log("====================================");
        console2.log("Batch Sending ERC20");
        console2.log("====================================");
        console2.log("Token Address:", tokenAddress);
        console2.log("From:", sender);
        console2.log("Total Recipients:", recipients.length);
        console2.log("Total Amount:", totalAmount);
        console2.log("Total Amount (with decimals):", totalAmount / (10 ** decimals));
        console2.log("Sender Balance:", token.balanceOf(sender));
        console2.log("====================================");

        vm.startBroadcast(senderPrivateKey);

        // 批量发送
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "Invalid recipient address");

            bool success = token.transfer(recipients[i], amounts[i]);
            require(success, string(abi.encodePacked("Transfer failed to recipient ", vm.toString(i))));

            console2.log("Sent", amounts[i] / (10 ** decimals), "tokens to", recipients[i]);
        }

        vm.stopBroadcast();

        console2.log("\n====================================");
        console2.log("Batch Transfer Complete!");
        console2.log("====================================");
        console2.log("All transfers successful");
        console2.log("====================================\n");
    }

    /**
     * @notice 使用 transferFrom 发送代币（需要先授权）
     * @dev 适用于从其他地址转移代币的场景
     */
    function sendERC20WithApproval() external {
        uint256 senderPrivateKey = vm.envUint("PRIVATE_KEY");
        address sender = vm.addr(senderPrivateKey);

        address tokenAddress = getTokenAddress();
        address from = vm.envAddress("FROM_ADDRESS"); // 代币所有者地址
        address to = getRecipient();

        IERC20 token = IERC20(tokenAddress);
        uint256 decimals = getDecimals(tokenAddress);
        uint256 amount = getAmount(decimals);

        // 检查授权额度
        uint256 allowance = token.allowance(from, sender);
        require(allowance >= amount, "Insufficient allowance");

        console2.log("====================================");
        console2.log("Sending ERC20 with TransferFrom");
        console2.log("====================================");
        console2.log("Token Address:", tokenAddress);
        console2.log("From:", from);
        console2.log("To:", to);
        console2.log("Caller:", sender);
        console2.log("Amount:", amount);
        console2.log("Allowance:", allowance);
        console2.log("====================================");

        vm.startBroadcast(senderPrivateKey);

        // 使用 transferFrom
        bool success = token.transferFrom(from, to, amount);
        require(success, "TransferFrom failed");

        vm.stopBroadcast();

        console2.log("\n====================================");
        console2.log("TransferFrom Complete!");
        console2.log("====================================");
    }

    /**
     * @notice 获取代币合约地址
     */
    function getTokenAddress() internal view returns (address) {
        try vm.envAddress("TOKEN_ADDRESS") returns (address tokenAddress) {
            return tokenAddress;
        } catch {
            require(
                DEFAULT_TOKEN_ADDRESS != address(0),
                "Please set TOKEN_ADDRESS in .env or modify DEFAULT_TOKEN_ADDRESS in script"
            );
            return DEFAULT_TOKEN_ADDRESS;
        }
    }

    /**
     * @notice 获取接收者地址
     */
    function getRecipient() internal view returns (address) {
        try vm.envAddress("RECIPIENT_ADDRESS") returns (address recipient) {
            return recipient;
        } catch {
            require(
                DEFAULT_RECIPIENT != address(0),
                "Please set RECIPIENT_ADDRESS in .env or modify DEFAULT_RECIPIENT in script"
            );
            return DEFAULT_RECIPIENT;
        }
    }

    /**
     * @notice 获取代币精度
     */
    function getDecimals(address tokenAddress) internal view returns (uint256) {
        try vm.envUint("TOKEN_DECIMALS") returns (uint256 decimals) {
            return decimals;
        } catch {
            // 尝试从合约读取
            try this.readDecimals(tokenAddress) returns (uint8 decimals) {
                return uint256(decimals);
            } catch {
                console2.log("Warning: Could not read decimals from contract, using default:", DEFAULT_DECIMALS);
                return DEFAULT_DECIMALS;
            }
        }
    }

    /**
     * @notice 从代币合约读取精度
     */
    function readDecimals(address tokenAddress) external view returns (uint8) {
        // 使用低级调用读取 decimals
        (bool success, bytes memory data) = tokenAddress.staticcall(abi.encodeWithSignature("decimals()"));
        require(success, "Failed to read decimals");
        return abi.decode(data, (uint8));
    }

    /**
     * @notice 获取发送数量
     */
    function getAmount(uint256 decimals) internal view returns (uint256) {
        try vm.envUint("AMOUNT") returns (uint256 amount) {
            // 检查是否已经包含精度
            try vm.envBool("AMOUNT_WITH_DECIMALS") returns (bool withDecimals) {
                if (withDecimals) {
                    return amount; // 已经包含精度
                }
            } catch { }

            // 默认情况：需要乘以精度
            return amount * (10 ** decimals);
        } catch {
            require(DEFAULT_AMOUNT > 0, "Please set AMOUNT in .env or modify DEFAULT_AMOUNT in script");
            return DEFAULT_AMOUNT * (10 ** decimals);
        }
    }
}
