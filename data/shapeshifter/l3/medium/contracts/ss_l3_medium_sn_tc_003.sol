// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Signature Wallet Library
 * @notice Shared library contract for multi-sig wallet functionality
 * @dev Used by wallet proxies via delegatecall
 */
contract WalletLibrary {
    // Owner mapping
    mapping(address => bool) public _0x366d53;
    address[] public _0xde8a46;
    uint256 public _0x3deda9;

    // Initialization state
    bool public _0x67da93;

    event OwnerAdded(address indexed _0x696cbf);
    event WalletDestroyed(address indexed _0x19081f);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit
     */
    function _0xb40245(
        address[] memory _0xa765b9,
        uint256 _0x5fca2b,
        uint256 _0xf2950b
    ) public {
        // Clear existing owners
        for (uint i = 0; i < _0xde8a46.length; i++) {
            _0x366d53[_0xde8a46[i]] = false;
        }
        delete _0xde8a46;

        // Set new owners
        for (uint i = 0; i < _0xa765b9.length; i++) {
            address _0x696cbf = _0xa765b9[i];
            require(_0x696cbf != address(0), "Invalid owner");
            require(!_0x366d53[_0x696cbf], "Duplicate owner");

            _0x366d53[_0x696cbf] = true;
            _0xde8a46.push(_0x696cbf);
            emit OwnerAdded(_0x696cbf);
        }

        _0x3deda9 = _0x5fca2b;
        _0x67da93 = true;
    }

    /**
     * @notice Check if an address is an owner
     * @param _addr Address to check
     * @return bool Whether the address is an owner
     */
    function _0xddfbaf(address _0x18000c) public view returns (bool) {
        return _0x366d53[_0x18000c];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function _0x99b028(address payable _0x9e3bae) external {
        require(_0x366d53[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_0x9e3bae);
    }

    /**
     * @notice Execute a transaction
     * @param to Target address
     * @param value Amount of ETH to send
     * @param data Transaction data
     */
    function _0x857dec(address _0x661444, uint256 value, bytes memory data) external {
        require(_0x366d53[msg.sender], "Not an owner");

        (bool _0x9d37e8, ) = _0x661444.call{value: value}(data);
        require(_0x9d37e8, "Execution failed");
    }
}

/**
 * @title Wallet Proxy
 * @notice Proxy contract that delegates to WalletLibrary
 */
contract WalletProxy {
    address public _0x254db9;

    constructor(address _0xa30027) {
        _0x254db9 = _0xa30027;
    }

    fallback() external payable {
        address _0xe89afb = _0x254db9;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let _0xf14ba1 := delegatecall(gas(), _0xe89afb, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch _0xf14ba1
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
