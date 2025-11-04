# 4. 调用任意合约方法脚本

## 📝 功能说明

这是一个通用的合约调用脚本模版，可以用于调用任意合约的任意方法。支持只读函数、写入函数、payable 函数等各种调用场景。

## 🎯 适用场景

- 调用合约的 view/pure 函数（查询数据）
- 调用合约的写入函数（修改状态）
- 调用 payable 函数（发送 ETH）
- 批量调用多个函数
- 测试合约交互
- 自动化合约操作

## 📋 使用步骤

### 方式 1: 修改脚本调用（推荐）

#### 1. 配置环境变量

在 `.env` 文件中添加：

```bash
# 调用者私钥（写入操作必需）
PRIVATE_KEY=your_private_key_here

# 目标合约地址
CONTRACT_ADDRESS=0x1234567890123456789012345678901234567890

# 发送的 ETH 数量（可选，用于 payable 函数）
VALUE_ETH=0.1
```

#### 2. 修改脚本

编辑 `script/4_CallContract.s.sol`，在 `run()` 函数中取消注释要调用的函数：

```solidity
function run() external {
    address contractAddress = getContractAddress();
    
    // 选择要调用的函数
    callViewFunction(contractAddress);        // 只读函数
    // callWriteFunction(contractAddress);    // 写入函数
    // callPayableFunction(contractAddress);  // Payable 函数
}
```

#### 3. 运行脚本

```bash
# 调用只读函数（不需要 --broadcast）
forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia

# 调用写入函数（需要 --broadcast）
forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia --broadcast
```

### 方式 2: 使用 Cast 直接调用

对于简单调用，可以直接使用 `cast` 命令：

```bash
# 调用只读函数
cast call <CONTRACT> "functionName()" --rpc-url sepolia

# 调用写入函数
cast send <CONTRACT> "functionName()" --private-key <KEY> --rpc-url sepolia --broadcast
```

## 💡 使用示例

### 示例 1: 查询 ERC20 代币余额

```solidity
function callViewFunction(address contractAddress) public view {
    // 查询总供应量
    (bool success, bytes memory returnData) =
        contractAddress.staticcall(abi.encodeWithSignature("totalSupply()"));
    
    if (success) {
        uint256 totalSupply = abi.decode(returnData, (uint256));
        console2.log("Total Supply:", totalSupply);
    }
    
    // 查询指定地址余额
    address account = 0xYourAddress;
    (bool success2, bytes memory returnData2) =
        contractAddress.staticcall(abi.encodeWithSignature("balanceOf(address)", account));
    
    if (success2) {
        uint256 balance = abi.decode(returnData2, (uint256));
        console2.log("Balance:", balance);
    }
}
```

运行：
```bash
CONTRACT_ADDRESS=0xTokenAddress forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia
```

### 示例 2: 调用代币转账

```solidity
function callFunctionWithParameters(address contractAddress) public {
    uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
    
    address recipient = 0xRecipientAddress;
    uint256 amount = 100 * 10**18; // 100 代币
    
    vm.startBroadcast(callerPrivateKey);
    
    (bool success,) = contractAddress.call(
        abi.encodeWithSignature("transfer(address,uint256)", recipient, amount)
    );
    
    vm.stopBroadcast();
    
    require(success, "Transfer failed");
}
```

运行：
```bash
CONTRACT_ADDRESS=0xTokenAddress forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia --broadcast
```

### 示例 3: 调用 Payable 函数（发送 ETH）

```solidity
function callPayableFunction(address contractAddress) public {
    uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
    uint256 valueWei = 0.1 ether;
    
    vm.startBroadcast(callerPrivateKey);
    
    // 调用 deposit() 函数并发送 ETH
    (bool success,) = contractAddress.call{value: valueWei}(
        abi.encodeWithSignature("deposit()")
    );
    
    vm.stopBroadcast();
    
    require(success, "Deposit failed");
}
```

运行：
```bash
CONTRACT_ADDRESS=0xContractAddress VALUE_ETH=0.1 \
forge script script/4_CallContract.s.sol:CallContract --rpc-url sepolia --broadcast
```

### 示例 4: 批量调用多个函数

```solidity
function batchCall(address contractAddress) public {
    uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
    
    vm.startBroadcast(callerPrivateKey);
    
    // 1. 授权
    contractAddress.call(
        abi.encodeWithSignature("approve(address,uint256)", spender, amount)
    );
    
    // 2. 转账
    contractAddress.call(
        abi.encodeWithSignature("transfer(address,uint256)", recipient, amount)
    );
    
    // 3. 其他操作
    // ...
    
    vm.stopBroadcast();
}
```

### 示例 5: 使用接口调用（类型安全）

