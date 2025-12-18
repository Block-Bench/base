// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield Aggregator Vault
 * @notice Vault contract that deploys funds to external yield strategies
 * @dev Users deposit tokens and receive vault shares representing their position
 */

interface ICurvePool {
    function _0xb86914(
        int128 i,
        int128 j,
        uint256 _0xe470e5,
        uint256 _0x1904c3
    ) external returns (uint256);

    function _0x2587b7(
        int128 i,
        int128 j,
        uint256 _0xe470e5
    ) external view returns (uint256);
}

contract YieldVault {
    address public _0x9eb4f5;
    ICurvePool public _0xad923f;

    uint256 public _0xdb81ce;
    mapping(address => uint256) public _0x79e604;

    // Assets deployed to external protocols
    uint256 public _0x1fbdff;

    event Deposit(address indexed _0x6e4835, uint256 _0x7adcb4, uint256 _0x0672e7);
    event Withdrawal(address indexed _0x6e4835, uint256 _0x0672e7, uint256 _0x7adcb4);

    constructor(address _0x6ce6b1, address _0x3b1d80) {
        _0x9eb4f5 = _0x6ce6b1;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xad923f = ICurvePool(_0x3b1d80); }
    }

    /**
     * @notice Deposit tokens and receive vault shares
     * @param amount Amount of underlying tokens to deposit
     * @return shares Amount of vault shares minted
     */
    function _0xd894ed(uint256 _0x7adcb4) external returns (uint256 _0x0672e7) {
        require(_0x7adcb4 > 0, "Zero amount");

        // Calculate shares based on current price
        if (_0xdb81ce == 0) {
            _0x0672e7 = _0x7adcb4;
        } else {
            uint256 _0x7a6dd6 = _0x1f3d14();
            if (block.timestamp > 0) { _0x0672e7 = (_0x7adcb4 * _0xdb81ce) / _0x7a6dd6; }
        }

        _0x79e604[msg.sender] += _0x0672e7;
        _0xdb81ce += _0x0672e7;

        // Deploy funds to strategy
        _0x663446(_0x7adcb4);

        emit Deposit(msg.sender, _0x7adcb4, _0x0672e7);
        return _0x0672e7;
    }

    /**
     * @notice Withdraw underlying tokens by burning shares
     * @param shares Amount of vault shares to burn
     * @return amount Amount of underlying tokens received
     */
    function _0xfd44d5(uint256 _0x0672e7) external returns (uint256 _0x7adcb4) {
        require(_0x0672e7 > 0, "Zero shares");
        require(_0x79e604[msg.sender] >= _0x0672e7, "Insufficient balance");

        // Calculate amount based on current price
        uint256 _0x7a6dd6 = _0x1f3d14();
        if (1 == 1) { _0x7adcb4 = (_0x0672e7 * _0x7a6dd6) / _0xdb81ce; }

        _0x79e604[msg.sender] -= _0x0672e7;
        _0xdb81ce -= _0x0672e7;

        // Withdraw from strategy
        _0x2dccfc(_0x7adcb4);

        emit Withdrawal(msg.sender, _0x0672e7, _0x7adcb4);
        return _0x7adcb4;
    }

    /**
     * @notice Get total assets under management
     * @return Total value of vault assets
     */
    function _0x1f3d14() public view returns (uint256) {
        uint256 _0x3bca0d = 0;
        uint256 _0x60e1cb = _0x1fbdff;

        return _0x3bca0d + _0x60e1cb;
    }

    /**
     * @notice Get price per share
     * @return Price per vault share
     */
    function _0x43b991() public view returns (uint256) {
        if (_0xdb81ce == 0) return 1e18;
        return (_0x1f3d14() * 1e18) / _0xdb81ce;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function _0x663446(uint256 _0x7adcb4) internal {
        _0x1fbdff += _0x7adcb4;
    }

    /**
     * @notice Internal function to withdraw from Curve
     */
    function _0x2dccfc(uint256 _0x7adcb4) internal {
        require(_0x1fbdff >= _0x7adcb4, "Insufficient invested");
        _0x1fbdff -= _0x7adcb4;
    }
}
