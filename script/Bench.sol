// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "oz/proxy/ERC1967/ERC1967Proxy.sol";

import "src/Deployer.sol";
import "src/UpgradeableToken.sol";
import "test/mock/UUPSProxy.sol";

using { compile } for Vm;
using { create, create2, appendArg } for bytes;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address,address) external view returns (uint256);

    function transfer(address,uint256) external returns (bool);
    function transferFrom(address,address,uint256) external returns (bool);
    function approve(address,uint256) external returns (bool);
}

address constant alice = address(0x10);
address constant bob = address(0x11);
uint256 constant amount = 0;

contract BenchScript is Script {
    UpgradeableToken huffProxy;
    UpgradeableToken ozProxy;
    address implementation;

    function run() public {
        // DEPLOY STUFF
        implementation = address(new UpgradeableToken());

        huffProxy = UpgradeableToken(
            vm.compile("huff/UUPSProxy.huff").appendArg(implementation).create({value: 0})
        );

        ozProxy = UpgradeableToken(address(new ERC1967Proxy(implementation, new bytes(0))));

        // INITIALIZE
        huffProxy.initialize();
        ozProxy.initialize();

        // WARM THE ADDRESS (requiring thing to shut the compiler up)
        (bool success, ) = implementation.staticcall(new bytes(0));
        require(!success);

        // SET UP THE BENCH TESTS
        bytes[] memory staticcalls = new bytes[](6);
        staticcalls[0] = abi.encodeCall(IERC20.name, ());
        staticcalls[1] = abi.encodeCall(IERC20.symbol, ());
        staticcalls[2] = abi.encodeCall(IERC20.decimals, ());
        staticcalls[3] = abi.encodeCall(IERC20.totalSupply, ());
        staticcalls[4] = abi.encodeCall(IERC20.balanceOf, (alice));
        staticcalls[5] = abi.encodeCall(IERC20.allowance, (alice, bob));

        bytes[] memory calls = new bytes[](3);
        calls[0] = abi.encodeCall(IERC20.transfer, (bob, amount));
        calls[1] = abi.encodeCall(IERC20.transferFrom, (alice, bob, amount));
        calls[2] = abi.encodeCall(IERC20.approve, (bob, amount));

        uint256[] memory huffgas = new uint256[](9);
        uint256[] memory ozgas = new uint256[](9);

        // RUN TESTS
        for (uint256 i; i < staticcalls.length; ++i) {
            (huffgas[i], ozgas[i]) = _makeStaticcall(huffProxy, ozProxy, staticcalls[i]);
            (huffgas[i], ozgas[i]) = _makeStaticcall(huffProxy, ozProxy, staticcalls[i]);
        }

        for (uint256 i; i < calls.length; ++i) {
            uint256 gasIndex = i + 6;
            (huffgas[gasIndex], ozgas[gasIndex]) = _makeCall(huffProxy, ozProxy, calls[i]);
            (huffgas[gasIndex], ozgas[gasIndex]) = _makeCall(huffProxy, ozProxy, calls[i]);
        }

        // PRINT BENCH
        for (uint256 i; i < huffgas.length; ++i) {
            console.log("---");
            console.log(huffgas[i]);
            console.log(ozgas[i]);
        }

        console.log("--- BYTECODE SIZE ---");
        console.log(address(huffProxy).code.length);
        console.log(address(ozProxy).code.length);


        console.log("--- BYTECODE ---");
        console.logBytes(address(huffProxy).code);
        console.logBytes(address(ozProxy).code);
    }

    function _makeCall(
        UpgradeableToken huff,
        UpgradeableToken oz,
        bytes memory data
    ) internal returns (uint256 huffgas, uint256 ozgas) {
        assembly {
            let argoffset := add(data, 0x20)
            let argsize := mload(data)

            huffgas := gas()
            pop(call(gas(), huff, 0, argoffset, argsize, 0, 0))
            huffgas := sub(huffgas, gas())

            ozgas := gas()
            pop(call(gas(), oz, 0, argoffset, argsize, 0, 0))
            ozgas := sub(ozgas, gas())
        }
    }

    function _makeStaticcall(
        UpgradeableToken huff,
        UpgradeableToken oz,
        bytes memory data
    ) internal returns (uint256 huffgas, uint256 ozgas) {
        assembly {
            let argoffset := add(data, 0x20)
            let argsize := mload(data)

            huffgas := gas()
            pop(staticcall(gas(), huff, argoffset, argsize, 0, 0))
            huffgas := sub(huffgas, gas())

            ozgas := gas()
            pop(call(gas(), oz, 0, argoffset, argsize, 0, 0))
            ozgas := sub(ozgas, gas())
        }
    }
}
