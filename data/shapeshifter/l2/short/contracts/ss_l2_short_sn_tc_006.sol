// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Cross-Chain Bridge
 * @notice Processes withdrawals from sidechain to mainnet using multi-sig validation
 * @dev Validators sign withdrawal requests to authorize token transfers
 */
contract CrossChainBridge {
    // Validator addresses
    address[] public t;
    mapping(address => bool) public r;

    uint256 public c = 5;
    uint256 public j;

    // Track processed withdrawals to prevent replay
    mapping(uint256 => bool) public a;

    // Supported tokens
    mapping(address => bool) public h;

    event WithdrawalProcessed(
        uint256 indexed n,
        address indexed ai,
        address indexed ag,
        uint256 ac
    );

    constructor(address[] memory o) {
        require(
            o.length >= c,
            "Not enough validators"
        );

        for (uint256 i = 0; i < o.length; i++) {
            address u = o[i];
            require(u != address(0), "Invalid validator");
            require(!r[u], "Duplicate validator");

            t.push(u);
            r[u] = true;
        }

        j = o.length;
    }

    /**
     * @notice Process a withdrawal request
     * @param _withdrawalId Unique ID for this withdrawal
     * @param _user Address to receive tokens
     * @param _token Token contract address
     * @param _amount Amount to withdraw
     * @param _signatures Concatenated validator signatures
     */
    function g(
        uint256 l,
        address ah,
        address ab,
        uint256 y,
        bytes memory p
    ) external {
        // Check if already processed
        require(!a[l], "Already processed");

        // Check if token is supported
        require(h[ab], "Token not supported");

        // Verify signatures
        require(
            f(
                l,
                ah,
                ab,
                y,
                p
            ),
            "Invalid signatures"
        );

        // Mark as processed
        a[l] = true;

        // Transfer tokens
        emit WithdrawalProcessed(l, ah, ab, y);
    }

    /**
     * @notice Verify validator signatures
     */
    function f(
        uint256 l,
        address ah,
        address ab,
        uint256 y,
        bytes memory p
    ) internal view returns (bool) {
        require(p.length % 65 == 0, "Invalid signature length");

        uint256 k = p.length / 65;
        require(k >= c, "Not enough signatures");

        // Reconstruct the message hash
        bytes32 q = v(
            abi.m(l, ah, ab, y)
        );
        bytes32 b = v(
            abi.m("\x19Ethereum Signed Message:\n32", q)
        );

        address[] memory z = new address[](k);

        // Extract and verify each signature
        for (uint256 i = 0; i < k; i++) {
            bytes memory w = e(p, i);
            address ad = i(b, w);

            // Check if signer is a validator
            require(r[ad], "Invalid signer");

            // Check for duplicate signers
            for (uint256 j = 0; j < i; j++) {
                require(z[j] != ad, "Duplicate signer");
            }

            z[i] = ad;
        }

        // All checks passed
        return true;
    }

    /**
     * @notice Extract a single signature from concatenated signatures
     */
    function e(
        bytes memory p,
        uint256 ae
    ) internal pure returns (bytes memory) {
        bytes memory w = new bytes(65);
        uint256 aa = ae * 65;

        for (uint256 i = 0; i < 65; i++) {
            w[i] = p[aa + i];
        }

        return w;
    }

    /**
     * @notice Recover signer from signature
     */
    function i(
        bytes32 af,
        bytes memory s
    ) internal pure returns (address) {
        require(s.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(s, 32))
            s := mload(add(s, 64))
            v := byte(0, mload(add(s, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return x(af, v, r, s);
    }

    /**
     * @notice Add supported token (admin function)
     */
    function d(address ab) external {
        h[ab] = true;
    }
}
