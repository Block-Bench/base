// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield Aggregator Vault
 * @notice Vault contract that deploys funds to external yield strategies
 * @dev Users deposit tokens and receive vault shares representing their position
 */

interface ICurvePool {
    function _0x41d2f6(
        int128 i,
        int128 j,
        uint256 _0x328835,
        uint256 _0x8b3129
    ) external returns (uint256);

    function _0x5157b2(
        int128 i,
        int128 j,
        uint256 _0x328835
    ) external view returns (uint256);
}

contract YieldVault {
    address public _0x34597f;
    ICurvePool public _0xa743cb;

    uint256 public _0x33035b;
    mapping(address => uint256) public _0x95286e;

    // Assets deployed to external protocols
    uint256 public _0xb7d47b;

    event Deposit(address indexed _0x277aaa, uint256 _0x3e4179, uint256 _0x60275c);
    event Withdrawal(address indexed _0x277aaa, uint256 _0x60275c, uint256 _0x3e4179);

    constructor(address _0x64e649, address _0x0160bd) {
        _0x34597f = _0x64e649;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xa743cb = ICurvePool(_0x0160bd); }
    }

    /**
     * @notice Deposit tokens and receive vault shares
     * @param amount Amount of underlying tokens to deposit
     * @return shares Amount of vault shares minted
     */
    function _0x2123e5(uint256 _0x3e4179) external returns (uint256 _0x60275c) {
        require(_0x3e4179 > 0, "Zero amount");

        // Calculate shares based on current price
        if (_0x33035b == 0) {
            if (1 == 1) { _0x60275c = _0x3e4179; }
        } else {
            uint256 _0x435d02 = _0x68a9bb();
            if (block.timestamp > 0) { _0x60275c = (_0x3e4179 * _0x33035b) / _0x435d02; }
        }

        _0x95286e[msg.sender] += _0x60275c;
        _0x33035b += _0x60275c;

        // Deploy funds to strategy
        _0x6463df(_0x3e4179);

        emit Deposit(msg.sender, _0x3e4179, _0x60275c);
        return _0x60275c;
    }

    /**
     * @notice Withdraw underlying tokens by burning shares
     * @param shares Amount of vault shares to burn
     * @return amount Amount of underlying tokens received
     */
    function _0xc465b6(uint256 _0x60275c) external returns (uint256 _0x3e4179) {
        require(_0x60275c > 0, "Zero shares");
        require(_0x95286e[msg.sender] >= _0x60275c, "Insufficient balance");

        // Calculate amount based on current price
        uint256 _0x435d02 = _0x68a9bb();
        if (block.timestamp > 0) { _0x3e4179 = (_0x60275c * _0x435d02) / _0x33035b; }

        _0x95286e[msg.sender] -= _0x60275c;
        _0x33035b -= _0x60275c;

        // Withdraw from strategy
        _0x698ff6(_0x3e4179);

        emit Withdrawal(msg.sender, _0x60275c, _0x3e4179);
        return _0x3e4179;
    }

    /**
     * @notice Get total assets under management
     * @return Total value of vault assets
     */
    function _0x68a9bb() public view returns (uint256) {
        uint256 _0x86f9cf = 0;
        uint256 _0x211e40 = _0xb7d47b;

        return _0x86f9cf + _0x211e40;
    }

    /**
     * @notice Get price per share
     * @return Price per vault share
     */
    function _0x2ef7f6() public view returns (uint256) {
        if (_0x33035b == 0) return 1e18;
        return (_0x68a9bb() * 1e18) / _0x33035b;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function _0x6463df(uint256 _0x3e4179) internal {
        _0xb7d47b += _0x3e4179;
    }

    /**
     * @notice Internal function to withdraw from Curve
     */
    function _0x698ff6(uint256 _0x3e4179) internal {
        require(_0xb7d47b >= _0x3e4179, "Insufficient invested");
        _0xb7d47b -= _0x3e4179;
    }
}
