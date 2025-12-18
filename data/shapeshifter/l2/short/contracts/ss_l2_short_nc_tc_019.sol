pragma solidity ^0.8.0;

interface IERC20 {
    function g(
        address from,
        address r,
        uint256 p
    ) external returns (bool);

    function k(address m) external view returns (uint256);
}

contract CrossChainBridge {
    address public o;

    event Deposit(
        uint8 b,
        bytes32 i,
        uint64 e
    );

    uint64 public e;

    constructor(address l) {
        o = l;
    }

    function n(
        uint8 b,
        bytes32 i,
        bytes calldata data
    ) external payable {
        e += 1;

        BridgeHandler(o).n(i, msg.sender, data);

        emit Deposit(b, i, e);
    }
}

contract BridgeHandler {
    mapping(bytes32 => address) public a;
    mapping(address => bool) public c;

    function n(
        bytes32 i,
        address j,
        bytes calldata data
    ) external {
        address d = a[i];

        uint256 p;
        (p) = abi.q(data, (uint256));

        IERC20(d).g(j, address(this), p);
    }

    function h(bytes32 i, address f) external {
        a[i] = f;
    }
}