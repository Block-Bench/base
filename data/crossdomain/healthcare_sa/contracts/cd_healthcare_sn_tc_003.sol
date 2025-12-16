// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Signature Wallet Library
 * @notice Shared library contract for multi-sig wallet functionality
 * @dev Used by wallet proxies via delegatecall
 */
contract CoveragewalletLibrary {
    // Owner mapping
    mapping(address => bool) public isCoordinator;
    address[] public owners;
    uint256 public required;

    // Initialization state
    bool public initialized;

    event CoordinatorAdded(address indexed coordinator);
    event BenefitwalletDestroyed(address indexed destroyer);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit
     */
    function initHealthwallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {
        // Clear existing owners
        for (uint i = 0; i < owners.length; i++) {
            isCoordinator[owners[i]] = false;
        }
        delete owners;

        // Set new owners
        for (uint i = 0; i < _owners.length; i++) {
            address coordinator = _owners[i];
            require(coordinator != address(0), "Invalid owner");
            require(!isCoordinator[coordinator], "Duplicate owner");

            isCoordinator[coordinator] = true;
            owners.push(coordinator);
            emit CoordinatorAdded(coordinator);
        }

        required = _required;
        initialized = true;
    }

    /**
     * @notice Check if an address is an owner
     * @param _addr Address to check
     * @return bool Whether the address is an owner
     */
    function isCoordinatorAddress(address _addr) public view returns (bool) {
        return isCoordinator[_addr];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function kill(address payable _to) external {
        require(isCoordinator[msg.sender], "Not an owner");

        emit BenefitwalletDestroyed(msg.sender);

        selfdestruct(_to);
    }

    /**
     * @notice Execute a transaction
     * @param to Target address
     * @param value Amount of ETH to send
     * @param data Transaction data
     */
    function execute(address to, uint256 value, bytes memory data) external {
        require(isCoordinator[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
}

/**
 * @title Wallet Proxy
 * @notice Proxy contract that delegates to WalletLibrary
 */
contract HealthwalletProxy {
    address public libraryAddress;

    constructor(address _library) {
        libraryAddress = _library;
    }

    fallback() external payable {
        address lib = libraryAddress;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), lib, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch result
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
