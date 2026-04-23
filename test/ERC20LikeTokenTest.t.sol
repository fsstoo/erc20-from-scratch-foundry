// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC20LikeToken} from "../src/ERC20LikeToken.sol";

contract ERC20LikeTokenTest is Test {
    ERC20LikeToken token;

    address internal owner;
    address internal alice;
    address internal bob;

    uint256 internal constant INITIAL_SUPPLY = 1_000_000 ether;
    uint256 internal constant AMOUNT = 100 ether;

    /*//////////////////////////////////////////////////////////////
                                SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        owner = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        token = new ERC20LikeToken(INITIAL_SUPPLY, "First Token", "FTK");
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    function testConstructor() public {
        assertEq(token.name(), "First Token");
        assertEq(token.symbol(), "FTK");
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.owner(), owner);
    }

    /*//////////////////////////////////////////////////////////////
                                TRANSFER
    //////////////////////////////////////////////////////////////*/

    function testTransfer() public {
        token.transfer(alice, AMOUNT);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - AMOUNT);
        assertEq(token.balanceOf(alice), AMOUNT);
    }

    function testTransferRevertsIfInsufficientBalance() public {
        vm.prank(bob);
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__InsufficientBalance.selector);
        token.transfer(alice, AMOUNT);
    }

    function testTransferRevertsToZeroAddress() public {
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__ZeroAddress.selector);
        token.transfer(address(0), AMOUNT);
    }

    function testTransferToSelf() public {
        token.transfer(owner, AMOUNT);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
    }

    function testFuzz_TransferRandomUsers(address to, uint256 amount) public {
        vm.assume(to != address(0));
        vm.assume(to != owner);

        amount = bound(amount, 0, INITIAL_SUPPLY);

        token.transfer(to, amount);

        assertEq(token.balanceOf(to), amount);
    }

    /*//////////////////////////////////////////////////////////////
                                APPROVE
    //////////////////////////////////////////////////////////////*/

    function testApprove() public {
        token.approve(alice, AMOUNT);
        assertEq(token.allowance(owner, alice), AMOUNT);
    }

    function testApproveRevertsZeroAddress() public {
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__ZeroAddress.selector);
        token.approve(address(0), AMOUNT);
    }

    function testIncreaseAllowance() public {
        token.approve(alice, AMOUNT);
        token.increaseAllowance(alice, AMOUNT);

        assertEq(token.allowance(owner, alice), 2 * AMOUNT);
    }

    function testDecreaseAllowance() public {
        token.approve(alice, AMOUNT);
        token.decreaseAllowance(alice, AMOUNT / 2);

        assertEq(token.allowance(owner, alice), AMOUNT / 2);
    }

    function testFuzz_ApproveOverwrite(uint256 amount1, uint256 amount2) public {
        token.approve(alice, amount1);
        token.approve(alice, amount2);

        assertEq(token.allowance(owner, alice), amount2);
    }

    function testFuzz_DecreaseAllowance(uint256 amount, uint256 decrease) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);
        decrease = bound(decrease, 0, amount);

        token.approve(alice, amount);
        token.decreaseAllowance(alice, decrease);

        assertEq(token.allowance(owner, alice), amount - decrease);
    }

    /*//////////////////////////////////////////////////////////////
                             TRANSFER FROM
    //////////////////////////////////////////////////////////////*/

    function testTransferFrom() public {
        token.approve(alice, AMOUNT);

        vm.prank(alice);
        token.transferFrom(owner, bob, AMOUNT);

        assertEq(token.balanceOf(bob), AMOUNT);
        assertEq(token.allowance(owner, alice), 0);
    }

    function testTransferFromRevertsIfInsufficientAllowance() public {
        token.approve(alice, AMOUNT / 2);

        vm.prank(alice);
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__InsufficientAllowance.selector);
        token.transferFrom(owner, bob, AMOUNT);
    }

    function testTransferFromRevertsIfFromZero() public {
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__ZeroAddress.selector);
        token.transferFrom(address(0), bob, AMOUNT);
    }

    function testTransferFromRevertsIfToZero() public {
        token.approve(alice, AMOUNT);

        vm.prank(alice);
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__ZeroAddress.selector);
        token.transferFrom(owner, address(0), AMOUNT);
    }

    function testFuzz_TransferFrom(uint256 amount, uint256 approvedAmount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);
        approvedAmount = bound(approvedAmount, amount, INITIAL_SUPPLY);

        token.approve(alice, approvedAmount);

        vm.prank(alice);
        token.transferFrom(owner, bob, amount);

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.allowance(owner, alice), approvedAmount - amount);
    }

    /*//////////////////////////////////////////////////////////////
                                  BURN
    //////////////////////////////////////////////////////////////*/

    function testBurn() public {
        token.burn(AMOUNT);

        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - AMOUNT);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - AMOUNT);
    }

    function testBurnRevertsIfInsufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__InsufficientBalance.selector);
        token.burn(AMOUNT);
    }

    function testFuzz_Burn(uint256 amount) public {
        amount = bound(amount, 0, INITIAL_SUPPLY);

        token.burn(amount);

        assertEq(token.totalSupply(), INITIAL_SUPPLY - amount);
    }

    /*//////////////////////////////////////////////////////////////
                                  MINT
    //////////////////////////////////////////////////////////////*/

    function testMintOnlyOwner() public {
        token.mint(alice, AMOUNT);
        assertEq(token.balanceOf(alice), AMOUNT);
    }

    function testMintRevertsIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(ERC20LikeToken.ERC20LikeToken__NotOwner.selector);
        token.mint(alice, AMOUNT);
    }

    function testFuzz_Mint(address to, uint256 amount) public {
        vm.assume(to != address(0));
        amount = bound(amount, 0, INITIAL_SUPPLY);

        token.mint(to, amount);

        assertEq(token.balanceOf(to), amount);
    }
}
