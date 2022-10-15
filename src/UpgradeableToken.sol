// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "oz-up/token/ERC20/ERC20Upgradeable.sol";
import "oz-up/access/OwnableUpgradeable.sol";
import "oz-up/proxy/utils/Initializable.sol";
import "oz-up/proxy/utils/UUPSUpgradeable.sol";

contract UpgradeableToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC20_init("MyToken", "MTK");
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}
}
