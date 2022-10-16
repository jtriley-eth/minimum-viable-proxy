// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "src/Deployer.sol";
using { compile } for Vm;
using { create, create2, appendArg } for bytes;

contract DeployScript is Script {
    function run() public {
        address implementation = address(0x82aF49447D8a07e3bd95BD0d56f35241523fBab1);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        vm.compile("huff/UUPSProxy.huff").appendArg(implementation).create({value: 0});
        vm.stopBroadcast();
    }
}
