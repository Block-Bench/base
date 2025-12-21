pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xdf704e, uint256 _0x77b483) external returns (bool);

    function _0x881b9d(
        address from,
        address _0xdf704e,
        uint256 _0x77b483
    ) external returns (bool);

    function _0xa3dee5(address _0x14518c) external view returns (uint256);

    function _0x0a7677(address _0xe6f2b5, uint256 _0x77b483) external returns (bool);
}

interface IWETH {
    function _0x9a2f1d() external payable;

    function _0x097ffa(uint256 _0x77b483) external;

    function _0xa3dee5(address _0x14518c) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable _0xd6b158;

    constructor(address _0xdb3aa8, address _0x342c10) {
        WETH = IWETH(_0xdb3aa8);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xd6b158 = _0x342c10; }
    }

    function _0xef47b9(
        int256 _0xdd6232,
        int256 _0xf44237,
        bytes calldata data
    ) external payable {
        (
            uint256 _0x9a75dd,
            address _0x7b1657,
            address _0xbab436,
            address _0x44c3af
        ) = abi._0xce2b12(data, (uint256, address, address, address));

        uint256 _0x3899cb;
        if (_0xdd6232 > 0) {
            _0x3899cb = uint256(_0xdd6232);
        } else {
            _0x3899cb = uint256(_0xf44237);
        }

        if (_0xbab436 == address(WETH)) {
            WETH._0x097ffa(_0x3899cb);
            payable(_0x44c3af).transfer(_0x3899cb);
        } else {
            IERC20(_0xbab436).transfer(_0x44c3af, _0x3899cb);
        }
    }

    function _0x0878a4(bytes calldata _0x881072) external {
        require(msg.sender == _0xd6b158, "Only settlement");
    }

    receive() external payable {}
}