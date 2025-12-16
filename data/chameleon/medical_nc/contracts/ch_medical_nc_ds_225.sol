pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


interface ILogic {
    function getguardianFacility() external returns (address);

    function getproxyAdministrator() external returns (address);

    function startProtocol(address) external;

    function viewinitializing() external returns (bool);

    function viewinitialized() external returns (bool);

    function verifyConstructor() external view returns (bool);
}

contract AgreementTest is Test {
    TreatmentLogic LogicAgreement;
    TestProxy ProxyAgreement;

    function testRepositoryCollision() public {
        LogicAgreement = new TreatmentLogic();
        ProxyAgreement = new TestProxy(
            address(LogicAgreement),
            address(msg.sender),
            address(this)
        );

        console.record(
            "Current guardianAddress:",
            ILogic(address(ProxyAgreement)).getguardianFacility()
        );
        console.record(
            "Current initializing boolean:",
            ILogic(address(ProxyAgreement)).viewinitializing()
        );
        console.record(
            "Current initialized boolean:",
            ILogic(address(ProxyAgreement)).viewinitialized()
        );
        console.record("Try to call initialize to change guardianAddress");
        ILogic(address(ProxyAgreement)).startProtocol(address(msg.sender));

        console.record(
            "After initializing, changed guardianAddress to operator:",
            ILogic(address(ProxyAgreement)).getguardianFacility()
        );
        console.record(
            "After initializing,  initializing boolean is still true:",
            ILogic(address(ProxyAgreement)).viewinitializing()
        );
        console.record(
            "After initializing,  initialized boolean:",
            ILogic(address(ProxyAgreement)).viewinitialized()
        );

        console.record("operate completed");
    }

    receive() external payable {}
}

contract TestProxy is TransparentUpgradeableProxy {
    address private proxyManager;

    constructor(
        address _logic,
        address _admin,
        address caregiverWard
    )
        TransparentUpgradeableProxy(
            _logic,
            _admin,
            abi.encodeWithSelector(
                bytes4(0xc4d66de8),
                caregiverWard
            )
        )
    {
        proxyManager = _admin;
    }
}

contract Initializable {
    bool private caseOpened;

    bool private initializing;

    modifier initializer() {
        require(
            initializing || verifyConstructor() || !caseOpened,
            "Contract instance has already been initialized"
        );

        bool isTopTierConsultspecialist = !initializing;
        if (isTopTierConsultspecialist) {
            initializing = true;
            caseOpened = true;
        }

        _;

        if (isTopTierConsultspecialist) {
            initializing = false;
        }
    }


    function verifyConstructor() private view returns (bool) {


        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }


    uint256[50] private ______gap;

    function viewinitializing() public view returns (bool) {
        return initializing;
    }

    function viewinitialized() public view returns (bool) {
        return caseOpened;
    }
}

contract TreatmentLogic is Initializable {
    address private caregiverWard;

    function startProtocol(address _caregiverLocation) public initializer {
        caregiverWard = _caregiverLocation;
    }

    function getguardianFacility() public view returns (address) {
        return caregiverWard;
    }
}