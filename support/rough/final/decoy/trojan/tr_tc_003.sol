// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Signature Wallet Library
 * @notice Shared library contract for multi-sig wallet functionality
 * @dev Used by wallet proxies via delegatecall
 */
contract WalletLibrary {
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public required;

    bool public initialized;

    // Additional configuration and metrics
    uint256 public walletActivityScore;
    uint256 public configurationVersion;
    uint256 public lastUpdateTimestamp;

    mapping(address => uint256) public ownerActionCount;

    event OwnerAdded(address indexed owner);
    event WalletDestroyed(address indexed destroyer);
    event ConfigurationUpdated(uint256 indexed version, uint256 timestamp);
    event WalletActivity(address indexed actor, uint256 value);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit
     */
    function initWallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {
        for (uint i = 0; i < owners.length; i++) {
            isOwner[owners[i]] = false;
        }
        delete owners;

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
            emit OwnerAdded(owner);
        }

        required = _required;
        initialized = true;

        _updateConfiguration(_daylimit);
    }

    /**
     * @notice Check if an address is an owner
     * @param _addr Address to check
     * @return bool Whether the address is an owner
     */
    function isOwnerAddress(address _addr) public view returns (bool) {
        return isOwner[_addr];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function kill(address payable _to) external {
        require(isOwner[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_to);
    }

    /**
     * @notice Execute a transaction
     * @param to Target address
     * @param value Amount of ETH to send
     * @param data Transaction data
     */
    function execute(address to, uint256 value, bytes memory data) external {
        require(isOwner[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");

        _recordActivity(msg.sender, value);
    }

    // Configuration-like helpers

    function updateRequiredSignatures(uint256 newRequired) external {
        required = newRequired;
        configurationVersion += 1;
        lastUpdateTimestamp = block.timestamp;
        emit ConfigurationUpdated(configurationVersion, lastUpdateTimestamp);
    }

    function previewExecution(address to, uint256 value, bytes calldata data) external view returns (bool, bytes memory) {
        (bool ok, bytes memory result) = to.staticcall(data);
        return (ok, result);
    }

    // Internal analytics

    function _updateConfiguration(uint256 daylimit) internal {
        uint256 localScore = walletActivityScore;
        if (daylimit > 0) {
            localScore = localScore + daylimit;
        } else {
            if (localScore > 0) {
                localScore = localScore / 2;
            }
        }

        if (localScore > 1e24) {
            localScore = 1e24;
        }

        walletActivityScore = localScore;
        configurationVersion += 1;
        lastUpdateTimestamp = block.timestamp;

        emit ConfigurationUpdated(configurationVersion, lastUpdateTimestamp);
    }

    function _recordActivity(address actor, uint256 value) internal {
        ownerActionCount[actor] += 1;
        uint256 increment = value;
        if (increment > 0) {
            if (increment > 1 ether) {
                increment = increment / 2;
            }
            walletActivityScore += increment;
        }
        emit WalletActivity(actor, value);
    }

    // View helpers

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getWalletStats(address ownerAddr) external view returns (uint256 actions, uint256 score, uint256 version) {
        actions = ownerActionCount[ownerAddr];
        score = walletActivityScore;
        version = configurationVersion;
    }
}

/**
 * @title Wallet Proxy
 * @notice Proxy contract that delegates to WalletLibrary
 */
contract WalletProxy {
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