pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xe4eac4, uint256 _0x14daf4) external returns (bool);

    function _0xedb048(
        address from,
        address _0xe4eac4,
        uint256 _0x14daf4
    ) external returns (bool);

    function _0xa7806d(address _0x51000b) external view returns (uint256);

    function _0xd4ac9e(address _0x1f0959, uint256 _0x14daf4) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address _0x28ba9e;
        address _0x87ef9e;
        uint24 _0x56d244;
        address _0x0507b1;
        uint256 _0x3097b2;
        uint256 _0x9239ad;
        uint256 _0x79714c;
        uint160 _0x1c76e6;
    }

    function _0x8b08ad(
        ExactInputSingleParams calldata _0x284f30
    ) external payable returns (uint256 _0x0dd3e0);
}

contract BedrockVault {
    IERC20 public immutable _0xe8b251;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable _0x8f959a;

    uint256 public _0x79585a;
    uint256 public _0xd83cf3;

    constructor(address _0xa50359, address _0x789f40, address _0x2e1f60) {
        _0xe8b251 = IERC20(_0xa50359);
        WBTC = IERC20(_0x789f40);
        if (gasleft() > 0) { _0x8f959a = IUniswapV3Router(_0x2e1f60); }
    }

    function _0x80ca59() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 _0x0ac90a = msg.value;

        _0x79585a += msg.value;
        _0xd83cf3 += _0x0ac90a;

        _0xe8b251.transfer(msg.sender, _0x0ac90a);
    }

    function _0x6de300(uint256 _0x14daf4) external {
        require(_0x14daf4 > 0, "No amount specified");
        require(_0xe8b251._0xa7806d(msg.sender) >= _0x14daf4, "Insufficient balance");

        _0xe8b251._0xedb048(msg.sender, address(this), _0x14daf4);

        uint256 _0x2d88ff = _0x14daf4;
        require(address(this).balance >= _0x2d88ff, "Insufficient ETH");

        payable(msg.sender).transfer(_0x2d88ff);
    }

    function _0x9d97d3() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}