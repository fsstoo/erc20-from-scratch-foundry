// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20LikeToken} from "../../src/ERC20LikeToken.sol";
import {Test} from "forge-std/Test.sol";

contract Handler is Test {
    ERC20LikeToken public token;

    address public owner;
    address[] public users;

    uint256 public totalMinted;
    uint256 public totalBurned;

    constructor(ERC20LikeToken _token, address[] memory _users) {
        token = _token;
        users = _users;
        owner = msg.sender;
    }

    function randomUser(uint256 seed) internal view returns (address) {
        if (seed % 10 == 0) return address(0);
        return users[seed % users.length];
    }

    function boundAmount(uint256 amount) internal view returns (uint256) {
        return bound(amount, 1, token.totalSupply());
    }

    /*//////////////////////////////////////////////////////////////
                                ACTIONS
    //////////////////////////////////////////////////////////////*/

    function transfer(uint256 fromSeed, uint256 toSeed, uint256 amount) public {
        address from = randomUser(fromSeed);
        address to = randomUser(toSeed);

        amount = boundAmount(amount);

        vm.prank(from);
        try token.transfer(to, amount) {} catch {}
    }

    function approve(uint256 ownerSeed, uint256 spenderSeed, uint256 amount) public {
        address _owner = randomUser(ownerSeed);
        address spender = randomUser(spenderSeed);

        amount = boundAmount(amount);

        vm.prank(_owner);
        try token.approve(spender, amount) {} catch {}
    }

    function transferFrom(uint256 spenderSeed, uint256 fromSeed, uint256 toSeed, uint256 amount) public {
        address spender = randomUser(spenderSeed);
        address from = randomUser(fromSeed);
        address to = randomUser(toSeed);

        amount = boundAmount(amount);

        vm.prank(spender);
        try token.transferFrom(from, to, amount) {} catch {}
    }

    function burn(uint256 userSeed, uint256 amount) public {
        address user = randomUser(userSeed);

        amount = boundAmount(amount);

        vm.prank(user);
        try token.burn(amount) {
            totalBurned += amount;
        } catch {}
    }

    function mint(uint256 toSeed, uint256 amount) public {
        address to = randomUser(toSeed);

        vm.prank(owner);
        try token.mint(to, amount) {
            totalMinted += amount;
        } catch {}
    }
}
