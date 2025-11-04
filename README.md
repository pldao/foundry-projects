# Foundry ERC20 Upgradeable Project

一个基于 Foundry 的可升级 ERC20 代币项目，集成了 ERC1967 代理模式和 UUPS 升级机制。

## 📋 项目特性

- ✅ **可升级的 ERC20 代币**: 使用 UUPS 代理模式
- ✅ **完整的权限控制**: 包含 Admin、Minter、Pauser、Upgrader 角色
- ✅ **多网络支持**: 预配置主流 EVM 链（Ethereum、BSC、Polygon、Arbitrum、Optimism、Base 等）
- ✅ **一键格式化**: 使用 `make format` 格式化所有合约
- ✅ **完整的测试套件**: 包含单元测试和集成测试
- ✅ **自动化部署脚本**: 支持多网络部署和升级
- ✅ **合约验证**: 自动化的 Etherscan 验证流程

## 🏗️ 项目结构

```
.
├── src/
│   ├── token/
│   │   └── Erc20.sol              # 可升级的 ERC20 代币实现
│   └── proxy/
│       └── ERC1967Proxy.sol       # ERC1967 代理合约
├── script/
│   ├── BaseScript.sol             # 基础部署脚本
│   ├── DeployERC20.s.sol          # ERC20 部署脚本
│   ├── UpgradeERC20.s.sol         # ERC20 升级脚本
│   ├── 1_DeployContract.s.sol     # 通用合约部署脚本
│   ├── 2_SendETH.s.sol            # 发送 ETH 脚本
│   ├── 3_SendERC20.s.sol          # 发送 ERC20 代币脚本
│   └── 4_CallContract.s.sol       # 调用任意合约方法脚本
├── test/
│   └── Erc20.t.sol                # ERC20 测试文件
├── docs/
│   ├── README.md                  # 脚本文档索引
│   ├── 1_DeployContract.md        # 部署脚本文档
│   ├── 2_SendETH.md               # 发送 ETH 文档
│   ├── 3_SendERC20.md             # 发送 ERC20 文档
│   └── 4_CallContract.md          # 调用合约文档
├── .env.example                   # 环境变量模板
├── foundry.toml                   # Foundry 配置文件
├── Makefile                       # 常用命令集合
└── README.md                      # 项目文档
```

## 🚀 快速开始

### 1. 安装依赖

```bash
# 首次使用运行完整设置（会自动创建 .env 文件并安装依赖）
make setup

# 或者手动安装
make install
```

### 2. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入你的私钥和 RPC URLs
vim .env
```

**重要配置项：**
- `PRIVATE_KEY`: 部署者私钥
- `ETHERSCAN_API_KEY`: 用于合约验证
- `*_RPC_URL`: 各网络的 RPC 端点
- `TOKEN_NAME`, `TOKEN_SYMBOL`: 代币名称和符号
- `INITIAL_SUPPLY`: 初始供应量

### 3. 编译合约

```bash
make build
```

### 4. 运行测试

```bash
# 运行所有测试
make test

# 运行测试并生成 Gas 报告
make test-gas

# 生成测试覆盖率报告
make coverage
```

### 5. 格式化代码（一键格式化）

```bash
# 格式化所有 Solidity 文件
make format

# 检查代码格式是否正确
make format-check
```

## 📦 部署指南

### 本地部署

```bash
# 启动本地节点（新终端）
make anvil

# 部署到本地网络
make deploy-localhost
```

### 测试网部署

```bash
# 部署到 Sepolia 测试网
make deploy-sepolia

# 部署到 BSC 测试网
make deploy-bsc-testnet

# 部署到 Polygon Amoy 测试网
make deploy-polygon-amoy
```

### 主网部署

```bash
# 部署到 Ethereum 主网（会提示确认）
make deploy-mainnet

# 部署到 BSC 主网
make deploy-bsc

# 部署到 Polygon 主网
make deploy-polygon

# 部署到 Arbitrum 主网
make deploy-arbitrum

# 部署到 Optimism 主网
make deploy-optimism

# 部署到 Base 主网
make deploy-base
```

## 🔄 合约升级

```bash
# 升级 Sepolia 测试网合约
PROXY_ADDRESS=0x... make upgrade-sepolia

# 升级主网合约（会提示确认）
PROXY_ADDRESS=0x... make upgrade-mainnet
```

## 🔍 合约验证

```bash
# 验证 Sepolia 合约
CONTRACT_ADDRESS=0x... make verify-sepolia

