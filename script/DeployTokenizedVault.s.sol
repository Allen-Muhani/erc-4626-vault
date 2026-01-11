// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {TokenizedVault} from "../src/TokenizedVault.sol";
import {Script} from "forge-std/Script.sol";
import {DeployMockErc20Asset} from "./DeployMockErc20Asset.s.sol";

contract DeployTokenizedVault is Script {
    function run() external returns (TokenizedVault) {
        DeployMockErc20Asset deployer = new DeployMockErc20Asset();
        address mockAsset = address(deployer.run());

        vm.startBroadcast();
        TokenizedVault vault = new TokenizedVault(
            mockAsset, // asset address
            500, // 5% fee in basis points
            "Tokenized Vault Ocean Token", // name
            "tvOCT" // symbol
        );
        vm.stopBroadcast();
        return vault;
    }
}
