// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Parity Multi-Sig Wallet Library (Vulnerable Version)
 * @notice This contract demonstrates the vulnerability that led to the $150M+ Parity wallet freeze
 * @dev November 6, 2017 - Historic Ethereum vulnerability
 *
 * VULNERABILITY: Unprotected initialization + delegatecall + selfdestruct
 *
 * ROOT CAUSE:
 * Parity used a library contract pattern where wallet proxies delegatecall to a shared
 * library contract (WalletLibrary). The library contract had an initialization function
 * initWallet() that was meant to be called via delegatecall from wallet proxies.
 *
 * However, the library contract itself could also be called directly (not via delegatecall),
 * and its initWallet() function was not protected. This meant anyone could:
 * 1. Call initWallet() directly on the library contract
 * 2. Become the owner of the library contract itself
 * 3. Call kill() to selfdestruct the library
 *
 * Once the library was destroyed, all wallet proxies that delegatecall to it became
 * permanently frozen, as they had no code to delegate to.
 *
 * ATTACK VECTOR:
 * 1. Attacker calls initWallet() directly on WalletLibrary contract
 * 2. Attacker becomes owner of the library (not intended behavior)
 * 3. Attacker calls kill() function
 * 4. Library contract self-destructs
 * 5. All 587 wallet proxies depending on this library are now frozen forever
 * 6. $150M+ in ETH and tokens permanently locked
 */

contract VulnerableParityWalletLibrary {
    // Owner mapping
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public required; // Number of signatures required

    // Initialization state
    bool public initialized;

    event OwnerAdded(address indexed owner);
    event WalletDestroyed(address indexed destroyer);

    /**
     * @notice Initialize the wallet with owners
     * @param _owners Array of owner addresses
     * @param _required Number of required signatures
     * @param _daylimit Daily withdrawal limit (unused in this example)
     *
     * CRITICAL VULNERABILITY:
     * This function lacks access control and can be called by anyone.
     * It was meant to be called via delegatecall from wallet proxies,
     * but it can also be called directly on the library contract.
     *
     * When called directly on the library (not via delegatecall),
     * the caller becomes the owner of the LIBRARY CONTRACT ITSELF,
     * not a wallet proxy. This allows them to destroy the library.
     */
    function initWallet(
        address[] memory _owners,
        uint256 _required,
        uint256 _daylimit
    ) public {
        // VULNERABILITY: No access control!
        // Should check: require(!initialized, "Already initialized");
        // But even that wouldn't fully protect the library contract

        // In the real Parity wallet, this check existed but wasn't sufficient
        // because initialized state was in the proxy's storage, not library's storage

        // Clear existing owners
        for (uint i = 0; i < owners.length; i++) {
            isOwner[owners[i]] = false;
        }
        delete owners;

        // Set new owners
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
     * @notice Destroy the contract (selfdestruct)
     * @param _to Address to send remaining funds to
     *
     * CRITICAL VULNERABILITY:
     * This function allows owners to destroy the contract.
     * Combined with the initWallet vulnerability, an attacker can:
     * 1. Call initWallet() to become owner
     * 2. Call kill() to destroy the library
     * 3. Break all 587 wallet proxies that depend on this library
     *
     * The function only checks if caller is an owner, but doesn't prevent
     * the library contract itself from being destroyed.
     */
    function kill(address payable _to) external {
        require(isOwner[msg.sender], "Not an owner");

        emit WalletDestroyed(msg.sender);

        // VULNERABILITY: Destroys the library contract!
        // All wallet proxies delegatecalling to this library will break
        selfdestruct(_to);
    }

    /**
     * @notice Example wallet function (simplified)
     * @dev All wallet proxies would delegatecall to functions like this
     */
    function execute(address to, uint256 value, bytes memory data) external {
        require(isOwner[msg.sender], "Not an owner");

        (bool success, ) = to.call{value: value}(data);
        require(success, "Execution failed");
    }
}

/**
 * Example Wallet Proxy (how real wallets used the library)
 */
contract ParityWalletProxy {
    // Library address (where all the logic lives)
    address public libraryAddress;

    constructor(address _library) {
        libraryAddress = _library;
    }

    /**
     * Fallback function - delegates all calls to the library
     * When the library is destroyed via selfdestruct, this breaks completely
     */
    fallback() external payable {
        address lib = libraryAddress;

        // Delegatecall to library
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

/**
 * REAL-WORLD IMPACT:
 * - $150M+ frozen permanently (not stolen, but locked forever)
 * - 587 wallet contracts affected
 * - Wallets included major organizations and ICO funds
 * - Some of the most prominent Ethereum projects lost access to treasuries
 * - Funds remain frozen to this day (cannot be recovered)
 *
 * FIX:
 * The fix required:
 * 1. Library contracts should not have initialization functions that can be called directly
 * 2. Library contracts should not have selfdestruct functions
 * 3. If using proxy pattern, clearly separate proxy storage from library logic
 * 4. Library contracts should use Solidity's 'library' keyword (not 'contract')
 * 5. Add access controls to ensure library cannot be initialized after deployment
 * 6. Consider using upgradeable proxy patterns (EIP-1967, etc.) with proper guards
 *
 * KEY LESSON:
 * The delegatecall proxy pattern is dangerous if not implemented correctly.
 * Library contracts should NEVER have state-changing functions that can be
 * called directly. The combination of unprotected initialization + selfdestruct
 * in a library contract was catastrophic.
 *
 * This bug was discovered by a user who accidentally triggered it, not by
 * a malicious attacker. They called initWallet() and kill() thinking they
 * were testing their own wallet, but actually destroyed the shared library.
 *
 * VULNERABLE LINES:
 * - Line 59-85: initWallet() lacks proper access control for library context
 * - Line 103-111: kill() allows destruction of library contract
 * - Line 110: selfdestruct() destroys library, breaking all dependent proxies
 */
