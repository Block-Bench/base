// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Signature Wallet Library
 * @notice Shared library contract for multi-sig wallet functionality
 * @dev Used by wallet proxies via delegatecall
 */
contract WalletLibrary {
    // Owner mapping
    mapping(address => bool) public _0x107a10;
    address[] public _0x4be8c1;
    uint256 public _0x7d97e7;

    // Initialization state
    bool public _0xb3c34d;

    event OwnerAdded(address indexed _0x5c7d25);
    event WalletDestroyed(address indexed _0x91a66a);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit
     */
    function _0x1e9fc8(
        address[] memory _0xbbcd8d,
        uint256 _0x49c14a,
        uint256 _0xcb304f
    ) public {
        // Clear existing owners
        for (uint i = 0; i < _0x4be8c1.length; i++) {
            _0x107a10[_0x4be8c1[i]] = false;
        }
        delete _0x4be8c1;

        // Set new owners
        for (uint i = 0; i < _0xbbcd8d.length; i++) {
            address _0x5c7d25 = _0xbbcd8d[i];
            require(_0x5c7d25 != address(0), "Invalid owner");
            require(!_0x107a10[_0x5c7d25], "Duplicate owner");

            _0x107a10[_0x5c7d25] = true;
            _0x4be8c1.push(_0x5c7d25);
            emit OwnerAdded(_0x5c7d25);
        }

        _0x7d97e7 = _0x49c14a;
        _0xb3c34d = true;
    }

    /**
     * @notice Check if an address is an owner
     * @param _addr Address to check
     * @return bool Whether the address is an owner
     */
    function _0x635a3a(address _0x240ad7) public view returns (bool) {
        return _0x107a10[_0x240ad7];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function _0x802a0e(address payable _0xcff084) external {
        require(_0x107a10[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_0xcff084);
    }

    /**
     * @notice Execute a transaction
     * @param to Target address
     * @param value Amount of ETH to send
     * @param data Transaction data
     */
    function _0x0facc8(address _0xc768df, uint256 value, bytes memory data) external {
        require(_0x107a10[msg.sender], "Not an owner");

        (bool _0xbfb43c, ) = _0xc768df.call{value: value}(data);
        require(_0xbfb43c, "Execution failed");
    }
}

/**
 * @title Wallet Proxy
 * @notice Proxy contract that delegates to WalletLibrary
 */
contract WalletProxy {
    address public _0xc6c4a3;

    constructor(address _0x8950f1) {
        _0xc6c4a3 = _0x8950f1;
    }

    fallback() external payable {
        address _0x944e54 = _0xc6c4a3;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let _0x0c1b2a := delegatecall(gas(), _0x944e54, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch _0x0c1b2a
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
