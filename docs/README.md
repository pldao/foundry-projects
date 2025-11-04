# 脚本文档索引

本目录包含项目中所有通用脚本的详细文档。每个脚本都提供了完整的使用说明、示例和最佳实践。

## 📚 脚本列表

### [1. 通用合约部署脚本](./1_DeployContract.md)
**脚本文件**: `script/1_DeployContract.s.sol`

用于部署任意 Solidity 合约的通用脚本模版。只需修改合约名称和构造函数参数即可使用。

**适用场景**:
- 部署新的智能合约
- 部署带构造函数参数的合约
- 部署可升级合约（UUPS/Transparent Proxy）
- 快速原型开发和测试

**快速开始**:
```bash
# 修改脚本中的合约部署代码
# 然后运行
forge script script/1_DeployContract.s.sol:DeployContract --rpc-url sepolia --broadcast
```

---

### [2. 发送 ETH 脚本](./2_SendETH.md)
**脚本文件**: `script/2_SendETH.s.sol`

用于向指定地址发送 ETH 的脚本模版。支持单笔转账和批量转账。

**适用场景**:
- 向指定地址发送 ETH
- 批量分发 ETH 给多个地址
- 测试网水龙头分发
- 合约初始化资金准备

**快速开始**:
```bash
# 配置环境变量
RECIPIENT_ADDRESS=0x... AMOUNT_ETH=0.1 \
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast
```

---

### [3. 发送 ERC20 代币脚本](./3_SendERC20.md)
**脚本文件**: `script/3_SendERC20.s.sol`

用于向指定地址发送 ERC20 代币的脚本模版。支持单笔转账、批量转账和授权转账。

**适用场景**:
- 向指定地址发送 ERC20 代币
- 批量分发代币给多个地址
- 代币空投
- 使用 transferFrom 从授权地址转移代币

**快速开始**:
```bash
# 配置环境变量
TOKEN_ADDRESS=0x... RECIPIENT_ADDRESS=0x... AMOUNT=100 \
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia --broadcast
```

---

### [4. 调用任意合约方法脚本](./4_CallContract.md)
**脚本文件**: `script/4_CallContract.s.sol`

用于调用任意合约的任意方法的通用脚本模版。支持只读函数、写入函数、payable 函数等。

**适用场景**:
- 调用合约的 view/pure 函数（查询数据）
- 调用合约的写入函数（修改状态）
- 调用 payable 函数（发送 ETH）
- 批量调用多个函数
- 测试合约交互

**快速开始**:
```bash
# 修改脚本中的函数调用代码
# 然后运行
CONTRACT_ADDRESS=0x... \
forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia --broadcast
```

---

## 🚀 通用使用流程

### 1. 选择合适的脚本

根据你的需求选择对应的脚本：
- 需要部署合约 → 使用脚本 1
- 需要发送 ETH → 使用脚本 2
- 需要发送 ERC20 代币 → 使用脚本 3
- 需要调用合约方法 → 使用脚本 4

### 2. 配置环境变量

在 `.env` 文件中配置必要的参数：

```bash
# 基本配置（所有脚本都需要）
PRIVATE_KEY=your_private_key_here

# 网络 RPC（根据目标网络配置）
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/your-api-key
MAINNET_RPC_URL=https://eth-mainnet.g.alchemy.com/v2/your-api-key

# 脚本特定配置（根据使用的脚本配置）
CONTRACT_ADDRESS=0x...
RECIPIENT_ADDRESS=0x...
TOKEN_ADDRESS=0x...
AMOUNT=100
```

### 3. 修改脚本

根据你的具体需求修改脚本中的代码：
- 部署脚本：修改 `deployContract()` 函数
- 发送脚本：配置接收者和金额
- 调用脚本：在 `run()` 中取消注释要调用的函数

### 4. 测试运行

先在本地或测试网进行模拟：

```bash
# 模拟运行（不广播交易）
forge script script/X_Script.s.sol:ScriptName --rpc-url sepolia

# 查看详细输出
forge script script/X_Script.s.sol:ScriptName --rpc-url sepolia -vvvv
```

### 5. 正式执行

确认无误后执行实际操作：

```bash
# 测试网执行
forge script script/X_Script.s.sol:ScriptName --rpc-url sepolia --broadcast

# 主网执行（谨慎！）
forge script script/X_Script.s.sol:ScriptName --rpc-url mainnet --broadcast --verify
```

## 📖 环境变量参考

### 必需变量

| 变量名 | 说明 | 使用脚本 |
|--------|------|---------|
| `PRIVATE_KEY` | 交易发送者私钥 | 所有脚本 |
| `CONTRACT_ADDRESS` | 目标合约地址 | 1, 4 |
| `TOKEN_ADDRESS` | ERC20 代币地址 | 3 |
| `RECIPIENT_ADDRESS` | 接收者地址 | 2, 3 |

### 可选变量

