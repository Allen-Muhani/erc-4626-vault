// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../mock/OceanToken.sol";

contract DeployMockErc20Asset is Script {
    function run() external returns (OceanToken) {
        vm.startBroadcast();
        OceanToken token = new OceanToken();
        vm.stopBroadcast();
        return token;
    }
}
