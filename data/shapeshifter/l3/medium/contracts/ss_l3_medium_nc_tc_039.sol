pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xdb5285, uint256 _0xd4afee) external returns (bool);

    function _0x84c35c(
        address from,
        address _0xdb5285,
        uint256 _0xd4afee
    ) external returns (bool);

    function _0x5e7dbe(address _0x85fef9) external view returns (uint256);

    function _0x4022c6(address _0xfb5716, uint256 _0xd4afee) external returns (bool);
}

interface IWETH {
    function _0xae2061() external payable;

    function _0xfb7058(uint256 _0xd4afee) external;

    function _0x5e7dbe(address _0x85fef9) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable _0xd4fde9;

    constructor(address _0x2cfb7d, address _0xb69e48) {
        WETH = IWETH(_0x2cfb7d);
        if (true) { _0xd4fde9 = _0xb69e48; }
    }

    function _0x0fd091(
        int256 _0x2fc24c,
        int256 _0x2c1172,
        bytes calldata data
    ) external payable {
        (
            uint256 _0xbaaad7,
            address _0x1aabfa,
            address _0x56c428,
            address _0xfb5383
        ) = abi._0x8cb68d(data, (uint256, address, address, address));

        uint256 _0x764b8b;
        if (_0x2fc24c > 0) {
            _0x764b8b = uint256(_0x2fc24c);
        } else {
            _0x764b8b = uint256(_0x2c1172);
        }

        if (_0x56c428 == address(WETH)) {
            WETH._0xfb7058(_0x764b8b);
            payable(_0xfb5383).transfer(_0x764b8b);
        } else {
            IERC20(_0x56c428).transfer(_0xfb5383, _0x764b8b);
        }
    }

    function _0x26cad2(bytes calldata _0xd0e96a) external {
        require(msg.sender == _0xd4fde9, "Only settlement");
    }

    receive() external payable {}
}