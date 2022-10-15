// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "src/Deployer.sol";
import "test/mock/Implementation.sol";
import "test/mock/UUPSProxy.sol";

using { compile } for Vm;
using { create, create2, appendArg } for bytes;

bytes32 constant PROXY_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

contract CounterTest is Test {
    address impl;
    address proxy;

    function setUp() public {
        impl = address(new Implementation());
        proxy = vm.compile("huff/UUPSPRoxy.huff")
            .appendArg(impl)
            .create({value: 0});
    }

    function testSlot() public {
        assertEq(vm.load(proxy, PROXY_SLOT), bytes32(uint256(uint160(impl))));
    }

    function testDelegatecall() public {
        uint256 beforeSet = Implementation(proxy).value();

        Implementation(proxy).setValue(1);

        uint256 afterSet = Implementation(proxy).value();

        assertEq(beforeSet, 0);
        assertEq(afterSet, 1);
    }
}
