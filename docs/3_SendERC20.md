# 3. 发送 ERC20 代币脚本

## 📝 功能说明

这是一个用于发送 ERC20 代币到指定地址的脚本模版。支持单笔转账、批量转账和授权转账功能。

## 🎯 适用场景

- 向指定地址发送 ERC20 代币
- 批量分发代币给多个地址
- 代币空投
- 使用 transferFrom 从授权地址转移代币
- 测试代币转账功能

## 📋 使用步骤

### 方式 1: 使用环境变量（推荐）

#### 1. 配置环境变量

在 `.env` 文件中添加：

```bash
# 发送者私钥（必需）
PRIVATE_KEY=your_private_key_here

# ERC20 代币合约地址（必需）
TOKEN_ADDRESS=0x1234567890123456789012345678901234567890

# 接收者地址（必需）
RECIPIENT_ADDRESS=0x9876543210987654321098765432109876543210

# 发送数量（会自动乘以代币精度）
AMOUNT=100

# 代币精度（可选，默认 18）
TOKEN_DECIMALS=18

# 如果 AMOUNT 已经包含精度，设置为 true
# AMOUNT_WITH_DECIMALS=true
```

#### 2. 运行脚本

```bash
# 发送到 Sepolia 测试网
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia --broadcast

# 发送到本地测试网
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url localhost --broadcast

# 发送到主网
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url mainnet --broadcast
```

### 方式 2: 使用命令行参数

```bash
# 在命令行中直接指定参数
TOKEN_ADDRESS=0x... RECIPIENT_ADDRESS=0x... AMOUNT=1000 \
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia --broadcast
```

## 💡 使用示例

### 示例 1: 发送标准 ERC20 代币（18 精度）

```bash
# 发送 100 个代币（会自动转换为 100 * 10^18）
TOKEN_ADDRESS=0xYourTokenAddress \
RECIPIENT_ADDRESS=0xRecipientAddress \
AMOUNT=100 \
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia --broadcast
```

### 示例 2: 发送 USDC（6 精度）

```bash
# USDC 使用 6 位精度
TOKEN_ADDRESS=0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 \
RECIPIENT_ADDRESS=0x... \
AMOUNT=1000 \
TOKEN_DECIMALS=6 \
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url mainnet --broadcast

# 这会发送 1000 USDC (1000 * 10^6 = 1000000000)
```

### 示例 3: 发送精确数量（已包含精度）

```bash
# 直接指定 wei 单位的数量
TOKEN_ADDRESS=0x... \
RECIPIENT_ADDRESS=0x... \
AMOUNT=1000000000000000000 \
AMOUNT_WITH_DECIMALS=true \
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia --broadcast
```

### 示例 4: 批量发送代币

修改 `script/3_SendERC20.s.sol` 中的 `batchSendERC20()` 函数：

```solidity
function batchSendERC20() external {
    // 配置接收者列表
    address[] memory recipients = new address[](3);
    uint256[] memory amounts = new uint256[](3);

    recipients[0] = 0xRecipient1...;
    amounts[0] = 100 * (10 ** decimals);

    recipients[1] = 0xRecipient2...;
    amounts[1] = 200 * (10 ** decimals);

    recipients[2] = 0xRecipient3...;
    amounts[2] = 300 * (10 ** decimals);

    // ... 其余代码保持不变
}
```

运行批量发送：

```bash
forge script script/3_SendERC20.s.sol:SendERC20 --sig "batchSendERC20()" --rpc-url sepolia --broadcast
```

### 示例 5: 使用 transferFrom（授权转账）

```bash
# 从另一个地址转移代币（需要先授权）
TOKEN_ADDRESS=0x... \
FROM_ADDRESS=0xTokenOwner... \
RECIPIENT_ADDRESS=0xReceiver... \
AMOUNT=100 \
forge script script/3_SendERC20.s.sol:SendERC20 --sig "sendERC20WithApproval()" --rpc-url sepolia --broadcast
```

