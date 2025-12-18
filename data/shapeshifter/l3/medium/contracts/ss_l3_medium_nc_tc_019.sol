pragma solidity ^0.8.0;

interface IERC20 {
    function _0xfe2e28(
        address from,
        address _0x51ef51,
        uint256 _0xde130c
    ) external returns (bool);

    function _0xe30d4b(address _0x259802) external view returns (uint256);
}

contract CrossChainBridge {
    address public _0x806dad;

    event Deposit(
        uint8 _0x22864e,
        bytes32 _0x9470a2,
        uint64 _0x2084d9
    );

    uint64 public _0x2084d9;

    constructor(address _0x94b9a8) {
        _0x806dad = _0x94b9a8;
    }

    function _0x6f4399(
        uint8 _0x22864e,
        bytes32 _0x9470a2,
        bytes calldata data
    ) external payable {
        _0x2084d9 += 1;

        BridgeHandler(_0x806dad)._0x6f4399(_0x9470a2, msg.sender, data);

        emit Deposit(_0x22864e, _0x9470a2, _0x2084d9);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public _0x934f21;
    mapping(address => bool) public _0x3629a6;

    function _0x6f4399(
        bytes32 _0x9470a2,
        address _0x9f7d15,
        bytes calldata data
    ) external {
        address _0xc6a92d = _0x934f21[_0x9470a2];

        uint256 _0xde130c;
        (_0xde130c) = abi._0xcc5744(data, (uint256));

        IERC20(_0xc6a92d)._0xfe2e28(_0x9f7d15, address(this), _0xde130c);
    }

    function _0x8fa52e(bytes32 _0x9470a2, address _0x2e1389) external {
        _0x934f21[_0x9470a2] = _0x2e1389;
    }
}