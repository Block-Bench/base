pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xde4b08, uint256 _0x47f5db) external returns (bool);

    function _0x2767ee(
        address from,
        address _0xde4b08,
        uint256 _0x47f5db
    ) external returns (bool);

    function _0x8efd2e(address _0x7e4620) external view returns (uint256);

    function _0x62375a(address _0xfd7ee2, uint256 _0x47f5db) external returns (bool);
}

interface IPendleMarket {
    function _0x70cd8c() external view returns (address[] memory);

    function _0x7f874b() external returns (uint256[] memory);

    function _0x594023(address _0xf58d02) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public _0xaa2c35;
    mapping(address => uint256) public _0x83bb5b;

    function _0x320a17(address _0xa1a104, uint256 _0x47f5db) external {
        IERC20(_0xa1a104)._0x2767ee(msg.sender, address(this), _0x47f5db);
        _0xaa2c35[_0xa1a104][msg.sender] += _0x47f5db;
        _0x83bb5b[_0xa1a104] += _0x47f5db;
    }

    function _0x594023(address _0xa1a104, address _0xf58d02) external {
        uint256[] memory _0x1bc30c = IPendleMarket(_0xa1a104)._0x594023(_0xf58d02);

        for (uint256 i = 0; i < _0x1bc30c.length; i++) {}
    }

    function _0x89ae5f(address _0xa1a104, uint256 _0x47f5db) external {
        require(
            _0xaa2c35[_0xa1a104][msg.sender] >= _0x47f5db,
            "Insufficient balance"
        );

        _0xaa2c35[_0xa1a104][msg.sender] -= _0x47f5db;
        _0x83bb5b[_0xa1a104] -= _0x47f5db;

        IERC20(_0xa1a104).transfer(msg.sender, _0x47f5db);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public _0xecf81b;

    function _0x161bad(address _0xa1a104) external {
        _0xecf81b[_0xa1a104] = true;
    }
}