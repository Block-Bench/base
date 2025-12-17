// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function _0xd74c84(address _0xb2fecd) external view returns (uint256);
}

interface ICToken {
    function _0xe34ab4(uint256 _0x3596fa) external;

    function _0xb5e9c5(uint256 _0x4790dc) external;

    function _0x9e43ad(uint256 _0x5e4761) external;

    function _0xa1c7d2() external view returns (address);
}

contract LendingProtocol {
    // Oracle for getting asset prices
    IOracle public _0x5e72f1;

    // Collateral factors
    mapping(address => uint256) public _0xd8ff41;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public _0x0d9c2d;

    // User borrows
    mapping(address => mapping(address => uint256)) public _0x950fd9;

    // Supported markets
    mapping(address => bool) public _0xac7e27;

    event Deposit(address indexed _0xced3df, address indexed _0xb2fecd, uint256 _0x1dbf43);
    event Borrow(address indexed _0xced3df, address indexed _0xb2fecd, uint256 _0x1dbf43);

    constructor(address _0x674ef7) {
        _0x5e72f1 = IOracle(_0x674ef7);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function _0xe34ab4(address _0xb2fecd, uint256 _0x1dbf43) external {
        require(_0xac7e27[_0xb2fecd], "Market not supported");

        // Mint cTokens to user
        _0x0d9c2d[msg.sender][_0xb2fecd] += _0x1dbf43;

        emit Deposit(msg.sender, _0xb2fecd, _0x1dbf43);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function _0xb5e9c5(address _0xb2fecd, uint256 _0x1dbf43) external {
        require(_0xac7e27[_0xb2fecd], "Market not supported");

        // Calculate user's borrowing power
        uint256 _0x35ae43 = _0xef3338(msg.sender);

        // Calculate current total borrows value
        uint256 _0x94133e = _0xfabd1c(msg.sender);

        // Get value of new borrow
        uint256 _0xad4112 = (_0x5e72f1._0xd74c84(_0xb2fecd) * _0x1dbf43) /
            1e18;

        // Check if user has enough collateral
        require(
            _0x94133e + _0xad4112 <= _0x35ae43,
            "Insufficient collateral"
        );

        // Update borrow balance
        _0x950fd9[msg.sender][_0xb2fecd] += _0x1dbf43;

        emit Borrow(msg.sender, _0xb2fecd, _0x1dbf43);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function _0xef3338(address _0xced3df) public view returns (uint256) {
        uint256 _0x55827d = 0;

        address[] memory _0xaf780f = new address[](2);

        for (uint256 i = 0; i < _0xaf780f.length; i++) {
            address _0xb2fecd = _0xaf780f[i];
            uint256 balance = _0x0d9c2d[_0xced3df][_0xb2fecd];

            if (balance > 0) {
                // Get price from oracle
                uint256 _0xac212f = _0x5e72f1._0xd74c84(_0xb2fecd);

                // Calculate value
                uint256 value = (balance * _0xac212f) / 1e18;

                // Apply collateral factor
                uint256 _0x6e66b5 = (value * _0xd8ff41[_0xb2fecd]) / 1e18;

                _0x55827d += _0x6e66b5;
            }
        }

        return _0x55827d;
    }

    /**
     * @notice Calculate user's total borrow value
     * @param user The user address
     * @return Total borrow value in USD
     */
    function _0xfabd1c(address _0xced3df) public view returns (uint256) {
        uint256 _0x323dcd = 0;

        address[] memory _0xaf780f = new address[](2);

        for (uint256 i = 0; i < _0xaf780f.length; i++) {
            address _0xb2fecd = _0xaf780f[i];
            uint256 _0x1f75bb = _0x950fd9[_0xced3df][_0xb2fecd];

            if (_0x1f75bb > 0) {
                uint256 _0xac212f = _0x5e72f1._0xd74c84(_0xb2fecd);
                uint256 value = (_0x1f75bb * _0xac212f) / 1e18;
                _0x323dcd += value;
            }
        }

        return _0x323dcd;
    }

    /**
     * @notice Add a supported market
     * @param cToken The cToken to add
     * @param collateralFactor The collateral factor
     */
    function _0xe99843(address _0xb2fecd, uint256 _0x99e7be) external {
        _0xac7e27[_0xb2fecd] = true;
        _0xd8ff41[_0xb2fecd] = _0x99e7be;
    }
}
