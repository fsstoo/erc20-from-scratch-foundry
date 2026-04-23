// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ERC20LikeToken} from "../../src/ERC20LikeToken.sol";
import {Handler} from "./Handler.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

contract ERC20InvariantTest is StdInvariant, Test {
    ERC20LikeToken token;
    Handler handler;

    address internal owner;
    address internal alice;
    address internal bob;
    address internal charlie;

    uint256 constant INITIAL_SUPPLY = 1_000_000 ether;

    function setUp() public {
        token = new ERC20LikeToken(INITIAL_SUPPLY, "First Token", "FTK");

        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");

        address[] memory _users = new address[](3);
        _users[0] = alice;
        _users[1] = bob;
        _users[2] = charlie;

        handler = new Handler(token, _users);

        // distribute tokens
        token.transfer(alice, INITIAL_SUPPLY / 3);
        token.transfer(bob, INITIAL_SUPPLY / 3);
        token.transfer(charlie, INITIAL_SUPPLY / 3);

        targetContract(address(handler));
    }

    /*//////////////////////////////////////////////////////////////
                                INVARIANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Total supply must follow mint/burn accounting
    function invariant_totalSupplyAccounting() public view {
        uint256 expected = INITIAL_SUPPLY + handler.totalMinted() - handler.totalBurned();

        assertEq(token.totalSupply(), expected);
    }

    /// @notice users balance can't exceeds total supply
    function invariant_balanceNeverExceedsTotalSupply() public view {
        address[3] memory users = [alice, bob, charlie];

        for (uint256 i = 0; i < users.length; i++) {
            assertLe(token.balanceOf(users[i]), token.totalSupply());
        }
    }

    /// @notice Zero address should never hold tokens (if your design forbids it)
    function invariant_zeroAddressHasNoBalance() public view {
        assertEq(token.balanceOf(address(0)), 0);
    }
}
