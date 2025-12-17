// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x987233, uint256 _0x7edd68) external returns (bool);

    function _0x702a09(
        address from,
        address _0x987233,
        uint256 _0x7edd68
    ) external returns (bool);

    function _0xb12a2e(address _0x80a3a8) external view returns (uint256);

    function _0x574975(address _0xcfb48c, uint256 _0x7edd68) external returns (bool);
}

interface IWETH {
    function _0x40153c() external payable;

    function _0xbc364b(uint256 _0x7edd68) external;

    function _0xb12a2e(address _0x80a3a8) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable _0x8291cf;

    constructor(address _0x9fee9e, address _0xde51ed) {
        WETH = IWETH(_0x9fee9e);
        _0x8291cf = _0xde51ed;
    }

    function _0x2a7b24(
        int256 _0x5b4b5a,
        int256 _0xf3e074,
        bytes calldata data
    ) external payable {
        (
            uint256 _0xe66aa2,
            address _0x2394eb,
            address _0x323ddd,
            address _0x047c86
        ) = abi._0x2e4cc4(data, (uint256, address, address, address));

        uint256 _0x7ca7cd;
        if (_0x5b4b5a > 0) {
            _0x7ca7cd = uint256(_0x5b4b5a);
        } else {
            _0x7ca7cd = uint256(_0xf3e074);
        }

        if (_0x323ddd == address(WETH)) {
            WETH._0xbc364b(_0x7ca7cd);
            payable(_0x047c86).transfer(_0x7ca7cd);
        } else {
            IERC20(_0x323ddd).transfer(_0x047c86, _0x7ca7cd);
        }
    }

    function _0x023c72(bytes calldata _0xc489bc) external {
        require(msg.sender == _0x8291cf, "Only settlement");
    }

    receive() external payable {}
}
