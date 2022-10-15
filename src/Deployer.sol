// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Vm} from "forge-std/Vm.sol";

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
