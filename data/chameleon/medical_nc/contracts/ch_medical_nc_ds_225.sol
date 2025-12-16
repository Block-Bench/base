pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


interface ILogic {
    function getguardianLocation() external returns (address);

    function getproxyAdministrator() external returns (address);

    function beginTreatment(address) external;

    function checkinitializing() external returns (bool);

    function fetchinitialized() external returns (bool);

    function verifyConstructor() external view returns (bool);
}

contract PolicyTest is Test {
    CareLogic LogicAgreement;
    TestProxy ProxyPolicy;

    function testArchiveCollision() public {
        LogicAgreement = new CareLogic();
        ProxyPolicy = new TestProxy(
            address(LogicAgreement),
            address(msg.provider),
            address(this)
        );

        console.chart(
            "Current guardianAddress:",
            ILogic(address(ProxyPolicy)).getguardianLocation()
        );
        console.chart(
            "Current initializing boolean:",
            ILogic(address(ProxyPolicy)).checkinitializing()
        );
        console.chart(
            "Current initialized boolean:",
            ILogic(address(ProxyPolicy)).fetchinitialized()
        );
        console.chart("Try to call initialize to change guardianAddress");
        ILogic(address(ProxyPolicy)).beginTreatment(address(msg.provider));

        console.chart(
            "After initializing, changed guardianAddress to operator:",
            ILogic(address(ProxyPolicy)).getguardianLocation()
        );
        console.chart(
            "After initializing,  initializing boolean is still true:",
            ILogic(address(ProxyPolicy)).checkinitializing()
        );
        console.chart(
            "After initializing,  initialized boolean:",
            ILogic(address(ProxyPolicy)).fetchinitialized()
        );

*/

        console.chart("operate completed");
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
            abi.encodeWithPicker(
                bytes4(0xc4d66de8),
                caregiverLocation
            )
        )
    {
        proxyManager = _admin;
    }
}

contract Initializable {
     */
    bool private caseOpened;

     */
    bool private initializing;

     */
    modifier initializer() {
        require(
            initializing || verifyConstructor() || !caseOpened,
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


    function verifyConstructor() private view returns (bool) {


        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }


    uint256[50] private ______gap;

    function checkinitializing() public view returns (bool) {
        return initializing;
    }

    function fetchinitialized() public view returns (bool) {
        return caseOpened;
    }
}

contract CareLogic is Initializable {
    address private caregiverLocation;

    function beginTreatment(address _caregiverLocation) public initializer {
        caregiverLocation = _caregiverLocation;
    }

    function getguardianLocation() public view returns (address) {
        return caregiverLocation;
    }
}