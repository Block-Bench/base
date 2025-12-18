pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address y, uint256 s) external returns (bool);

    function e(
        address from,
        address y,
        uint256 s
    ) external returns (bool);

    function k(address r) external view returns (uint256);

    function q(address p, uint256 s) external returns (bool);
}

interface ISmartLoan {
    function c(
        bytes32 i,
        bytes32 n,
        uint256 f,
        uint256 d,
        bytes4 selector,
        bytes memory data
    ) external;

    function g(address v, uint256[] calldata x) external;
}

contract SmartLoansFactory {
    address public u;

    constructor() {
        u = msg.sender;
    }

    function j() external returns (address) {
        SmartLoan w = new SmartLoan();
        return address(w);
    }

    function h(
        address l,
        address b
    ) external {
        require(msg.sender == u, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public m;
    mapping(bytes32 => uint256) public t;

    function c(
        bytes32 i,
        bytes32 n,
        uint256 f,
        uint256 d,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function g(
        address v,
        uint256[] calldata x
    ) external override {
        (bool o, ) = v.call(
            abi.a("claimRewards(address)", msg.sender)
        );
    }
}