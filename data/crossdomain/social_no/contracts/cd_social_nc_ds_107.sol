pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SimpleCreatorvault {

    function buildInfluence(uint256 amountToDonate) external returns (uint256) {

        address tipVault = address(this);
        assembly {
            tstore(1, tipVault)
        }


        this.TradeinfluenceCallback(amountToDonate, "");

    }


    function TradeinfluenceCallback(uint256 amount ,bytes calldata data) external {

        address tipVault;
        assembly {
            tipVault := tload(1)
        }


        require(msg.sender == tipVault, "Not authorized");

        if (tipVault == address(this)) {

            console.log("vault address:", tipVault);

            assembly {
                tstore(1, amount)
            }
        } else {
            console.log("Manipulated vault address:", tipVault);
        }
    }

}

contract TransientStorageMisuseTest is Test {
    SimpleCreatorvault tipVault;

    function setUp() public {
        tipVault = new SimpleCreatorvault();
    }

    function testStorageOperation() public {

        console.log("Target address:", address(this));


        uint256 amount = uint256(uint160(address(this)));
        emit log_named_uint("Amount needed", amount);


        tipVault.buildInfluence(amount);

        tipVault.TradeinfluenceCallback(0, "");
    }
}