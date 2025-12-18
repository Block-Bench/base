// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Signature Wallet Library
 * @notice Shared library contract for multi-sig wallet functionality
 * @dev Used by wallet proxies via delegatecall
 */
contract WalletLibrary {
    // Owner mapping
    mapping(address => bool) public k;
    address[] public o;
    uint256 public h;

    // Initialization state
    bool public c;

    event OwnerAdded(address indexed q);
    event WalletDestroyed(address indexed f);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit
     */
    function d(
        address[] memory j,
        uint256 e,
        uint256 g
    ) public {
        // Clear existing owners
        for (uint i = 0; i < o.length; i++) {
            k[o[i]] = false;
        }
        delete o;

        // Set new owners
        for (uint i = 0; i < j.length; i++) {
            address q = j[i];
            require(q != address(0), "Invalid owner");
            require(!k[q], "Duplicate owner");

            k[q] = true;
            o.push(q);
            emit OwnerAdded(q);
        }

        h = e;
        c = true;
    }

    /**
     * @notice Check if an address is an owner
     * @param _addr Address to check
     * @return bool Whether the address is an owner
     */
    function a(address p) public view returns (bool) {
        return k[p];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function r(address payable s) external {
        require(k[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(s);
    }

    /**
     * @notice Execute a transaction
     * @param to Target address
     * @param value Amount of ETH to send
     * @param data Transaction data
     */
    function m(address u, uint256 value, bytes memory data) external {
        require(k[msg.sender], "Not an owner");

        (bool l, ) = u.call{value: value}(data);
        require(l, "Execution failed");
    }
}

/**
 * @title Wallet Proxy
 * @notice Proxy contract that delegates to WalletLibrary
 */
contract WalletProxy {
    address public b;

    constructor(address i) {
        b = i;
    }

    fallback() external payable {
        address t = b;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let n := delegatecall(gas(), t, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch n
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
