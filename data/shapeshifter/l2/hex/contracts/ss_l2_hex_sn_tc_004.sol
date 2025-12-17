// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Yield Aggregator Vault
 * @notice Vault contract that deploys funds to external yield strategies
 * @dev Users deposit tokens and receive vault shares representing their position
 */

interface ICurvePool {
    function _0x47ad6d(
        int128 i,
        int128 j,
        uint256 _0x615949,
        uint256 _0x295dd3
    ) external returns (uint256);

    function _0xf72700(
        int128 i,
        int128 j,
        uint256 _0x615949
    ) external view returns (uint256);
}

contract YieldVault {
    address public _0x27aaf7;
    ICurvePool public _0x5ef325;

    uint256 public _0x7d39a6;
    mapping(address => uint256) public _0xd78fe6;

    // Assets deployed to external protocols
    uint256 public _0xa979a7;

    event Deposit(address indexed _0x9330dd, uint256 _0x0908aa, uint256 _0xf3763c);
    event Withdrawal(address indexed _0x9330dd, uint256 _0xf3763c, uint256 _0x0908aa);

    constructor(address _0xd8ec24, address _0x8df8e3) {
        _0x27aaf7 = _0xd8ec24;
        _0x5ef325 = ICurvePool(_0x8df8e3);
    }

    /**
     * @notice Deposit tokens and receive vault shares
     * @param amount Amount of underlying tokens to deposit
     * @return shares Amount of vault shares minted
     */
    function _0xdaf54b(uint256 _0x0908aa) external returns (uint256 _0xf3763c) {
        require(_0x0908aa > 0, "Zero amount");

        // Calculate shares based on current price
        if (_0x7d39a6 == 0) {
            _0xf3763c = _0x0908aa;
        } else {
            uint256 _0x9f9cb3 = _0xe2b9c8();
            _0xf3763c = (_0x0908aa * _0x7d39a6) / _0x9f9cb3;
        }

        _0xd78fe6[msg.sender] += _0xf3763c;
        _0x7d39a6 += _0xf3763c;

        // Deploy funds to strategy
        _0xea3aad(_0x0908aa);

        emit Deposit(msg.sender, _0x0908aa, _0xf3763c);
        return _0xf3763c;
    }

    /**
     * @notice Withdraw underlying tokens by burning shares
     * @param shares Amount of vault shares to burn
     * @return amount Amount of underlying tokens received
     */
    function _0x9f9e52(uint256 _0xf3763c) external returns (uint256 _0x0908aa) {
        require(_0xf3763c > 0, "Zero shares");
        require(_0xd78fe6[msg.sender] >= _0xf3763c, "Insufficient balance");

        // Calculate amount based on current price
        uint256 _0x9f9cb3 = _0xe2b9c8();
        _0x0908aa = (_0xf3763c * _0x9f9cb3) / _0x7d39a6;

        _0xd78fe6[msg.sender] -= _0xf3763c;
        _0x7d39a6 -= _0xf3763c;

        // Withdraw from strategy
        _0x57cc9e(_0x0908aa);

        emit Withdrawal(msg.sender, _0xf3763c, _0x0908aa);
        return _0x0908aa;
    }

    /**
     * @notice Get total assets under management
     * @return Total value of vault assets
     */
    function _0xe2b9c8() public view returns (uint256) {
        uint256 _0x907b05 = 0;
        uint256 _0x47b97a = _0xa979a7;

        return _0x907b05 + _0x47b97a;
    }

    /**
     * @notice Get price per share
     * @return Price per vault share
     */
    function _0x961685() public view returns (uint256) {
        if (_0x7d39a6 == 0) return 1e18;
        return (_0xe2b9c8() * 1e18) / _0x7d39a6;
    }

    /**
     * @notice Internal function to invest in Curve
     */
    function _0xea3aad(uint256 _0x0908aa) internal {
        _0xa979a7 += _0x0908aa;
    }

    /**
     * @notice Internal function to withdraw from Curve
     */
    function _0x57cc9e(uint256 _0x0908aa) internal {
        require(_0xa979a7 >= _0x0908aa, "Insufficient invested");
        _0xa979a7 -= _0x0908aa;
    }
}
