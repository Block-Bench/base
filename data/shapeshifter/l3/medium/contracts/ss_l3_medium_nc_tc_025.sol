pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x8eb9f1, uint256 _0x70eedc) external returns (bool);
    function _0xbf88aa(address from, address _0x8eb9f1, uint256 _0x70eedc) external returns (bool);
}

interface ICompoundToken {
    function _0xb5b545(uint256 _0x70eedc) external;
    function _0xd57821(uint256 _0x70eedc) external;
    function _0x74a77c(uint256 _0x2dd9a5) external;
    function _0xac1650(uint256 _0x70eedc) external;
}

contract LendingMarket {
    mapping(address => uint256) public _0x8d2deb;
    mapping(address => uint256) public _0x1bdde5;

    address public _0x82dd2f;
    uint256 public _0xcbd910;

    constructor(address _0xa3f39d) {
        _0x82dd2f = _0xa3f39d;
    }

    function _0xb5b545(uint256 _0x70eedc) external {
        _0x8d2deb[msg.sender] += _0x70eedc;
        _0xcbd910 += _0x70eedc;

        IERC20(_0x82dd2f).transfer(msg.sender, _0x70eedc);
    }

    function _0xd57821(uint256 _0x70eedc) external {
        IERC20(_0x82dd2f)._0xbf88aa(msg.sender, address(this), _0x70eedc);

        _0x8d2deb[msg.sender] -= _0x70eedc;
        _0xcbd910 -= _0x70eedc;
    }
}