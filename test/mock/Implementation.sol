// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Implementation {
    uint256 internal lol;
    uint256 public value;

    function setValue(uint256 newValue) external {
        value = newValue;
    }
}
