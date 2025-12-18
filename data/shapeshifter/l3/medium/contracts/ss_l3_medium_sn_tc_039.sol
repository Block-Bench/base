// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x368e6b, uint256 _0x66d901) external returns (bool);

    function _0x29bd0c(
        address from,
        address _0x368e6b,
        uint256 _0x66d901
    ) external returns (bool);

    function _0xd9d51b(address _0xd22532) external view returns (uint256);

    function _0x0105dc(address _0xf78fd6, uint256 _0x66d901) external returns (bool);
}

interface IWETH {
    function _0x8bf0e7() external payable;

    function _0x2c2fde(uint256 _0x66d901) external;

    function _0xd9d51b(address _0xd22532) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable _0xf086f4;

    constructor(address _0xd1ec7d, address _0x718515) {
        WETH = IWETH(_0xd1ec7d);
        _0xf086f4 = _0x718515;
    }

    function _0x99a059(
        int256 _0x5ff205,
        int256 _0xcd67b6,
        bytes calldata data
    ) external payable {
        (
            uint256 _0xe6cf77,
            address _0x102c54,
            address _0xad7626,
            address _0xd1f5bd
        ) = abi._0x48d883(data, (uint256, address, address, address));

        uint256 _0x33709d;
        if (_0x5ff205 > 0) {
            _0x33709d = uint256(_0x5ff205);
        } else {
            _0x33709d = uint256(_0xcd67b6);
        }

        if (_0xad7626 == address(WETH)) {
            WETH._0x2c2fde(_0x33709d);
            payable(_0xd1f5bd).transfer(_0x33709d);
        } else {
            IERC20(_0xad7626).transfer(_0xd1f5bd, _0x33709d);
        }
    }

    function _0x768bcd(bytes calldata _0xf9f22a) external {
        require(msg.sender == _0xf086f4, "Only settlement");
    }

    receive() external payable {}
}
