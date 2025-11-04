# 1. 通用合约部署脚本

## 📝 功能说明

这是一个通用的合约部署脚本模版，可以用于部署任何 Solidity 合约。只需要简单修改合约名称和构造函数参数即可使用。

## 🎯 适用场景

- 部署新的智能合约
- 部署带构造函数参数的合约
- 部署可升级合约（UUPS/Transparent Proxy）
- 快速原型开发和测试

## 📋 使用步骤

### 1. 修改脚本

编辑 `script/1_DeployContract.s.sol` 文件：

```solidity
// 1. 导入你的合约
import {YourContract} from "../src/path/to/YourContract.sol";

// 2. 修改 deployContract() 函数
function deployContract() internal returns (address) {
    // 部署你的合约
    YourContract contract = new YourContract(/* 构造函数参数 */);
    return address(contract);
}
```

### 2. 配置环境变量

在 `.env` 文件中设置：

```bash
# 部署者私钥
PRIVATE_KEY=your_private_key_here

# 可选：合约参数（如果需要）
TOKEN_NAME=MyToken
TOKEN_SYMBOL=MTK
INITIAL_SUPPLY=1000000000000000000000000
```

### 3. 运行部署

```bash
# 部署到本地测试网
forge script script/1_DeployContract.s.sol:DeployContract --rpc-url localhost --broadcast

# 部署到 Sepolia 测试网
forge script script/1_DeployContract.s.sol:DeployContract --rpc-url sepolia --broadcast

# 部署并验证合约
forge script script/1_DeployContract.s.sol:DeployContract --rpc-url sepolia --broadcast --verify
```

## 💡 使用示例

### 示例 1: 部署简单的 ERC20 代币

```solidity
import {SimpleToken} from "../src/token/SimpleToken.sol";

function deployContract() internal returns (address) {
    SimpleToken token = new SimpleToken(
        "MyToken",           // 代币名称
        "MTK",              // 代币符号
        1000000 * 10**18    // 初始供应量
    );
    
    console2.log("Token deployed:", address(token));
    return address(token);
}
```

### 示例 2: 使用环境变量配置

```solidity
import {ConfigurableToken} from "../src/token/ConfigurableToken.sol";

function deployContract() internal returns (address) {
    // 从环境变量读取配置
    string memory name = vm.envString("TOKEN_NAME");
    string memory symbol = vm.envString("TOKEN_SYMBOL");
    uint256 supply = vm.envUint("INITIAL_SUPPLY");
    address owner = vm.envOr("OWNER_ADDRESS", msg.sender);
    
    ConfigurableToken token = new ConfigurableToken(name, symbol, supply, owner);
    return address(token);
}
```

### 示例 3: 部署可升级合约

```solidity
import {MyUpgradeableContract} from "../src/MyUpgradeableContract.sol";
import {ERC1967Proxy} from "../src/proxy/ERC1967Proxy.sol";

function deployContract() internal returns (address) {
    // 部署实现合约
    MyUpgradeableContract implementation = new MyUpgradeableContract();
    console2.log("Implementation:", address(implementation));
    
    // 编码初始化数据
    bytes memory initData = abi.encodeWithSelector(
        MyUpgradeableContract.initialize.selector,
        msg.sender,  // owner
        "MyToken",   // name
        "MTK"        // symbol
    );
    
    // 部署代理
    ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
    console2.log("Proxy:", address(proxy));
    
    return address(proxy);
}
```

## 🔍 部署后操作

部署完成后，脚本会：

1. **输出部署信息**到控制台
   ```
   ====================================
   Deployment Complete!
   ====================================
   Contract Address: 0x...
   Deployer: 0x...
   ====================================
   ```

2. **保存部署记录**到 `deployments/latest.txt`
   ```
   Contract deployed at: 0x...
   Deployer: 0x...
   Chain ID: 11155111
   Block Number: 12345678
   ```

3. **生成广播日志**到 `broadcast/` 目录（用于验证和重放）

## ⚙️ 高级配置

### 使用特定的私钥

```bash
# 方式1: 使用环境变量
PRIVATE_KEY=0x... forge script script/1_DeployContract.s.sol --rpc-url sepolia --broadcast

# 方式2: 使用命令行参数
forge script script/1_DeployContract.s.sol --rpc-url sepolia --private-key 0x... --broadcast

# 方式3: 使用硬件钱包（推荐生产环境）
forge script script/1_DeployContract.s.sol --rpc-url mainnet --ledger --broadcast
```

### 模拟部署（不实际发送交易）

```bash
# 只模拟，不广播
forge script script/1_DeployContract.s.sol --rpc-url sepolia

# 查看详细调用信息
forge script script/1_DeployContract.s.sol --rpc-url sepolia -vvvv
```

### Gas 优化

```bash
# 估算 Gas 费用
forge script script/1_DeployContract.s.sol --rpc-url sepolia --gas-estimate

# 指定 Gas 价格
forge script script/1_DeployContract.s.sol --rpc-url sepolia --with-gas-price 30gwei --broadcast
```

## 🔒 安全提示

1. ⚠️ **永远不要在代码中硬编码私钥**
2. ⚠️ **主网部署前在测试网充分测试**
3. ⚠️ **验证部署的合约地址和参数**
4. ⚠️ **保存好部署记录和交易哈希**
5. ⚠️ **使用硬件钱包进行主网部署**

## 📊 常见问题

### Q: 如何部署到多个网络？

```bash
# 脚本化部署到多个网络
for network in localhost sepolia mainnet; do
    echo "Deploying to $network..."
    forge script script/1_DeployContract.s.sol --rpc-url $network --broadcast
done
```

### Q: 如何重复使用相同的部署地址？

使用 `CREATE2` 进行确定性部署：

```solidity
bytes32 salt = keccak256("my_unique_salt");
YourContract contract = new YourContract{salt: salt}(/* params */);
```

### Q: 部署失败如何调试？

```bash
# 使用更详细的输出
forge script script/1_DeployContract.s.sol --rpc-url sepolia -vvvvv

# 检查 Gas 是否足够
cast balance <your_address> --rpc-url sepolia

# 检查 nonce
cast nonce <your_address> --rpc-url sepolia
```

## 📚 相关文档

- [Foundry Script 文档](https://book.getfoundry.sh/tutorials/solidity-scripting)
- [部署脚本最佳实践](https://book.getfoundry.sh/tutorials/best-practices)
- [CREATE2 部署](https://book.getfoundry.sh/tutorials/create2-tutorial)
