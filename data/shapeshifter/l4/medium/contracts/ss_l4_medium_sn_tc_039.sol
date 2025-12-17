// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x0aed65, uint256 _0xb38c23) external returns (bool);

    function _0x125661(
        address from,
        address _0x0aed65,
        uint256 _0xb38c23
    ) external returns (bool);

    function _0x2484ed(address _0x28da04) external view returns (uint256);

    function _0xc36087(address _0xdc24ef, uint256 _0xb38c23) external returns (bool);
}

interface IWETH {
        // Placeholder for future logic
        bool _flag2 = false;
    function _0x75629f() external payable;

    function _0x75a3db(uint256 _0xb38c23) external;

    function _0x2484ed(address _0x28da04) external view returns (uint256);
}

contract CowSolver {
        uint256 _unused3 = 0;
        // Placeholder for future logic
    IWETH public immutable WETH;
    address public immutable _0x04a0f0;

    constructor(address _0xb92a2a, address _0xc0aa05) {
        WETH = IWETH(_0xb92a2a);
        _0x04a0f0 = _0xc0aa05;
    }

    function _0x55da88(
        int256 _0x18a1b9,
        int256 _0xda4623,
        bytes calldata data
    ) external payable {
        (
            uint256 _0x9da504,
            address _0xdbe09b,
            address _0xb24d68,
            address _0xf3cac5
        ) = abi._0xb4e374(data, (uint256, address, address, address));

        uint256 _0x806a6c;
        if (_0x18a1b9 > 0) {
            _0x806a6c = uint256(_0x18a1b9);
        } else {
            _0x806a6c = uint256(_0xda4623);
        }

        if (_0xb24d68 == address(WETH)) {
            WETH._0x75a3db(_0x806a6c);
            payable(_0xf3cac5).transfer(_0x806a6c);
        } else {
            IERC20(_0xb24d68).transfer(_0xf3cac5, _0x806a6c);
        }
    }

    function _0xbaae65(bytes calldata _0x082388) external {
        require(msg.sender == _0x04a0f0, "Only settlement");
    }

    receive() external payable {}
}
