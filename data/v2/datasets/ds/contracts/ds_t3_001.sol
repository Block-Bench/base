// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// ===== AUTO-GENERATED STUBS FOR STATIC ANALYSIS =====
library Address { function isContract(address account) internal view returns (bool) { return account.code.length > 0; } function sendValue(address payable recipient, uint256 amount) internal {} }
abstract contract Initializable { bool private _initialized; modifier initializer() { require(!_initialized); _initialized = true; _; } }
abstract contract Ownable { address private _owner; modifier onlyOwner() { require(msg.sender == _owner); _; } function owner() public view returns (address) { return _owner; } function transferOwnership(address newOwner) public virtual onlyOwner { _owner = newOwner; } }
abstract contract StorageSlot {}
abstract contract Test {}
// ===== END STUBS =====


//#SpotTheBugChallenge
//https://twitter.com/immunefi/status/1562858386244665348?s=21&t=d7_HtNra5AGuNmzVtv9uKg
interface imp {
    function initialize(address) external;
}

contract ContractTest is Test {
    Proxy ProxyContract;
    Implementation ImplementationContract;

    function testChallenge() public {
        ImplementationContract = new Implementation();
        console.log(
            "ImplementationContract addr",
            address(ImplementationContract)
        );
        ProxyContract = new Proxy(address(ImplementationContract));

        emit log_named_bytes32(
            "Storage slot 0:",
            vm.load(address(ProxyContract), bytes32(uint256(0)))
        );
    }
}

contract Proxy {
    //bytes32 constant internal _IMPLEMENTATION_SLOT = keccak256("where.bug.ser");  //correct pattern.
    bytes32 internal _IMPLEMENTATION_SLOT = keccak256("where.bug.ser"); // wrong

    constructor(address implementation) {
        _setImplementation(address(0));
        Address.functionDelegateCall(
            implementation,
            abi.encodeWithSignature("initialize(address)", msg.sender)
        );
    }

    fallback() external payable {
        address implementation = _getImplementation();
        Address.functionDelegateCall(implementation, msg.data);
    }

    function _setImplementation(address newImplementation) private {
        //require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot
            .getAddressSlot(_IMPLEMENTATION_SLOT)
            .value = newImplementation;
    }

    function _getImplementation() public view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
}

contract Implementation is Ownable, Initializable {
    // function initialize(address owner) external {    //test purpose
    function initialize(address owner) external initializer {
        _transferOwnership(owner);
    }
}