**注意**: 使用 `transferFrom` 前，代币所有者需要先授权：

```bash
# 使用 cast 授权
cast send <TOKEN_ADDRESS> "approve(address,uint256)" <SPENDER_ADDRESS> <AMOUNT> \
    --private-key <OWNER_KEY> --rpc-url sepolia
```

## 🔍 脚本输出

成功发送后会显示：

```
====================================
Sending ERC20 Token
====================================
Token Address: 0x...
From: 0xSenderAddress...
To: 0xRecipientAddress...
Amount: 100000000000000000000
Amount (with decimals): 100
Sender Balance: 1000000000000000000000
Sender Balance (with decimals): 1000
Decimals: 18
Chain ID: 11155111
====================================

====================================
ERC20 Transfer Complete!
====================================
Transaction successful
Recipient Balance: 100000000000000000000
Recipient Balance (with decimals): 100
Sender New Balance: 900000000000000000000
Sender New Balance (with decimals): 900
====================================
```

## ⚙️ 高级用法

### 1. 查询代币信息

```bash
# 查询代币余额
cast call <TOKEN_ADDRESS> "balanceOf(address)" <YOUR_ADDRESS> --rpc-url sepolia

# 查询代币名称
cast call <TOKEN_ADDRESS> "name()" --rpc-url sepolia | cast to-ascii

# 查询代币符号
cast call <TOKEN_ADDRESS> "symbol()" --rpc-url sepolia | cast to-ascii

# 查询代币精度
cast call <TOKEN_ADDRESS> "decimals()" --rpc-url sepolia

# 查询代币总供应量
cast call <TOKEN_ADDRESS> "totalSupply()" --rpc-url sepolia
```

### 2. 授权额度管理

```bash
# 查询授权额度
cast call <TOKEN_ADDRESS> "allowance(address,address)" <OWNER> <SPENDER> --rpc-url sepolia

# 设置授权额度
cast send <TOKEN_ADDRESS> "approve(address,uint256)" <SPENDER> <AMOUNT> \
    --private-key <KEY> --rpc-url sepolia

# 增加授权额度
cast send <TOKEN_ADDRESS> "increaseAllowance(address,uint256)" <SPENDER> <AMOUNT> \
    --private-key <KEY> --rpc-url sepolia

# 减少授权额度
cast send <TOKEN_ADDRESS> "decreaseAllowance(address,uint256)" <SPENDER> <AMOUNT> \
    --private-key <KEY> --rpc-url sepolia
```

### 3. 模拟发送（不实际广播）

```bash
# 只模拟，不发送
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia

# 查看详细信息
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia -vvvv
```

### 4. 处理不同精度的代币

```solidity
// 常见代币精度
// USDT, USDC: 6 位
// WBTC: 8 位  
// DAI, WETH, 大多数 ERC20: 18 位

// 示例：发送 1000 USDC (6 位精度)
TOKEN_DECIMALS=6 AMOUNT=1000 forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url mainnet --broadcast

// 示例：发送 0.5 WBTC (8 位精度)
TOKEN_DECIMALS=8 AMOUNT=0.5 forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url mainnet --broadcast
```

## 📊 批量发送优化

### 使用自定义批量发送合约

对于大量地址，建议部署专门的批量发送合约：

```solidity
// BatchTransfer.sol
contract BatchTransfer {
    function batchTransfer(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(recipients.length == amounts.length, "Length mismatch");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(
                token.transferFrom(msg.sender, recipients[i], amounts[i]),
                "Transfer failed"
            );
        }
    }
}
```

使用步骤：
1. 部署 BatchTransfer 合约
2. 授权代币给 BatchTransfer 合约
3. 调用 batchTransfer 函数

## 🔒 安全提示

1. ⚠️ **验证代币地址**：确保代币合约地址正确，避免发送到错误合约
2. ⚠️ **检查余额**：确保有足够的代币余额
3. ⚠️ **精度问题**：注意代币精度，避免发送错误数量
4. ⚠️ **授权安全**：不要授权无限额度给不信任的合约
5. ⚠️ **小额测试**：主网操作前先用小额测试
6. ⚠️ **合约验证**：确认代币合约是否可信
7. ⚠️ **防重入**：批量转账时注意 Gas 限制

