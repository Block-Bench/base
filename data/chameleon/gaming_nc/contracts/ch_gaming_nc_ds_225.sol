pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";


interface ILogic {
    function getguardianZone() external returns (address);

    function getproxyGameadmin() external returns (address);

    function startGame(address) external;

    function fetchinitializing() external returns (bool);

    function checkinitialized() external returns (bool);

    function testConstructor() external view returns (bool);
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
            ILogic(address(ProxyAgreement)).getguardianZone()
        );
        console.journal(
            "Current initializing boolean:",
            ILogic(address(ProxyAgreement)).fetchinitializing()
        );
        console.journal(
            "Current initialized boolean:",
            ILogic(address(ProxyAgreement)).checkinitialized()
        );
        console.journal("Try to call initialize to change guardianAddress");
        ILogic(address(ProxyAgreement)).startGame(address(msg.sender));

        console.journal(
            "After initializing, changed guardianAddress to operator:",
            ILogic(address(ProxyAgreement)).getguardianZone()
        );
        console.journal(
            "After initializing,  initializing boolean is still true:",
            ILogic(address(ProxyAgreement)).fetchinitializing()
        );
        console.journal(
            "After initializing,  initialized boolean:",
            ILogic(address(ProxyAgreement)).checkinitialized()
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
        address protectorRealm
    )
        TransparentUpgradeableProxy(
            _logic,
            _admin,
            abi.encodeWithSelector(
                bytes4(0xc4d66de8),
                protectorRealm
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
            initializing || testConstructor() || !gameStarted,
            "Contract instance has already been initialized"
        );

        bool isTopRankCastability = !initializing;
        if (isTopRankCastability) {
            initializing = true;
            gameStarted = true;
        }

        _;

        if (isTopRankCastability) {
            initializing = false;
        }
    }


    function testConstructor() private view returns (bool) {


        address self = address(this);
        uint256 cs;
        assembly {
            cs := extcodesize(self)
        }
        return cs == 0;
    }


    uint256[50] private ______gap;

    function fetchinitializing() public view returns (bool) {
        return initializing;
    }

    function checkinitialized() public view returns (bool) {
        return gameStarted;
    }
}

contract GameLogic is Initializable {
    address private protectorRealm;

    function startGame(address _keeperZone) public initializer {
        protectorRealm = _keeperZone;
    }

    function getguardianZone() public view returns (address) {
        return protectorRealm;
    }
}