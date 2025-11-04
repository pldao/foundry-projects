// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";
import { Erc20 } from "../src/token/Erc20.sol";
import { ERC1967Proxy } from "../src/proxy/ERC1967Proxy.sol";

contract Erc20Test is Test {
    Erc20 public implementation;
    Erc20 public token;
    ERC1967Proxy public proxy;

    address public owner = address(1);
    address public pauser = address(2);
    address public minter = address(3);
    address public upgrader = address(4);
    address public user = address(5);

    string constant TOKEN_NAME = "Test Token";
    string constant TOKEN_SYMBOL = "TEST";
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 10 ** 18;

    function setUp() public {
        // Deploy implementation
        implementation = new Erc20();

        // Encode initialization data
        bytes memory initData = abi.encodeWithSelector(
            Erc20.initialize.selector, TOKEN_NAME, TOKEN_SYMBOL, owner, INITIAL_SUPPLY, owner, pauser, minter, upgrader
        );

        // Deploy proxy
        proxy = new ERC1967Proxy(address(implementation), initData);

        // Wrap proxy in token interface
        token = Erc20(address(proxy));
    }

    function testInitialization() public view {
        assertEq(token.name(), TOKEN_NAME);
        assertEq(token.symbol(), TOKEN_SYMBOL);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testRoles() public view {
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), owner));
        assertTrue(token.hasRole(token.PAUSER_ROLE(), pauser));
        assertTrue(token.hasRole(token.MINTER_ROLE(), minter));
        assertTrue(token.hasRole(token.UPGRADER_ROLE(), upgrader));
    }

    function testMint() public {
        uint256 mintAmount = 1000 * 10 ** 18;

        vm.prank(minter);
        token.mint(user, mintAmount);

        assertEq(token.balanceOf(user), mintAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }

    function testMintFailsWithoutRole() public {
        uint256 mintAmount = 1000 * 10 ** 18;

        vm.prank(user);
        vm.expectRevert();
        token.mint(user, mintAmount);
    }

    function testBurn() public {
        uint256 burnAmount = 1000 * 10 ** 18;

        vm.prank(owner);
        token.burn(burnAmount);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - burnAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
    }

    function testPause() public {
        vm.prank(pauser);
        token.pause();

        assertTrue(token.paused());

        // Transfers should fail when paused
        vm.prank(owner);
        vm.expectRevert();
        token.transfer(user, 100);
    }

    function testUnpause() public {
        // First pause
        vm.prank(pauser);
        token.pause();

        // Then unpause
        vm.prank(pauser);
        token.unpause();

        assertFalse(token.paused());

        // Transfers should work after unpause
        vm.prank(owner);
        token.transfer(user, 100);
        assertEq(token.balanceOf(user), 100);
    }

    function testPauseFailsWithoutRole() public {
        vm.prank(user);
        vm.expectRevert();
        token.pause();
    }

    function testTransfer() public {
        uint256 transferAmount = 1000 * 10 ** 18;

        vm.prank(owner);
        token.transfer(user, transferAmount);

        assertEq(token.balanceOf(user), transferAmount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(owner);
        token.approve(user, amount);

        assertEq(token.allowance(owner, user), amount);

        vm.prank(user);
        token.transferFrom(owner, user, amount);

        assertEq(token.balanceOf(user), amount);
        assertEq(token.allowance(owner, user), 0);
    }

    function testUpgrade() public {
        // Deploy new implementation
        Erc20 newImplementation = new Erc20();

        // Upgrade
        vm.prank(upgrader);
        token.upgradeToAndCall(address(newImplementation), "");

        // Verify state is preserved
        assertEq(token.name(), TOKEN_NAME);
        assertEq(token.symbol(), TOKEN_SYMBOL);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function testUpgradeFailsWithoutRole() public {
        Erc20 newImplementation = new Erc20();

        vm.prank(user);
        vm.expectRevert();
        token.upgradeToAndCall(address(newImplementation), "");
    }

    function testPermit() public {
        uint256 privateKey = 0xA11CE;
        address alice = vm.addr(privateKey);

        vm.prank(owner);
        token.transfer(alice, 1000 * 10 ** 18);

        uint256 amount = 100 * 10 ** 18;
        uint256 deadline = block.timestamp + 1 days;

        // Create permit signature
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                alice,
                user,
                amount,
                token.nonces(alice),
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        // Execute permit
        token.permit(alice, user, amount, deadline, v, r, s);

        assertEq(token.allowance(alice, user), amount);
    }
}
