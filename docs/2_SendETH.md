# 2. 发送 ETH 脚本

## 📝 功能说明

这是一个用于发送 ETH 到指定地址的脚本模版。支持单笔转账和批量转账功能。

## 🎯 适用场景

- 向指定地址发送 ETH
- 批量分发 ETH 给多个地址
- 测试网水龙头分发
- 合约初始化资金准备
- 空投 ETH

## 📋 使用步骤

### 方式 1: 使用环境变量（推荐）

#### 1. 配置环境变量

在 `.env` 文件中添加：

```bash
# 发送者私钥（必需）
PRIVATE_KEY=your_private_key_here

# 接收者地址
RECIPIENT_ADDRESS=0x1234567890123456789012345678901234567890

# 发送金额（单位：ETH）
AMOUNT_ETH=0.1
```

#### 2. 运行脚本

```bash
# 发送到 Sepolia 测试网
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast

# 发送到本地测试网
forge script script/2_SendETH.s.sol:SendETH --rpc-url localhost --broadcast

# 发送到主网（需要确认）
forge script script/2_SendETH.s.sol:SendETH --rpc-url mainnet --broadcast
```

### 方式 2: 使用命令行参数

```bash
# 在命令行中直接指定参数
RECIPIENT_ADDRESS=0x... AMOUNT_ETH=0.5 forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast
```

### 方式 3: 修改脚本默认值

编辑 `script/2_SendETH.s.sol`：

```solidity
// 设置默认接收者地址
address constant DEFAULT_RECIPIENT = 0x1234567890123456789012345678901234567890;

// 设置默认发送金额（单位：ETH）
uint256 constant DEFAULT_AMOUNT_ETH = 0.1;
```

然后运行：

```bash
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast
```

## 💡 使用示例

### 示例 1: 发送少量测试 ETH

```bash
# 发送 0.01 ETH 到测试地址
RECIPIENT_ADDRESS=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb AMOUNT_ETH=0.01 \
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast
```

### 示例 2: 发送大额 ETH（使用 wei）

```bash
# 发送精确的 wei 数量
RECIPIENT_ADDRESS=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb AMOUNT_WEI=1234567890000000000 \
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast
```

### 示例 3: 批量发送 ETH

修改 `script/2_SendETH.s.sol` 中的 `batchSendETH()` 函数：

```solidity
function batchSendETH() external {
    // 配置接收者列表
    address[] memory recipients = new address[](3);
    uint256[] memory amounts = new uint256[](3);

    recipients[0] = 0xRecipient1...;
    amounts[0] = 0.1 ether;

    recipients[1] = 0xRecipient2...;
    amounts[1] = 0.2 ether;

    recipients[2] = 0xRecipient3...;
    amounts[2] = 0.3 ether;

    // ... 其余代码保持不变
}
```

然后修改 `run()` 函数调用 `batchSendETH()`，或者创建新的入口：

```bash
forge script script/2_SendETH.s.sol:SendETH --sig "batchSendETH()" --rpc-url sepolia --broadcast
```

## 🔍 脚本输出

成功发送后会显示：

```
====================================
Sending ETH
====================================
From: 0xYourAddress...
To: 0xRecipientAddress...
Amount (ETH): 0.1
Amount (Wei): 100000000000000000
Sender Balance (ETH): 1.5
Chain ID: 11155111
====================================

====================================
ETH Transfer Complete!
====================================
Transaction successful
Recipient Balance (ETH): 0.1
Sender New Balance (ETH): 1.4
====================================
```

## ⚙️ 高级用法

### 1. 模拟发送（不实际广播）

```bash
# 只模拟，不发送
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia

# 查看详细信息
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia -vvvv
```

### 2. 检查余额

```bash
# 使用 cast 检查发送者余额
cast balance <your_address> --rpc-url sepolia

# 转换 wei 到 ETH
cast to-unit 1000000000000000000 ether
```

### 3. 估算 Gas 费用

```bash
# 估算交易成本
cast estimate <recipient_address> --value 0.1ether --rpc-url sepolia

# 查看当前 Gas 价格
cast gas-price --rpc-url sepolia
```

### 4. 使用不同的 Gas 设置

```bash
# 指定 Gas 价格
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --with-gas-price 30gwei --broadcast

# 指定 Gas 限制
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --gas-limit 100000 --broadcast
```

## 📊 批量发送配置

### 创建批量发送列表

可以从 CSV 文件读取地址列表：

```solidity
function batchSendFromFile() external {
    // 读取 CSV 文件
    string memory csvData = vm.readFile("recipients.csv");
    
    // 解析并发送（需要实现解析逻辑）
    // ...
}
```

CSV 文件格式 (`recipients.csv`)：

```csv
address,amount
0x1111111111111111111111111111111111111111,0.1
0x2222222222222222222222222222222222222222,0.2
0x3333333333333333333333333333333333333333,0.3
```

## 🔒 安全提示

1. ⚠️ **验证接收地址**：确保接收地址正确，ETH 转账不可撤销
2. ⚠️ **检查余额**：确保发送者有足够的 ETH（包括 Gas 费）
3. ⚠️ **小额测试**：主网操作前先在测试网测试
4. ⚠️ **私钥安全**：不要在代码中硬编码私钥
5. ⚠️ **批量发送**：大额批量发送前务必再次确认所有地址和金额

## 🐛 常见问题

### Q: 交易失败，显示 "Insufficient balance"

**A:** 检查发送者余额是否足够（包括 Gas 费）：

```bash
cast balance <your_address> --rpc-url sepolia
```

### Q: 如何取消待处理的交易？

**A:** 发送一个相同 nonce 但更高 Gas 价格的交易：

```bash
# 查看当前 nonce
cast nonce <your_address> --rpc-url sepolia

# 发送替换交易
cast send <your_address> --value 0 --nonce <nonce> --gas-price 50gwei --private-key <key> --rpc-url sepolia
```

### Q: 批量发送时某个交易失败怎么办？

**A:** 脚本会在失败时停止。可以：
1. 记录失败的位置
2. 修改脚本从失败位置继续
3. 或使用更健壮的错误处理

### Q: 如何在主网安全地发送大额 ETH？

**A:** 建议：
1. 使用硬件钱包
2. 分多次小额发送
3. 使用多签钱包
4. 先在测试网完整测试

```bash
# 使用 Ledger 硬件钱包
forge script script/2_SendETH.s.sol:SendETH --rpc-url mainnet --ledger --broadcast
```

## 📈 Gas 优化建议

批量发送时，可以使用更高效的方式：

```solidity
// 使用 assembly 降低 Gas 成本
function efficientSend(address payable recipient, uint256 amount) internal {
    assembly {
        let success := call(gas(), recipient, amount, 0, 0, 0, 0)
        if iszero(success) {
            revert(0, 0)
        }
    }
}
```

## 📚 相关文档

- [Foundry Script 文档](https://book.getfoundry.sh/tutorials/solidity-scripting)
- [Cast 命令文档](https://book.getfoundry.sh/reference/cast)
- [ETH 单位转换](https://eth-converter.com/)
