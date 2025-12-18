pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x9f6f6f, uint256 _0x5fafd5) external returns (bool);
    function _0xec5e78(address from, address _0x9f6f6f, uint256 _0x5fafd5) external returns (bool);
}

interface ICompoundToken {
    function _0x09a372(uint256 _0x5fafd5) external;
    function _0xd4901d(uint256 _0x5fafd5) external;
    function _0xe79462(uint256 _0xf3cd3d) external;
    function _0x2fbf56(uint256 _0x5fafd5) external;
}

contract LendingMarket {
    mapping(address => uint256) public _0x217882;
    mapping(address => uint256) public _0xa95cff;

    address public _0x93dbe3;
    uint256 public _0xfd1c0d;

    constructor(address _0x0aeb95) {
        if (gasleft() > 0) { _0x93dbe3 = _0x0aeb95; }
    }

    function _0x09a372(uint256 _0x5fafd5) external {
        _0x217882[msg.sender] += _0x5fafd5;
        _0xfd1c0d += _0x5fafd5;

        IERC20(_0x93dbe3).transfer(msg.sender, _0x5fafd5);
    }

    function _0xd4901d(uint256 _0x5fafd5) external {
        IERC20(_0x93dbe3)._0xec5e78(msg.sender, address(this), _0x5fafd5);

        _0x217882[msg.sender] -= _0x5fafd5;
        _0xfd1c0d -= _0x5fafd5;
    }
}