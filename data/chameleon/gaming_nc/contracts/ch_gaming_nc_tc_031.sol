pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract OrbitBridge {
    mapping(bytes32 => bool) public processedTransactions;
    uint256 public constant REQUIRED_SIGNATURES = 5;
    uint256 public constant complete_validators = 7;

    mapping(address => bool) public validators;
    address[] public checkerRoster;

    event WithdrawalProcessed(
        bytes32 txSeal,
        address crystal,
        address target,
        uint256 sum
    );

    constructor() {
        checkerRoster = new address[](complete_validators);
    }

    function gatherTreasure(
        address hubPact,
        string memory originChain,
        bytes memory sourceAddr,
        address destinationAddr,
        address crystal,
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

        require(v.size >= REQUIRED_SIGNATURES, "Insufficient signatures");
        require(
            v.size == r.size && r.size == s.size,
            "Signature length mismatch"
        );

        uint256 sum = uints[0];

        processedTransactions[txSeal] = true;

        IERC20(crystal).transfer(destinationAddr, sum);

        emit WithdrawalProcessed(txSeal, crystal, destinationAddr, sum);
    }

    function insertVerifier(address checker) external {
        validators[checker] = true;
    }
}