// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function _0xd6ea04(address _0xa6fe81) external view returns (uint256);
}

interface ICToken {
    function _0x3e8344(uint256 _0xaa5637) external;

    function _0x391935(uint256 _0x4b65b3) external;

    function _0x837df0(uint256 _0xa73777) external;

    function _0x112d1a() external view returns (address);
}

contract LendingProtocol {
    // Oracle for getting asset prices
    IOracle public _0x892d85;

    // Collateral factors
    mapping(address => uint256) public _0xe18c36;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public _0xb06f2c;

    // User borrows
    mapping(address => mapping(address => uint256)) public _0xb66c0f;

    // Supported markets
    mapping(address => bool) public _0xe01174;

    event Deposit(address indexed _0xb6244f, address indexed _0xa6fe81, uint256 _0x93e4f0);
    event Borrow(address indexed _0xb6244f, address indexed _0xa6fe81, uint256 _0x93e4f0);

    constructor(address _0x08adb9) {
        _0x892d85 = IOracle(_0x08adb9);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function _0x3e8344(address _0xa6fe81, uint256 _0x93e4f0) external {
        require(_0xe01174[_0xa6fe81], "Market not supported");

        // Mint cTokens to user
        _0xb06f2c[msg.sender][_0xa6fe81] += _0x93e4f0;

        emit Deposit(msg.sender, _0xa6fe81, _0x93e4f0);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function _0x391935(address _0xa6fe81, uint256 _0x93e4f0) external {
        require(_0xe01174[_0xa6fe81], "Market not supported");

        // Calculate user's borrowing power
        uint256 _0x1a9dcb = _0x873cc0(msg.sender);

        // Calculate current total borrows value
        uint256 _0x00cbf2 = _0xb08327(msg.sender);

        // Get value of new borrow
        uint256 _0x581121 = (_0x892d85._0xd6ea04(_0xa6fe81) * _0x93e4f0) /
            1e18;

        // Check if user has enough collateral
        require(
            _0x00cbf2 + _0x581121 <= _0x1a9dcb,
            "Insufficient collateral"
        );

        // Update borrow balance
        _0xb66c0f[msg.sender][_0xa6fe81] += _0x93e4f0;

        emit Borrow(msg.sender, _0xa6fe81, _0x93e4f0);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function _0x873cc0(address _0xb6244f) public view returns (uint256) {
        uint256 _0x5afc97 = 0;

        address[] memory _0x9189c0 = new address[](2);

        for (uint256 i = 0; i < _0x9189c0.length; i++) {
            address _0xa6fe81 = _0x9189c0[i];
            uint256 balance = _0xb06f2c[_0xb6244f][_0xa6fe81];

            if (balance > 0) {
                // Get price from oracle
                uint256 _0x4d7dc6 = _0x892d85._0xd6ea04(_0xa6fe81);

                // Calculate value
                uint256 value = (balance * _0x4d7dc6) / 1e18;

                // Apply collateral factor
                uint256 _0x8094d9 = (value * _0xe18c36[_0xa6fe81]) / 1e18;

                _0x5afc97 += _0x8094d9;
            }
        }

        return _0x5afc97;
    }

    /**
     * @notice Calculate user's total borrow value
     * @param user The user address
     * @return Total borrow value in USD
     */
    function _0xb08327(address _0xb6244f) public view returns (uint256) {
        uint256 _0x98cd20 = 0;

        address[] memory _0x9189c0 = new address[](2);

        for (uint256 i = 0; i < _0x9189c0.length; i++) {
            address _0xa6fe81 = _0x9189c0[i];
            uint256 _0xf4fd6b = _0xb66c0f[_0xb6244f][_0xa6fe81];

            if (_0xf4fd6b > 0) {
                uint256 _0x4d7dc6 = _0x892d85._0xd6ea04(_0xa6fe81);
                uint256 value = (_0xf4fd6b * _0x4d7dc6) / 1e18;
                _0x98cd20 += value;
            }
        }

        return _0x98cd20;
    }

    /**
     * @notice Add a supported market
     * @param cToken The cToken to add
     * @param collateralFactor The collateral factor
     */
    function _0xe7ea29(address _0xa6fe81, uint256 _0x79f7ba) external {
        _0xe01174[_0xa6fe81] = true;
        _0xe18c36[_0xa6fe81] = _0x79f7ba;
    }
}