# 验证主网合约
CONTRACT_ADDRESS=0x... make verify-mainnet
```

## 🔧 通用脚本工具

项目提供了 4 个通用脚本模版，可用于各种常见的区块链操作。每个脚本都有详细的文档说明。

### 脚本列表

| 脚本 | 功能 | 文档 |
|------|------|------|
| **1_DeployContract.s.sol** | 通用合约部署脚本 | [查看文档](./docs/1_DeployContract.md) |
| **2_SendETH.s.sol** | 发送 ETH 给指定地址 | [查看文档](./docs/2_SendETH.md) |
| **3_SendERC20.s.sol** | 发送 ERC20 代币 | [查看文档](./docs/3_SendERC20.md) |
| **4_CallContract.s.sol** | 调用任意合约方法 | [查看文档](./docs/4_CallContract.md) |

### 快速使用

```bash
# 1. 部署任意合约
# 修改 script/1_DeployContract.s.sol 中的合约代码
forge script script/1_DeployContract.s.sol:DeployContract --rpc-url sepolia --broadcast

# 2. 发送 ETH
RECIPIENT_ADDRESS=0x... AMOUNT_ETH=0.1 \
forge script script/2_SendETH.s.sol:SendETH --rpc-url sepolia --broadcast

# 3. 发送 ERC20 代币
TOKEN_ADDRESS=0x... RECIPIENT_ADDRESS=0x... AMOUNT=100 \
forge script script/3_SendERC20.s.sol:SendERC20 --rpc-url sepolia --broadcast

# 4. 调用合约方法
# 修改 script/4_CallContract.s.sol 中的调用逻辑
CONTRACT_ADDRESS=0x... \
forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia --broadcast
```

**📚 完整文档**: 查看 [docs/README.md](./docs/README.md) 了解详细使用说明和示例。

## 📖 可用命令

运行 `make help` 查看所有可用命令：

```bash
make help
```

### 常用命令

| 命令 | 说明 |
|------|------|
| `make format` | 🎨 一键格式化所有合约 |
| `make build` | 🔨 编译合约 |
| `make test` | 🧪 运行测试 |
| `make clean` | 🧹 清理构建产物 |
| `make deploy-sepolia` | 🚀 部署到 Sepolia |
| `make setup` | ⚙️ 初始化项目设置 |
| `make snapshot` | 📸 生成 Gas 快照 |
| `make coverage` | 📊 生成测试覆盖率报告 |

## 🔧 Foundry 工具

**Foundry** 是一个用 Rust 编写的快速、可移植和模块化的以太坊应用开发工具包。

Foundry 包含：

- **Forge**: 以太坊测试框架（类似 Truffle、Hardhat 和 DappTools）
- **Cast**: 与 EVM 智能合约交互、发送交易和获取链数据的瑞士军刀
- **Anvil**: 本地以太坊节点，类似 Ganache、Hardhat Network
- **Chisel**: 快速、实用、详细的 Solidity REPL

### 文档

https://book.getfoundry.sh/

### 基础命令

```shell
# 构建
forge build

# 测试
forge test

# 格式化
forge fmt

# Gas 快照
forge snapshot

# 本地节点
anvil

# 帮助
forge --help
anvil --help
cast --help
```

## 🌐 支持的网络

项目已预配置以下网络：

### 主网
- Ethereum Mainnet
- BSC (Binance Smart Chain)
- Polygon (Matic)
- Arbitrum
- Optimism
- Base
- Avalanche

### 测试网
- Sepolia (Ethereum)
- BSC Testnet
- Polygon Amoy
- Arbitrum Sepolia
- Optimism Sepolia
- Base Sepolia
- Avalanche Fuji

## 📝 合约功能

### ERC20 代币功能

- ✅ 标准 ERC20 功能（transfer, approve, transferFrom）
- ✅ 可暂停（Pausable）
- ✅ 可销毁（Burnable）
- ✅ 可铸造（Mintable，需要 MINTER_ROLE）
- ✅ EIP-2612 Permit 支持
- ✅ UUPS 可升级
- ✅ 基于角色的访问控制

### 角色权限

- `DEFAULT_ADMIN_ROLE`: 管理员，可以授予和撤销其他角色
- `PAUSER_ROLE`: 可以暂停和恢复代币转账
- `MINTER_ROLE`: 可以铸造新代币
- `UPGRADER_ROLE`: 可以升级合约实现

## 🔒 安全注意事项

1. ⚠️ **永远不要提交 `.env` 文件到 Git**
2. ⚠️ **主网部署前务必在测试网充分测试**
3. ⚠️ **确保私钥安全，使用硬件钱包进行主网操作**
4. ⚠️ **升级合约前务必备份当前实现地址**
5. ⚠️ **仔细审计角色分配，避免权限过度集中**

## 📄 许可证

MIT

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📞 联系方式

如有问题，请提交 Issue 或联系项目维护者。