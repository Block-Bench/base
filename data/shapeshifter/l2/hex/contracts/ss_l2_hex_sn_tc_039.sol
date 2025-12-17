// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x42300a, uint256 _0x58bde6) external returns (bool);

    function _0xfc57c0(
        address from,
        address _0x42300a,
        uint256 _0x58bde6
    ) external returns (bool);

    function _0xea7d75(address _0xe3e06f) external view returns (uint256);

    function _0x2c50f4(address _0x7b612b, uint256 _0x58bde6) external returns (bool);
}

interface IWETH {
    function _0x8bca28() external payable;

    function _0x501c8b(uint256 _0x58bde6) external;

    function _0xea7d75(address _0xe3e06f) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable _0xaed6d9;

    constructor(address _0xef9371, address _0x0b5fd2) {
        WETH = IWETH(_0xef9371);
        _0xaed6d9 = _0x0b5fd2;
    }

    function _0x6d301c(
        int256 _0x35bf01,
        int256 _0x7522bd,
        bytes calldata data
    ) external payable {
        (
            uint256 _0xb1e115,
            address _0x7fae2f,
            address _0xf470aa,
            address _0xa9aa37
        ) = abi._0xffccd2(data, (uint256, address, address, address));

        uint256 _0x6a8b1b;
        if (_0x35bf01 > 0) {
            _0x6a8b1b = uint256(_0x35bf01);
        } else {
            _0x6a8b1b = uint256(_0x7522bd);
        }

        if (_0xf470aa == address(WETH)) {
            WETH._0x501c8b(_0x6a8b1b);
            payable(_0xa9aa37).transfer(_0x6a8b1b);
        } else {
            IERC20(_0xf470aa).transfer(_0xa9aa37, _0x6a8b1b);
        }
    }

    function _0xca1956(bytes calldata _0x13e910) external {
        require(msg.sender == _0xaed6d9, "Only settlement");
    }

    receive() external payable {}
}
