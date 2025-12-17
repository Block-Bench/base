// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Decentralized lending and borrowing platform
 * @dev Users can deposit collateral and borrow against it
 */

interface IOracle {
    function _0x6b5bd9(address _0xcc6a33) external view returns (uint256);
}

interface ICToken {
    function _0x3783a1(uint256 _0x9e7435) external;

    function _0x6aa6fe(uint256 _0xfb82bc) external;

    function _0x4f6527(uint256 _0xa883c4) external;

    function _0x17ac18() external view returns (address);
}

contract LendingProtocol {
    // Oracle for getting asset prices
    IOracle public _0x29a323;

    // Collateral factors
    mapping(address => uint256) public _0x3e2e34;

    // User deposits (cToken balances)
    mapping(address => mapping(address => uint256)) public _0x5c9228;

    // User borrows
    mapping(address => mapping(address => uint256)) public _0x6cb295;

    // Supported markets
    mapping(address => bool) public _0x7f2d4d;

    event Deposit(address indexed _0xc30ea6, address indexed _0xcc6a33, uint256 _0xebab5d);
    event Borrow(address indexed _0xc30ea6, address indexed _0xcc6a33, uint256 _0xebab5d);

    constructor(address _0x6a2eed) {
        _0x29a323 = IOracle(_0x6a2eed);
    }

    /**
     * @notice Mint cTokens by depositing underlying assets
     * @param cToken The cToken to mint
     * @param amount Amount of underlying to deposit
     */
    function _0x3783a1(address _0xcc6a33, uint256 _0xebab5d) external {
        require(_0x7f2d4d[_0xcc6a33], "Market not supported");

        // Mint cTokens to user
        _0x5c9228[msg.sender][_0xcc6a33] += _0xebab5d;

        emit Deposit(msg.sender, _0xcc6a33, _0xebab5d);
    }

    /**
     * @notice Borrow assets against collateral
     * @param cToken The cToken to borrow
     * @param amount Amount to borrow
     */
    function _0x6aa6fe(address _0xcc6a33, uint256 _0xebab5d) external {
        require(_0x7f2d4d[_0xcc6a33], "Market not supported");

        // Calculate user's borrowing power
        uint256 _0x257c89 = _0x68e6d3(msg.sender);

        // Calculate current total borrows value
        uint256 _0x5f0b38 = _0x22ba6d(msg.sender);

        // Get value of new borrow
        uint256 _0x86008a = (_0x29a323._0x6b5bd9(_0xcc6a33) * _0xebab5d) /
            1e18;

        // Check if user has enough collateral
        require(
            _0x5f0b38 + _0x86008a <= _0x257c89,
            "Insufficient collateral"
        );

        // Update borrow balance
        _0x6cb295[msg.sender][_0xcc6a33] += _0xebab5d;

        emit Borrow(msg.sender, _0xcc6a33, _0xebab5d);
    }

    /**
     * @notice Calculate user's total borrowing power
     * @param user The user address
     * @return Total borrowing power in USD
     */
    function _0x68e6d3(address _0xc30ea6) public view returns (uint256) {
        uint256 _0xbb5cd1 = 0;

        address[] memory _0x4924ae = new address[](2);

        for (uint256 i = 0; i < _0x4924ae.length; i++) {
            address _0xcc6a33 = _0x4924ae[i];
            uint256 balance = _0x5c9228[_0xc30ea6][_0xcc6a33];

            if (balance > 0) {
                // Get price from oracle
                uint256 _0x46d87a = _0x29a323._0x6b5bd9(_0xcc6a33);

                // Calculate value
                uint256 value = (balance * _0x46d87a) / 1e18;

                // Apply collateral factor
                uint256 _0x97fdac = (value * _0x3e2e34[_0xcc6a33]) / 1e18;

                _0xbb5cd1 += _0x97fdac;
            }
        }

        return _0xbb5cd1;
    }

    /**
     * @notice Calculate user's total borrow value
     * @param user The user address
     * @return Total borrow value in USD
     */
    function _0x22ba6d(address _0xc30ea6) public view returns (uint256) {
        uint256 _0x9db687 = 0;

        address[] memory _0x4924ae = new address[](2);

        for (uint256 i = 0; i < _0x4924ae.length; i++) {
            address _0xcc6a33 = _0x4924ae[i];
            uint256 _0x458826 = _0x6cb295[_0xc30ea6][_0xcc6a33];

            if (_0x458826 > 0) {
                uint256 _0x46d87a = _0x29a323._0x6b5bd9(_0xcc6a33);
                uint256 value = (_0x458826 * _0x46d87a) / 1e18;
                _0x9db687 += value;
            }
        }

        return _0x9db687;
    }

    /**
     * @notice Add a supported market
     * @param cToken The cToken to add
     * @param collateralFactor The collateral factor
     */
    function _0x4f2c8e(address _0xcc6a33, uint256 _0x6e3749) external {
        _0x7f2d4d[_0xcc6a33] = true;
        _0x3e2e34[_0xcc6a33] = _0x6e3749;
    }
}
