pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x63c490, uint256 _0xc3c626) external returns (bool);

    function _0xa8dea9(
        address from,
        address _0x63c490,
        uint256 _0xc3c626
    ) external returns (bool);

    function _0x68c9f7(address _0xe0d0c3) external view returns (uint256);

    function _0x8a6a93(address _0x026c6a, uint256 _0xc3c626) external returns (bool);
}

interface IUniswapV3Router {
    struct ExactInputSingleParams {
        address _0x57b33d;
        address _0xde782b;
        uint24 _0x09088e;
        address _0x878b3e;
        uint256 _0xec982a;
        uint256 _0x8b6cd1;
        uint256 _0xcd8999;
        uint160 _0x38737a;
    }

    function _0xd82e1c(
        ExactInputSingleParams calldata _0x59ceeb
    ) external payable returns (uint256 _0xee25ae);
}

contract BedrockVault {
    IERC20 public immutable _0x51b93a;
    IERC20 public immutable WBTC;
    IUniswapV3Router public immutable _0xcdfacc;

    uint256 public _0xa454ec;
    uint256 public _0xb14187;

    constructor(address _0xc09748, address _0xfb9c99, address _0xf27724) {
        _0x51b93a = IERC20(_0xc09748);
        WBTC = IERC20(_0xfb9c99);
        _0xcdfacc = IUniswapV3Router(_0xf27724);
    }

    function _0x429a29() external payable {
        require(msg.value > 0, "No ETH sent");

        uint256 _0x9d501a = msg.value;

        _0xa454ec += msg.value;
        _0xb14187 += _0x9d501a;

        _0x51b93a.transfer(msg.sender, _0x9d501a);
    }

    function _0x0981e5(uint256 _0xc3c626) external {
        require(_0xc3c626 > 0, "No amount specified");
        require(_0x51b93a._0x68c9f7(msg.sender) >= _0xc3c626, "Insufficient balance");

        _0x51b93a._0xa8dea9(msg.sender, address(this), _0xc3c626);

        uint256 _0x88ee00 = _0xc3c626;
        require(address(this).balance >= _0x88ee00, "Insufficient ETH");

        payable(msg.sender).transfer(_0x88ee00);
    }

    function _0x6030af() external pure returns (uint256) {
        return 1e18;
    }

    receive() external payable {}
}