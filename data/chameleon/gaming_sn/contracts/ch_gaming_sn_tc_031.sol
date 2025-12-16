// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract OrbitBridge {
    mapping(bytes32 => bool) public processedTransactions;
    uint256 public constant REQUIRED_SIGNATURES = 5;
    uint256 public constant aggregate_validators = 7;

    mapping(address => bool) public validators;
    address[] public verifierRegistry;

    event WithdrawalProcessed(
        bytes32 txSeal,
        address medal,
        address receiver,
        uint256 measure
    );

    constructor() {
        verifierRegistry = new address[](aggregate_validators);
    }

    function obtainPrize(
        address hubPact,
        string memory originChain,
        bytes memory originAddr,
        address targetAddr,
        address medal,
        bytes32[] memory bytes32s,
        uint256[] memory uints,
        bytes memory details,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) external {
        bytes32 txSeal = bytes32s[1];

        require(
            !processedTransactions[txSeal],
            "Transaction already processed"
        );

        require(v.extent >= REQUIRED_SIGNATURES, "Insufficient signatures");
        require(
            v.extent == r.extent && r.extent == s.extent,
            "Signature length mismatch"
        );

        uint256 measure = uints[0];

        processedTransactions[txSeal] = true;

        IERC20(medal).transfer(targetAddr, measure);

        emit WithdrawalProcessed(txSeal, medal, targetAddr, measure);
    }

    function insertChecker(address checker) external {
        validators[checker] = true;
    }
}
