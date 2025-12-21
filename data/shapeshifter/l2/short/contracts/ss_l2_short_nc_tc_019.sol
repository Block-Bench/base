pragma solidity ^0.8.0;

interface IERC20 {
    function e(
        address from,
        address r,
        uint256 p
    ) external returns (bool);

    function k(address o) external view returns (uint256);
}

contract CrossChainBridge {
    address public n;

    event Deposit(
        uint8 b,
        bytes32 i,
        uint64 f
    );

    uint64 public f;

    constructor(address l) {
        n = l;
    }

    function m(
        uint8 b,
        bytes32 i,
        bytes calldata data
    ) external payable {
        f += 1;

        BridgeHandler(n).m(i, msg.sender, data);

        emit Deposit(b, i, f);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public a;
    mapping(address => bool) public c;

    function m(
        bytes32 i,
        address j,
        bytes calldata data
    ) external {
        address d = a[i];

        uint256 p;
        (p) = abi.q(data, (uint256));

        IERC20(d).e(j, address(this), p);
    }

    function h(bytes32 i, address g) external {
        a[i] = g;
    }
}