```solidity
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

function callUsingInterface(address contractAddress) public {
    uint256 callerPrivateKey = vm.envUint("PRIVATE_KEY");
    IERC20 token = IERC20(contractAddress);
    
    vm.startBroadcast(callerPrivateKey);
    
    // 类型安全的调用
    token.transfer(recipient, amount);
    token.approve(spender, amount);
    
    vm.stopBroadcast();
}
```

## 🔍 使用 Cast 命令调用

### 调用只读函数

```bash
# 1. 无参数函数
cast call <CONTRACT> "totalSupply()" --rpc-url sepolia

# 2. 带参数函数
cast call <CONTRACT> "balanceOf(address)" <ADDRESS> --rpc-url sepolia

# 3. 解码返回值
cast call <CONTRACT> "name()" --rpc-url sepolia | cast to-ascii

# 4. 多参数函数
cast call <CONTRACT> "allowance(address,address)" <OWNER> <SPENDER> --rpc-url sepolia
```

### 调用写入函数

```bash
# 1. 基本写入
cast send <CONTRACT> "transfer(address,uint256)" <TO> <AMOUNT> \
    --private-key <KEY> --rpc-url sepolia

# 2. 带 ETH 的调用
cast send <CONTRACT> "deposit()" --value 0.1ether \
    --private-key <KEY> --rpc-url sepolia

# 3. 设置 Gas 价格
cast send <CONTRACT> "functionName()" \
    --gas-price 30gwei --private-key <KEY> --rpc-url sepolia

# 4. 估算 Gas
cast estimate <CONTRACT> "functionName()" --rpc-url sepolia
```

## ⚙️ 高级用法

### 1. 动态编码函数调用

```solidity
// 方式 1: 使用 abi.encodeWithSignature
bytes memory callData = abi.encodeWithSignature(
    "transfer(address,uint256)",
    recipient,
    amount
);

// 方式 2: 使用 abi.encodeWithSelector
bytes4 selector = bytes4(keccak256("transfer(address,uint256)"));
bytes memory callData = abi.encodeWithSelector(
    selector,
    recipient,
    amount
);

// 方式 3: 使用接口
IERC20(token).transfer(recipient, amount);
```

### 2. 解析不同类型的返回值

```solidity
// uint256 返回值
(bool success, bytes memory data) = contract.call(callData);
uint256 result = abi.decode(data, (uint256));

// address 返回值
address resultAddress = abi.decode(data, (address));

// bool 返回值
bool resultBool = abi.decode(data, (bool));

// string 返回值
string memory resultString = abi.decode(data, (string));

// 多个返回值
(uint256 a, address b, bool c) = abi.decode(data, (uint256, address, bool));

// 数组返回值
address[] memory addresses = abi.decode(data, (address[]));
```

### 3. 错误处理

```solidity
(bool success, bytes memory returnData) = contractAddress.call(callData);

if (!success) {
    // 解析 revert 消息
    if (returnData.length > 0) {
        // 尝试解码错误消息
        string memory errorMessage = abi.decode(returnData, (string));
        console2.log("Error:", errorMessage);
    } else {
        console2.log("Call failed without error message");
    }
    revert("Function call failed");
}
```

### 4. 使用环境变量配置参数

```bash
# .env 文件
CONTRACT_ADDRESS=0x...
FUNCTION_NAME=transfer
PARAM_ADDRESS=0x...
PARAM_AMOUNT=100000000000000000000
```

```solidity
function dynamicCall() public {
    address contractAddress = vm.envAddress("CONTRACT_ADDRESS");
    string memory functionName = vm.envString("FUNCTION_NAME");
    address paramAddress = vm.envAddress("PARAM_ADDRESS");
    uint256 paramAmount = vm.envUint("PARAM_AMOUNT");
    
    bytes memory callData = abi.encodeWithSignature(
        string(abi.encodePacked(functionName, "(address,uint256)")),
        paramAddress,
        paramAmount
    );
    
    // 执行调用
    // ...
}
```

## 📊 常用合约调用模式

### ERC20 代币操作

```bash
# 查询余额
cast call <TOKEN> "balanceOf(address)" <ADDRESS> --rpc-url sepolia

# 转账
cast send <TOKEN> "transfer(address,uint256)" <TO> <AMOUNT> \
    --private-key <KEY> --rpc-url sepolia

# 授权
cast send <TOKEN> "approve(address,uint256)" <SPENDER> <AMOUNT> \
    --private-key <KEY> --rpc-url sepolia

# 查询授权额度
cast call <TOKEN> "allowance(address,address)" <OWNER> <SPENDER> --rpc-url sepolia
```

### NFT (ERC721) 操作

```bash
# 查询所有者
cast call <NFT> "ownerOf(uint256)" <TOKEN_ID> --rpc-url sepolia

# 转移 NFT
cast send <NFT> "transferFrom(address,address,uint256)" <FROM> <TO> <TOKEN_ID> \
    --private-key <KEY> --rpc-url sepolia

# 授权
cast send <NFT> "approve(address,uint256)" <SPENDER> <TOKEN_ID> \
    --private-key <KEY> --rpc-url sepolia

# 查询余额
cast call <NFT> "balanceOf(address)" <ADDRESS> --rpc-url sepolia
```

