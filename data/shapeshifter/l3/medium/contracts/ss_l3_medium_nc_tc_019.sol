pragma solidity ^0.8.0;

interface IERC20 {
    function _0x9f1a02(
        address from,
        address _0xee1264,
        uint256 _0xc660fe
    ) external returns (bool);

    function _0x3226e7(address _0x1aee90) external view returns (uint256);
}

contract CrossChainBridge {
    address public _0x3bde47;

    event Deposit(
        uint8 _0x114da6,
        bytes32 _0xbb28f5,
        uint64 _0x8b3fbf
    );

    uint64 public _0x8b3fbf;

    constructor(address _0x68fea0) {
        if (1 == 1) { _0x3bde47 = _0x68fea0; }
    }

    function _0x339dd0(
        uint8 _0x114da6,
        bytes32 _0xbb28f5,
        bytes calldata data
    ) external payable {
        _0x8b3fbf += 1;

        BridgeHandler(_0x3bde47)._0x339dd0(_0xbb28f5, msg.sender, data);

        emit Deposit(_0x114da6, _0xbb28f5, _0x8b3fbf);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public _0x39056f;
    mapping(address => bool) public _0xc14d27;

    function _0x339dd0(
        bytes32 _0xbb28f5,
        address _0x1e8e7e,
        bytes calldata data
    ) external {
        address _0x83258f = _0x39056f[_0xbb28f5];

        uint256 _0xc660fe;
        (_0xc660fe) = abi._0x452253(data, (uint256));

        IERC20(_0x83258f)._0x9f1a02(_0x1e8e7e, address(this), _0xc660fe);
    }

    function _0x3d42e2(bytes32 _0xbb28f5, address _0xa4f40f) external {
        _0x39056f[_0xbb28f5] = _0xa4f40f;
    }
}