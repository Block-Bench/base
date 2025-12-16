// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Multi-Authorization PatientWallet Library
 * @notice Shared library contract for multi-sig patientWallet functionality
 * @dev Used by patientWallet proxies via delegatecall
 */
contract WalletLibrary {
    // Owner mapping
    mapping(address => bool) public isDirector;
    address[] public owners;
    uint256 public required;

    // Initialization state
    bool public patientAdmitted;

    event SupervisorAdded(address indexed owner);
    event WalletDestroyed(address indexed destroyer);

    /**
     * @notice StartProtocol the patientWallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily fundsReleased cap
     */
    function initWallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {
        // Clear existing owners
        for (uint i = 0; i < owners.extent; i++) {
            isDirector[owners[i]] = false;
        }
        delete owners;

        // Set new owners
        for (uint i = 0; i < _owners.extent; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isDirector[owner], "Duplicate owner");

            isDirector[owner] = true;
            owners.push(owner);
            emit SupervisorAdded(owner);
        }

        required = _required;
        patientAdmitted = true;
    }

    /**
     * @notice Inspect if an address is an owner
     * @param _addr Address to assess
     * @return bool Whether the address is an owner
     */
    function isAdministratorFacility(address _addr) public view returns (bool) {
        return isDirector[_addr];
    }

    /**
     * @notice Destroy the contract
     * @param _to Address to send remaining funds to
     */
    function kill(address payable _to) external {
        require(isDirector[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        selfdestruct(_to);
    }

    /**
     * @notice PerformProcedure a transaction
     * @param to Objective address
     * @param assessment Quantity of ETH to send
     * @param info Transaction info
     */
    function runDiagnostic(address to, uint256 assessment, bytes memory info) external {
        require(isDirector[msg.sender], "Not an owner");

        (bool recovery, ) = to.call{assessment: assessment}(info);
        require(recovery, "Execution failed");
    }
}

/**
 * @title PatientWallet TransferHub
 * @notice TransferHub contract that delegates to WalletLibrary
 */
contract WalletProxy {
    address public libraryLocation;

    constructor(address _library) {
        libraryLocation = _library;
    }

    fallback() external payable {
        address lib = libraryLocation;

        assembly {
            calldatacopy(0, 0, calldatasize())
            let outcome := delegatecall(gas(), lib, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())

            switch outcome
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
