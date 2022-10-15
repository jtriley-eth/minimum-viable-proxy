// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz/proxy/ERC1967/ERC1967Proxy.sol";
import "oz/access/Ownable.sol";

contract UUPSProxy is ERC1967Proxy, Ownable {
    constructor(address implementation) ERC1967Proxy(implementation, new bytes(0)) {}

    function setImplementation(address newImplementation) external {
        assembly {
            // compiler was yelling at me about the internal func, so we do it in asm
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }
}
