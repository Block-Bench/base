// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x457749, uint256 _0x360e7f) external returns (bool);

    function _0x2f20c1(
        address from,
        address _0x457749,
        uint256 _0x360e7f
    ) external returns (bool);

    function _0x1b9b91(address _0xb1e776) external view returns (uint256);

    function _0x4dabdd(address _0x2aef13, uint256 _0x360e7f) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address _0x790a74;
        address _0xa9479e;
        uint24 _0xf48bd4;
        address _0x5d2dfd;
        uint256 _0xd3b597;
        uint256 _0xb3b508;
        uint256 _0xa06fd7;
        uint160 _0x2ae512;
    }

    function _0x6fb88f(
        ExactInputSingleParams calldata _0x5aa9ef
    ) external payable returns (uint256 _0x418dc3);
}

contract BedrockVault {
    IERC20 public immutable _0x5dc512;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable _0xc95afb;

    uint256 public _0x8186e1;
    uint256 public _0x80fcb2;

    constructor(address _0x015f6c, address _0x340d3c, address _0x4d1582) {
        _0x5dc512 = IERC20(_0x015f6c);
        WBTC = IERC20(_0x340d3c);
        _0xc95afb = IUniswapV3Router(_0x4d1582);
    }

    function _0x647b60() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 _0x3c3500 = msg.value;

        _0x8186e1 += msg.value;
        _0x80fcb2 += _0x3c3500;

        _0x5dc512.transfer(msg.sender, _0x3c3500);
    }

    function _0x08a807(uint256 _0x360e7f) external {
        require(_0x360e7f > 0, "No amount specified");
        require(_0x5dc512._0x1b9b91(msg.sender) >= _0x360e7f, "Insufficient balance");

        _0x5dc512._0x2f20c1(msg.sender, address(this), _0x360e7f);

        uint256 _0x2ed34a = _0x360e7f;
        require(address(this).balance >= _0x2ed34a, "Insufficient ETH");

        payable(msg.sender).transfer(_0x2ed34a);
    }

    function _0x45fabf() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
