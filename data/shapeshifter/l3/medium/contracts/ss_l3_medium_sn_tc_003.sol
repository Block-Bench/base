// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Signature Wallet Library
 * @notice Shared library contract for multi-sig wallet functionality
 * @dev Used by wallet proxies via delegatecall
 */
contract WalletLibrary {
    // Owner mapping
    mapping(address => bool) public _0xb50a23;
    address[] public _0x388b24;
    uint256 public _0x137b25;

    // Initialization state
    bool public _0xa751e1;

    event OwnerAdded(address indexed _0x58c441);
    event WalletDestroyed(address indexed _0xd4ec78);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit
     */
    function _0xdf20cf(
        address[] memory _0xf69692,
        uint256 _0x441b96,
        uint256 _0x7c1d4e
    ) public {
        // Clear existing owners
        for (uint i = 0; i < _0x388b24.length; i++) {
            _0xb50a23[_0x388b24[i]] = false;
        }
        delete _0x388b24;

        // Set new owners
        for (uint i = 0; i < _0xf69692.length; i++) {
            address _0x58c441 = _0xf69692[i];
            require(_0x58c441 != address(0), "Invalid owner");
            require(!_0xb50a23[_0x58c441], "Duplicate owner");

            _0xb50a23[_0x58c441] = true;
            _0x388b24.push(_0x58c441);
            emit OwnerAdded(_0x58c441);
        }

        _0x137b25 = _0x441b96;
        _0xa751e1 = true;
    }

    /**
     * @notice Check if an address is an owner
     * @param _addr Address to check
     * @return bool Whether the address is an owner
     */
    function _0xe638a1(address _0x791ce4) public view returns (bool) {
        return _0xb50a23[_0x791ce4];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function _0x91e149(address payable _0x985172) external {
        require(_0xb50a23[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_0x985172);
    }

    /**
     * @notice Execute a transaction
     * @param to Target address
     * @param value Amount of ETH to send
     * @param data Transaction data
     */
    function _0x73ad70(address _0xfd573b, uint256 value, bytes memory data) external {
        require(_0xb50a23[msg.sender], "Not an owner");

        (bool _0x9b0c13, ) = _0xfd573b.call{value: value}(data);
        require(_0x9b0c13, "Execution failed");
    }
}

/**
 * @title Wallet Proxy
 * @notice Proxy contract that delegates to WalletLibrary
 */
contract WalletProxy {
    address public _0x66d434;

    constructor(address _0xd1bfba) {
        _0x66d434 = _0xd1bfba;
    }

    fallback() external payable {
        address _0x558b64 = _0x66d434;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let _0xe40993 := delegatecall(gas(), _0x558b64, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch _0xe40993
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
