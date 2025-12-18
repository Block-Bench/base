pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address y, uint256 s) external returns (bool);

    function e(
        address from,
        address y,
        uint256 s
    ) external returns (bool);

    function k(address r) external view returns (uint256);

    function q(address o, uint256 s) external returns (bool);
}

interface ISmartLoan {
    function c(
        bytes32 j,
        bytes32 m,
        uint256 f,
        uint256 d,
        bytes4 selector,
        bytes memory data
    ) external;

    function h(address v, uint256[] calldata x) external;
}

contract SmartLoansFactory {
    address public t;

    constructor() {
        t = msg.sender;
    }

    function i() external returns (address) {
        SmartLoan w = new SmartLoan();
        return address(w);
    }

    function g(
        address l,
        address b
    ) external {
        require(msg.sender == t, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public n;
    mapping(bytes32 => uint256) public u;

    function c(
        bytes32 j,
        bytes32 m,
        uint256 f,
        uint256 d,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function h(
        address v,
        uint256[] calldata x
    ) external override {
        (bool p, ) = v.call(
            abi.a("claimRewards(address)", msg.sender)
        );
    }
}