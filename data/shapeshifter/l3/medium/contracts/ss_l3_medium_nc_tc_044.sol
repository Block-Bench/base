pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xbbcb6c, uint256 _0xb22aa7) external returns (bool);

    function _0x041080(
        address from,
        address _0xbbcb6c,
        uint256 _0xb22aa7
    ) external returns (bool);

    function _0x7be22e(address _0x541e6c) external view returns (uint256);

    function _0xe29902(address _0xcff942, uint256 _0xb22aa7) external returns (bool);
}

interface ISmartLoan {
    function _0xaac0b0(
        bytes32 _0xb15ebe,
        bytes32 _0xfa1d8a,
        uint256 _0x0fe2c4,
        uint256 _0x56ad2a,
        bytes4 selector,
        bytes memory data
    ) external;

    function _0xa4d32c(address _0x5825b0, uint256[] calldata _0xa4bd9f) external;
}

contract SmartLoansFactory {
    address public _0x1e14ae;

    constructor() {
        _0x1e14ae = msg.sender;
    }

    function _0x3fa492() external returns (address) {
        SmartLoan _0xb2ad6d = new SmartLoan();
        return address(_0xb2ad6d);
    }

    function _0x3676f5(
        address _0x1d6fef,
        address _0x57b81d
    ) external {
        require(msg.sender == _0x1e14ae, "Not admin");
    }
}

contract SmartLoan is ISmartLoan {
    mapping(bytes32 => uint256) public _0x3c6766;
    mapping(bytes32 => uint256) public _0x865d1b;

    function _0xaac0b0(
        bytes32 _0xb15ebe,
        bytes32 _0xfa1d8a,
        uint256 _0x0fe2c4,
        uint256 _0x56ad2a,
        bytes4 selector,
        bytes memory data
    ) external override {}

    function _0xa4d32c(
        address _0x5825b0,
        uint256[] calldata _0xa4bd9f
    ) external override {
        (bool _0xb8cddd, ) = _0x5825b0.call(
            abi._0x5ea073("claimRewards(address)", msg.sender)
        );
    }
}