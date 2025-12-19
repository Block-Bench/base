struct EIP712Domain {
    string name;
    string version;
    uint256 chainId;
    address verifyingContract;
}

// Domain separator should be computed and included in signed payload
bytes32 domainSeparator = keccak256(
    abi.encode(
        EIP712_TYPEHASH,
        keccak256(bytes("Kyber
")),
        keccak256(bytes("1")),
        block.chainid,
        address(this)
    )
);