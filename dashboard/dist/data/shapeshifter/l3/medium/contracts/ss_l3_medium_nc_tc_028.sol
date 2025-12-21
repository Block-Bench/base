pragma solidity ^0.8.0;

interface IERC20 {
    function _0xe77a7e(address _0x679f83) external view returns (uint256);
    function transfer(address _0x7241d4, uint256 _0x867445) external returns (bool);
    function _0x4cd98a(address from, address _0x7241d4, uint256 _0x867445) external returns (bool);
}

contract TokenVault {
    address public _0xbcb739;
    mapping(address => uint256) public _0x9f8a0c;

    constructor(address _0x7481e9) {
        _0xbcb739 = _0x7481e9;
    }

    function _0x182eae(uint256 _0x867445) external {
        IERC20(_0xbcb739)._0x4cd98a(msg.sender, address(this), _0x867445);

        _0x9f8a0c[msg.sender] += _0x867445;
    }

    function _0xee2776(uint256 _0x867445) external {
        require(_0x9f8a0c[msg.sender] >= _0x867445, "Insufficient");

        _0x9f8a0c[msg.sender] -= _0x867445;

        IERC20(_0xbcb739).transfer(msg.sender, _0x867445);
    }
}