### 多签钱包操作

```bash
# 提交交易
cast send <MULTISIG> "submitTransaction(address,uint256,bytes)" <TO> <VALUE> <DATA> \
    --private-key <KEY> --rpc-url sepolia

# 确认交易
cast send <MULTISIG> "confirmTransaction(uint256)" <TX_ID> \
    --private-key <KEY> --rpc-url sepolia

# 执行交易
cast send <MULTISIG> "executeTransaction(uint256)" <TX_ID> \
    --private-key <KEY> --rpc-url sepolia
```

### Uniswap/DEX 交互

```bash
# 查询价格
cast call <ROUTER> "getAmountsOut(uint256,address[])" <AMOUNT_IN> "[<TOKEN_A>,<TOKEN_B>]" \
    --rpc-url mainnet

# 交换代币
cast send <ROUTER> "swapExactTokensForTokens(uint256,uint256,address[],address,uint256)" \
    <AMOUNT_IN> <AMOUNT_OUT_MIN> "[<TOKEN_A>,<TOKEN_B>]" <TO> <DEADLINE> \
    --private-key <KEY> --rpc-url mainnet
```

## 🔒 安全提示

1. ⚠️ **验证合约地址**：确保调用的是正确的合约
2. ⚠️ **检查函数签名**：确认函数名称和参数类型正确
3. ⚠️ **测试网先测试**：主网操作前在测试网充分测试
4. ⚠️ **Gas 限制**：注意函数的 Gas 消耗
5. ⚠️ **权限检查**：确认调用者有足够权限
6. ⚠️ **重入攻击**：调用外部合约时注意重入风险
7. ⚠️ **返回值验证**：检查函数调用是否成功

## 🐛 常见问题

### Q: 调用失败，没有错误消息

**A:** 检查以下几点：

```bash
# 1. 验证函数签名
cast sig "transfer(address,uint256)"

# 2. 检查合约代码
cast code <CONTRACT> --rpc-url sepolia

# 3. 估算 Gas
cast estimate <CONTRACT> "functionName()" --rpc-url sepolia

# 4. 使用详细输出
forge script ... -vvvv
```

### Q: 如何调用重载的函数？

**A:** 明确指定完整的函数签名：

```solidity
// 如果有多个 transfer 函数
// transfer(address)
// transfer(address,uint256)

// 调用第一个
abi.encodeWithSignature("transfer(address)", recipient)

// 调用第二个
abi.encodeWithSignature("transfer(address,uint256)", recipient, amount)
```

### Q: 如何传递结构体参数？

**A:** 将结构体展开为基本类型：

```solidity
// 结构体定义
struct User {
    address addr;
    uint256 amount;
    bool active;
}

// 调用时展开
contractAddress.call(
    abi.encodeWithSignature(
        "updateUser(address,uint256,bool)",
        userAddr,
        userAmount,
        userActive
    )
);
```

### Q: 如何处理动态数组参数？

**A:** 示例：

```solidity
address[] memory addresses = new address[](3);
addresses[0] = 0x...;
addresses[1] = 0x...;
addresses[2] = 0x...;

contractAddress.call(
    abi.encodeWithSignature("batchProcess(address[])", addresses)
);
```

### Q: 如何查看合约的所有函数？

**A:** 使用以下方法：

```bash
# 1. 在 Etherscan 查看已验证的合约

# 2. 使用 cast 获取 ABI
cast interface <CONTRACT> --rpc-url sepolia

# 3. 使用 4byte.directory 查询函数签名
# https://www.4byte.directory/
```

## 📈 性能优化

### 批量调用优化

使用 Multicall 合约批量查询：

```solidity
// 使用 Multicall3 批量调用
interface IMulticall3 {
    struct Call {
        address target;
        bytes callData;
    }
    
    function aggregate(Call[] calldata calls)
        external
        returns (uint256 blockNumber, bytes[] memory returnData);
}
```

### Gas 优化建议

```solidity
// 1. 使用 unchecked 节省 Gas
unchecked {
    balance += amount;
}

// 2. 缓存数组长度
uint256 length = array.length;
for (uint256 i = 0; i < length; i++) {
    // ...
}

// 3. 使用 calldata 而不是 memory
function process(address[] calldata addresses) external {
    // ...
}
```

## 📚 相关文档

- [Solidity ABI 编码](https://docs.soliditylang.org/en/latest/abi-spec.html)
- [Foundry Cast 文档](https://book.getfoundry.sh/reference/cast/)
- [低级调用文档](https://docs.soliditylang.org/en/latest/units-and-global-variables.html#members-of-address-types)
- [4byte Directory](https://www.4byte.directory/) - 函数签名查询
