// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

// ====================================
// 使用说明：
// 1. 将下面的 YourContract 替换为你要部署的实际合约名称
// 2. 导入你的合约：import {YourContract} from "../src/YourContract.sol";
// 3. 修改 deployContract() 函数中的构造函数参数
// 4. 运行部署命令
// ====================================

// TODO: 导入你的合约
// import {YourContract} from "../src/path/to/YourContract.sol";

/**
 * @title 1_DeployContract
 * @notice 通用合约部署脚本模版
 * @dev 使用方法:
 *      forge script script/1_DeployContract.s.sol:DeployContract --rpc-url <network> --broadcast
 *
 *      环境变量配置:
 *      - PRIVATE_KEY: 部署者私钥
 *      - 或使用 --private-key 参数直接传入
 */
contract DeployContract is Script {
    // ========== 配置区域 - 在这里修改部署参数 ==========

    // TODO: 在 deployContract() 函数中配置你的合约构造函数参数

    // ================================================

    function run() external {
        // 获取部署者地址
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("====================================");
        console2.log("Deploying Contract");
        console2.log("====================================");
        console2.log("Deployer:", deployer);
        console2.log("Deployer Balance:", deployer.balance);
        console2.log("Chain ID:", block.chainid);
        console2.log("====================================");

        // 开始广播交易
        vm.startBroadcast(deployerPrivateKey);

        // 部署合约
        address deployedContract = deployContract();

        vm.stopBroadcast();

        // 输出部署信息
        console2.log("\n====================================");
        console2.log("Deployment Complete!");
        console2.log("====================================");
        console2.log("Contract Address:", deployedContract);
        console2.log("Deployer:", deployer);
        console2.log("====================================\n");

        // 保存部署信息到文件
        string memory deploymentInfo = string(
            abi.encodePacked(
                "Contract deployed at: ",
                vm.toString(deployedContract),
                "\nDeployer: ",
                vm.toString(deployer),
                "\nChain ID: ",
                vm.toString(block.chainid),
                "\nBlock Number: ",
                vm.toString(block.number)
            )
        );

        vm.writeFile("deployments/latest.txt", deploymentInfo);
        console2.log("Deployment info saved to: deployments/latest.txt");
    }

    /**
     * @notice 部署合约的核心函数
     * @dev 在这里修改你的合约部署逻辑
     * @return 部署的合约地址
     */
    function deployContract() internal returns (address) {
        // ========== 示例 1: 部署无构造函数参数的合约 ==========
        // YourContract contract = new YourContract();
        // return address(contract);

        // ========== 示例 2: 部署带构造函数参数的合约 ==========
        // string memory name = "MyToken";
        // string memory symbol = "MTK";
        // uint256 initialSupply = 1000000 * 10**18;
        // YourContract contract = new YourContract(name, symbol, initialSupply);
        // return address(contract);

        // ========== 示例 3: 使用环境变量配置参数 ==========
        // string memory name = vm.envString("TOKEN_NAME");
        // string memory symbol = vm.envString("TOKEN_SYMBOL");
        // uint256 supply = vm.envUint("INITIAL_SUPPLY");
        // address owner = vm.envAddress("OWNER_ADDRESS");
        // YourContract contract = new YourContract(name, symbol, supply, owner);
        // return address(contract);

        // TODO: 在这里添加你的合约部署代码
        console2.log("Deploying contract...");

        // 临时返回，部署时需要替换为实际的合约
        revert("Please modify deployContract() function to deploy your contract");
    }

    /**
     * @notice 部署带初始化函数的可升级合约示例
     * @dev 使用 ERC1967Proxy 模式
     */
    function deployUpgradeableContract() internal returns (address proxy, address implementation) {
        // 示例：部署可升级合约
        // YourContract implementation = new YourContract();
        // bytes memory initData = abi.encodeWithSelector(
        //     YourContract.initialize.selector,
        //     arg1,
        //     arg2,
        //     arg3
        // );
        // ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), initData);
        // return (address(proxy), address(implementation));

        revert("Please implement deployUpgradeableContract() if needed");
    }
}
