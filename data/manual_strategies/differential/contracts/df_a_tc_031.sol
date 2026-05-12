// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract OrbitBridge {
    mapping(bytes32 => bool) public processedTransactions;
    uint256 public constant REQUIRED_SIGNATURES = 5;
    uint256 public constant TOTAL_VALIDATORS = 7;

    mapping(address => bool) public validators;
    address[] public validatorList;

    event WithdrawalProcessed(
        bytes32 txHash,
        address token,
        address recipient,
        uint256 amount
    );

    constructor() {
        validatorList = new address[](0);
    }

    function withdraw(
        address hubContract,
        string memory fromChain,
        bytes memory fromAddr,
        address toAddr,
        address token,
        bytes32[] memory bytes32s,
        uint256[] memory uints,
        bytes memory data,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external {
        bytes32 txHash = bytes32s[1];

        require(!processedTransactions[txHash], "Transaction already processed");
        require(v.length >= REQUIRED_SIGNATURES, "Insufficient signatures");
        require(v.length == r.length && r.length == s.length, "Signature length mismatch");

        uint256 amount = uints[0];

        bytes32 messageHash = keccak256(abi.encodePacked(txHash, token, toAddr, amount));
        bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        uint256 validSignatures = 0;
        for (uint i = 0; i < v.length; i++) {
            address signer = ecrecover(ethSignedMessageHash, v[i], r[i], s[i]);
            if (validators[signer]) {
                validSignatures++;
            }
        }

        require(validSignatures >= REQUIRED_SIGNATURES, "Not enough valid validator signatures");

        processedTransactions[txHash] = true;
        IERC20(token).transfer(toAddr, amount);
        emit WithdrawalProcessed(txHash, token, toAddr, amount);
    }

    function addValidator(address validator) external {
        validators[validator] = true;
    }
}
