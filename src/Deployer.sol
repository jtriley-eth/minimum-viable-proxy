// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Vm} from "forge-std/Vm.sol";

using { appendArg, create } for bytes;

bytes constant compiled = hex"60208038033d393d517f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc55603e8060343d393df3363d3d373d3d363d7f360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc545af43d6000803e610039573d6000fd5b3d6000f3";

function useMvp(address implementation) returns (address) {
    return compiled.appendArg(implementation).create({value: 0});
}

function compile(Vm vm, string memory path) returns (bytes memory) {
    string[] memory cmd = new string[](3);
    cmd[0] = "huffc";
    cmd[1] = "--bytecode";
    cmd[2] = path;
    return vm.ffi(cmd);
}

error DeploymentFailure(bytes bytecode);

function create(bytes memory bytecode, uint256 value) returns (address deployedAddress) {
    assembly {
        deployedAddress := create(value, add(bytecode, 0x20), mload(bytecode))
    }

    if (deployedAddress == address(0)) revert DeploymentFailure(bytecode);
}

function create2(
    bytes memory bytecode,
    uint256 value,
    bytes32 salt
) returns (address deployedAddress) {
    assembly {
        deployedAddress := create2(value, add(bytecode, 0x20), mload(bytecode), salt)
    }

    if (deployedAddress == address(0)) revert DeploymentFailure(bytecode);
}

function appendArg(bytes memory bytecode, address arg) pure returns (bytes memory) {
    return bytes.concat(bytecode, abi.encode(arg));
}
