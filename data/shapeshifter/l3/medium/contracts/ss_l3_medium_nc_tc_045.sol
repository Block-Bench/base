pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xba07b9, uint256 _0x4430db) external returns (bool);

    function _0x49ffdf(
        address from,
        address _0xba07b9,
        uint256 _0x4430db
    ) external returns (bool);

    function _0x81d513(address _0x7e8a37) external view returns (uint256);

    function _0x19cfb0(address _0xd5ee50, uint256 _0x4430db) external returns (bool);
}

interface IPendleMarket {
    function _0x59c9f4() external view returns (address[] memory);

    function _0xaaaf3f() external returns (uint256[] memory);

    function _0x0d4f93(address _0x9bbdce) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public _0xc30372;
    mapping(address => uint256) public _0x00799c;

    function _0x3e77ca(address _0xb20a0b, uint256 _0x4430db) external {
        IERC20(_0xb20a0b)._0x49ffdf(msg.sender, address(this), _0x4430db);
        _0xc30372[_0xb20a0b][msg.sender] += _0x4430db;
        _0x00799c[_0xb20a0b] += _0x4430db;
    }

    function _0x0d4f93(address _0xb20a0b, address _0x9bbdce) external {
        uint256[] memory _0x47b589 = IPendleMarket(_0xb20a0b)._0x0d4f93(_0x9bbdce);

        for (uint256 i = 0; i < _0x47b589.length; i++) {}
    }

    function _0x8a159c(address _0xb20a0b, uint256 _0x4430db) external {
        require(
            _0xc30372[_0xb20a0b][msg.sender] >= _0x4430db,
            "Insufficient balance"
        );

        _0xc30372[_0xb20a0b][msg.sender] -= _0x4430db;
        _0x00799c[_0xb20a0b] -= _0x4430db;

        IERC20(_0xb20a0b).transfer(msg.sender, _0x4430db);
    }
}

contract PendleMarketRegister {
    mapping(address => bool) public _0xc864de;

    function _0xe18934(address _0xb20a0b) external {
        _0xc864de[_0xb20a0b] = true;
    }
}