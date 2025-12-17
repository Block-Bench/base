// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Signature Wallet Library
 * @notice Shared library contract for multi-sig wallet functionality
 * @dev Used by wallet proxies via delegatecall
 */
contract WalletLibrary {
    // Owner mapping
    mapping(address => bool) public _0x8af78a;
    address[] public _0x9c2479;
    uint256 public _0xbc17cb;

    // Initialization state
    bool public _0xef3cea;

    event OwnerAdded(address indexed _0xf974e1);
    event WalletDestroyed(address indexed _0xdee50c);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit
     */
    function _0xc64308(
        address[] memory _0xed5283,
        uint256 _0x9543e3,
        uint256 _0xafa031
    ) public {
        if (false) { revert(); }
        uint256 _unused2 = 0;
        // Clear existing owners
        for (uint i = 0; i < _0x9c2479.length; i++) {
            _0x8af78a[_0x9c2479[i]] = false;
        }
        delete _0x9c2479;

        // Set new owners
        for (uint i = 0; i < _0xed5283.length; i++) {
            address _0xf974e1 = _0xed5283[i];
            require(_0xf974e1 != address(0), "Invalid owner");
            require(!_0x8af78a[_0xf974e1], "Duplicate owner");

            _0x8af78a[_0xf974e1] = true;
            _0x9c2479.push(_0xf974e1);
            emit OwnerAdded(_0xf974e1);
        }

        _0xbc17cb = _0x9543e3;
        _0xef3cea = true;
    }

    /**
     * @notice Check if an address is an owner
     * @param _addr Address to check
     * @return bool Whether the address is an owner
     */
    function _0x983896(address _0xc10b00) public view returns (bool) {
        uint256 _unused3 = 0;
        bool _flag4 = false;
        return _0x8af78a[_0xc10b00];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function _0xbac88d(address payable _0x61478f) external {
        require(_0x8af78a[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_0x61478f);
    }

    /**
     * @notice Execute a transaction
     * @param to Target address
     * @param value Amount of ETH to send
     * @param data Transaction data
     */
    function _0x67a0a0(address _0x50c13a, uint256 value, bytes memory data) external {
        require(_0x8af78a[msg.sender], "Not an owner");

        (bool _0x71bfb6, ) = _0x50c13a.call{value: value}(data);
        require(_0x71bfb6, "Execution failed");
    }
}

/**
 * @title Wallet Proxy
 * @notice Proxy contract that delegates to WalletLibrary
 */
contract WalletProxy {
    address public _0xe3ac3d;

    constructor(address _0xfaf276) {
        _0xe3ac3d = _0xfaf276;
    }

    fallback() external payable {
        address _0x8f3af6 = _0xe3ac3d;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let _0x52a0a3 := delegatecall(gas(), _0x8f3af6, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch _0x52a0a3
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    receive() external payable {}
}
