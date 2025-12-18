// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address y, uint256 s) external returns (bool);

    function f(
        address from,
        address y,
        uint256 s
    ) external returns (bool);

    function l(address r) external view returns (uint256);

    function p(address o, uint256 s) external returns (bool);
}

interface ISmartLoan {
    function c(
        bytes32 i,
        bytes32 n,
        uint256 e,
        uint256 d,
        bytes4 selector,
        bytes memory data
    ) external;

    function g(address v, uint256[] calldata x) external;
}

contract SmartLoansFactory {
    address public t;

    constructor() {
        t = msg.sender;
    }

    function j() external returns (address) {
        SmartLoan w = new SmartLoan();
        return address(w);
    }

    function h(
        address k,
        address b
    ) external {
        require(msg.sender == t, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public m;
    mapping(bytes32 => uint256) public u;

    function c(
        bytes32 i,
        bytes32 n,
        uint256 e,
        uint256 d,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function g(
        address v,
        uint256[] calldata x
    ) external override {
        (bool q, ) = v.call(
            abi.a("claimRewards(address)", msg.sender)
        );
    }
}
