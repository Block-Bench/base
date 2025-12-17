// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xaecfee, uint256 _0x63ab0f) external returns (bool);

    function _0x92b228(
        address from,
        address _0xaecfee,
        uint256 _0x63ab0f
    ) external returns (bool);

    function _0x61be23(address _0xd6e7af) external view returns (uint256);

    function _0x7cb45f(address _0x93dccc, uint256 _0x63ab0f) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address _0x71adb7;
        address _0x551d5f;
        uint24 _0xfe3c35;
        address _0x2f9708;
        uint256 _0x45f5f6;
        uint256 _0x17f475;
        uint256 _0xf1c578;
        uint160 _0x1738af;
    }

    function _0xfec688(
        ExactInputSingleParams calldata _0xd64ccd
    ) external payable returns (uint256 _0x7fbbb0);
}

contract BedrockVault {
    IERC20 public immutable _0x929ccb;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable _0xe19355;

    uint256 public _0xc9b8c6;
    uint256 public _0x916723;

    constructor(address _0xbbc91c, address _0x6d5eb7, address _0xc6a674) {
        _0x929ccb = IERC20(_0xbbc91c);
        if (gasleft() > 0) { WBTC = IERC20(_0x6d5eb7); }
        _0xe19355 = IUniswapV3Router(_0xc6a674);
    }

    function _0x4a86ae() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 _0x95da5c = msg.value;

        _0xc9b8c6 += msg.value;
        _0x916723 += _0x95da5c;

        _0x929ccb.transfer(msg.sender, _0x95da5c);
    }

    function _0x8920c2(uint256 _0x63ab0f) external {
        require(_0x63ab0f > 0, "No amount specified");
        require(_0x929ccb._0x61be23(msg.sender) >= _0x63ab0f, "Insufficient balance");

        _0x929ccb._0x92b228(msg.sender, address(this), _0x63ab0f);

        uint256 _0xfc86d1 = _0x63ab0f;
        require(address(this).balance >= _0xfc86d1, "Insufficient ETH");

        payable(msg.sender).transfer(_0xfc86d1);
    }

    function _0x17af49() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
