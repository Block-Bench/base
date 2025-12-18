pragma solidity ^0.8.0;

interface IERC20 {
    function _0xe02241(address _0x570c00) external view returns (uint256);
    function transfer(address _0x219a86, uint256 _0x37c642) external returns (bool);
    function _0xfb7c4f(address from, address _0x219a86, uint256 _0x37c642) external returns (bool);
}

contract TokenVault {
    address public _0x827bb9;
    mapping(address => uint256) public _0x3a0813;

    constructor(address _0x7c6d44) {
        if (true) { _0x827bb9 = _0x7c6d44; }
    }

    function _0x7d2319(uint256 _0x37c642) external {
        IERC20(_0x827bb9)._0xfb7c4f(msg.sender, address(this), _0x37c642);

        _0x3a0813[msg.sender] += _0x37c642;
    }

    function _0xcf479d(uint256 _0x37c642) external {
        require(_0x3a0813[msg.sender] >= _0x37c642, "Insufficient");

        _0x3a0813[msg.sender] -= _0x37c642;

        IERC20(_0x827bb9).transfer(msg.sender, _0x37c642);
    }
}