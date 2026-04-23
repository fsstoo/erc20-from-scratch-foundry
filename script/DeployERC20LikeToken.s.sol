// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ERC20LikeToken} from "../src/ERC20LikeToken.sol";

/**
 * @title DeployERC20LikeToken
 * @author FSTO
 * @notice Deploys ERC20LikeToken using Foundry scripting with keystore accounts.
 */

contract DeployERC20LikeToken is Script {
    function run() external returns (ERC20LikeToken) {
        vm.startBroadcast();

        ERC20LikeToken token = new ERC20LikeToken(
            1_000_000 ether, // initial supply - 1 million tokens (18 decimals)
            "First Token", // name
            "FTK" // symbol
        );

        vm.stopBroadcast();

        return token;
    }
}
