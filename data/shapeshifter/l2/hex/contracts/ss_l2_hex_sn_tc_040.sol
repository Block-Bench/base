// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x7af535, uint256 _0x1c9651) external returns (bool);

    function _0x157783(
        address from,
        address _0x7af535,
        uint256 _0x1c9651
    ) external returns (bool);

    function _0x9cdbff(address _0xde4c19) external view returns (uint256);

    function _0xcf992b(address _0x524178, uint256 _0x1c9651) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address _0xc157d6;
        address _0xb2a36e;
        uint24 _0xd68578;
        address _0x228e35;
        uint256 _0x881810;
        uint256 _0x524875;
        uint256 _0xf388f9;
        uint160 _0xe4708e;
    }

    function _0x86f74f(
        ExactInputSingleParams calldata _0x8ac67d
    ) external payable returns (uint256 _0x2dd3db);
}

contract BedrockVault {
    IERC20 public immutable _0xacc169;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable _0x3f55ed;

    uint256 public _0x5c4359;
    uint256 public _0xb4d091;

    constructor(address _0x146e17, address _0xa81be9, address _0xe506e0) {
        _0xacc169 = IERC20(_0x146e17);
        WBTC = IERC20(_0xa81be9);
        _0x3f55ed = IUniswapV3Router(_0xe506e0);
    }

    function _0xca7a5e() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 _0x81e077 = msg.value;

        _0x5c4359 += msg.value;
        _0xb4d091 += _0x81e077;

        _0xacc169.transfer(msg.sender, _0x81e077);
    }

    function _0x24aa3f(uint256 _0x1c9651) external {
        require(_0x1c9651 > 0, "No amount specified");
        require(_0xacc169._0x9cdbff(msg.sender) >= _0x1c9651, "Insufficient balance");

        _0xacc169._0x157783(msg.sender, address(this), _0x1c9651);

        uint256 _0x0e8259 = _0x1c9651;
        require(address(this).balance >= _0x0e8259, "Insufficient ETH");

        payable(msg.sender).transfer(_0x0e8259);
    }

    function _0x6b2834() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}