## 🐛 常见问题

### Q: 交易失败，显示 "Insufficient token balance"

**A:** 检查发送者代币余额：

```bash
cast call <TOKEN_ADDRESS> "balanceOf(address)" <YOUR_ADDRESS> --rpc-url sepolia
```

### Q: 如何处理不同精度的代币？

**A:** 设置 `TOKEN_DECIMALS` 环境变量：

```bash
# USDC (6 位精度)
TOKEN_DECIMALS=6 AMOUNT=1000 forge script ...

# WBTC (8 位精度)  
TOKEN_DECIMALS=8 AMOUNT=0.1 forge script ...

# 标准 ERC20 (18 位精度)
TOKEN_DECIMALS=18 AMOUNT=100 forge script ...
```

### Q: transferFrom 失败，显示 "Insufficient allowance"

**A:** 需要先授权：

```bash
# 检查当前授权额度
cast call <TOKEN> "allowance(address,address)" <OWNER> <SPENDER> --rpc-url sepolia

# 设置授权
cast send <TOKEN> "approve(address,uint256)" <SPENDER> <AMOUNT> \
    --private-key <OWNER_KEY> --rpc-url sepolia
```

### Q: 如何取消待处理的代币转账？

**A:** 发送一个相同 nonce 但更高 Gas 价格的交易：

```bash
# 查看当前 nonce
cast nonce <YOUR_ADDRESS> --rpc-url sepolia

# 发送替换交易（发送 0 代币给自己）
cast send <TOKEN> "transfer(address,uint256)" <YOUR_ADDRESS> 0 \
    --nonce <NONCE> --gas-price 50gwei --private-key <KEY> --rpc-url sepolia
```

### Q: 批量发送时 Gas 不够怎么办？

**A:** 分批次发送或增加 Gas 限制：

```bash
# 方式 1: 分批次（每次 50 个地址）
# 修改脚本中的 recipients 数组

# 方式 2: 增加 Gas 限制
forge script script/3_SendERC20.s.sol:SendERC20 \
    --gas-limit 5000000 --rpc-url sepolia --broadcast
```

### Q: 如何验证代币合约是否安全？

**A:** 检查以下几点：

```bash
# 1. 验证代币信息
cast call <TOKEN> "name()" --rpc-url sepolia | cast to-ascii
cast call <TOKEN> "symbol()" --rpc-url sepolia | cast to-ascii
cast call <TOKEN> "totalSupply()" --rpc-url sepolia

# 2. 检查合约代码（在 Etherscan 上）
# 3. 查看审计报告
# 4. 检查项目社区和声誉
```

## 📈 Gas 优化

### 优化批量转账 Gas

```solidity
// 使用紧凑编码
function efficientBatchTransfer(
    IERC20 token,
    address[] calldata recipients,
    uint256 amount  // 所有人发送相同数量
) external {
    for (uint256 i = 0; i < recipients.length;) {
        token.transfer(recipients[i], amount);
        unchecked { ++i; }
    }
}
```

### 使用 Merkle Airdrop

对于大规模空投，使用 Merkle Tree 更节省 Gas：

```solidity
// MerkleAirdrop.sol
contract MerkleAirdrop {
    bytes32 public merkleRoot;
    
    function claim(uint256 amount, bytes32[] calldata proof) external {
        // 验证 Merkle 证明
        // 发送代币
    }
}
```

## 📚 相关文档

- [ERC20 标准](https://eips.ethereum.org/EIPS/eip-20)
- [OpenZeppelin ERC20 文档](https://docs.openzeppelin.com/contracts/4.x/erc20)
- [Foundry Cast 文档](https://book.getfoundry.sh/reference/cast)
- [代币精度说明](https://docs.openzeppelin.com/contracts/4.x/erc20#a-note-on-decimals)