| 变量名 | 说明 | 默认值 | 使用脚本 |
|--------|------|--------|---------|
| `AMOUNT` | 代币数量 | 0 | 3 |
| `AMOUNT_ETH` | ETH 数量 | 0 | 2 |
| `VALUE_ETH` | Payable 函数发送的 ETH | 0 | 4 |
| `TOKEN_DECIMALS` | 代币精度 | 18 | 3 |

## 🛠️ 常用命令速查

### Forge 命令

```bash
# 编译合约
forge build

# 运行测试
forge test

# 格式化代码
forge fmt

# 运行脚本（模拟）
forge script <SCRIPT_PATH> --rpc-url <NETWORK>

# 运行脚本（广播）
forge script <SCRIPT_PATH> --rpc-url <NETWORK> --broadcast

# 运行脚本并验证
forge script <SCRIPT_PATH> --rpc-url <NETWORK> --broadcast --verify
```

### Cast 命令

```bash
# 查询余额
cast balance <ADDRESS> --rpc-url <NETWORK>

# 调用只读函数
cast call <CONTRACT> "functionName()" --rpc-url <NETWORK>

# 调用写入函数
cast send <CONTRACT> "functionName()" --private-key <KEY> --rpc-url <NETWORK>

# 查看合约代码
cast code <CONTRACT> --rpc-url <NETWORK>

# 查看交易详情
cast tx <TX_HASH> --rpc-url <NETWORK>

# 查看区块信息
cast block latest --rpc-url <NETWORK>
```

## 🔒 安全最佳实践

### 1. 私钥管理

```bash
# ❌ 错误：在代码中硬编码私钥
uint256 privateKey = 0xabc...;

# ✅ 正确：使用环境变量
uint256 privateKey = vm.envUint("PRIVATE_KEY");

# ✅ 更好：使用硬件钱包（主网）
forge script ... --ledger
```

### 2. 测试流程

```bash
# 1. 本地测试
forge test

# 2. 本地模拟
forge script ... --rpc-url localhost

# 3. 测试网测试
forge script ... --rpc-url sepolia --broadcast

# 4. 主网小额测试
# 先用小额测试

# 5. 主网正式执行
forge script ... --rpc-url mainnet --broadcast
```

### 3. 交易确认

```bash
# 查看待处理交易
cast tx <TX_HASH> --rpc-url <NETWORK>

# 等待交易确认
cast receipt <TX_HASH> --rpc-url <NETWORK>

# 检查交易状态
cast tx <TX_HASH> --rpc-url <NETWORK> | grep status
```

### 4. Gas 管理

```bash
# 估算 Gas
forge script ... --rpc-url <NETWORK> --gas-estimate

# 设置 Gas 价格
forge script ... --with-gas-price 30gwei

# 设置 Gas 限制
forge script ... --gas-limit 5000000
```

## 💡 使用技巧

### 1. 调试技巧

```bash
# 显示详细日志
forge script ... -vvvv

# 查看 trace
forge script ... --debug

# 检查编码
cast abi-encode "functionName(type1,type2)" arg1 arg2
```

### 2. 批量操作

```bash
# 循环执行脚本
for network in sepolia goerli mainnet; do
    forge script script/Deploy.s.sol --rpc-url $network --broadcast
done
```

### 3. 保存部署记录

```bash
# 自动保存到文件
forge script ... --broadcast | tee deployment.log

# 解析部署地址
grep "Contract Address" deployment.log
```

## 🆘 故障排查

### 问题：交易失败

```bash
# 1. 检查余额
cast balance <YOUR_ADDRESS> --rpc-url <NETWORK>

# 2. 检查 nonce
cast nonce <YOUR_ADDRESS> --rpc-url <NETWORK>

# 3. 估算 Gas
cast estimate <CONTRACT> "functionName()" --rpc-url <NETWORK>

# 4. 查看详细错误
forge script ... -vvvv
```

### 问题：编译失败

```bash
# 清理并重新编译
forge clean
forge build

# 更新依赖
forge update

# 检查 Solidity 版本
forge --version
```

### 问题：RPC 连接问题

```bash
# 测试 RPC 连接
cast block latest --rpc-url <RPC_URL>

# 使用备用 RPC
export BACKUP_RPC_URL=https://...
forge script ... --rpc-url $BACKUP_RPC_URL
```

## 📚 更多资源

- [Foundry Book](https://book.getfoundry.sh/) - 官方文档
- [Foundry GitHub](https://github.com/foundry-rs/foundry) - 源代码和问题追踪
- [Solidity 文档](https://docs.soliditylang.org/) - Solidity 语言文档
- [OpenZeppelin 文档](https://docs.openzeppelin.com/) - 安全合约库
- [Ethereum 开发者资源](https://ethereum.org/developers) - 综合开发资源

## 🤝 贡献

如果你发现文档中的错误或有改进建议，欢迎提交 Issue 或 Pull Request！

---

**最后更新**: 2024年11月

**维护者**: 项目团队
