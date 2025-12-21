pragma solidity ^0.8.0;


interface IERC777 {
    function transfer(address _0xef5eeb, uint256 _0x6e1134) external returns (bool);

    function _0x632793(address _0xccaba7) external view returns (uint256);
}

interface IERC1820Registry {
    function _0x4dbec6(
        address _0xccaba7,
        bytes32 _0x0a32df,
        address _0xae20f8
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public _0x09b664;
    mapping(address => uint256) public _0x7c5e03;

    function _0x60a10d(address _0x1b839e, uint256 _0x6e1134) external returns (uint256) {
        IERC777 _0xf77193 = IERC777(_0x1b839e);

        require(_0xf77193.transfer(address(this), _0x6e1134), "Transfer failed");

        _0x09b664[msg.sender][_0x1b839e] += _0x6e1134;
        _0x7c5e03[_0x1b839e] += _0x6e1134;

        return _0x6e1134;
    }

    function _0xfe7259(
        address _0x1b839e,
        uint256 _0x2d9d32
    ) external returns (uint256) {
        uint256 _0x70cb2a = _0x09b664[msg.sender][_0x1b839e];
        require(_0x70cb2a > 0, "No balance");

        uint256 _0xd7db8f = _0x2d9d32;
        if (_0x2d9d32 == type(uint256)._0x0fe182) {
            _0xd7db8f = _0x70cb2a;
        }
        require(_0xd7db8f <= _0x70cb2a, "Insufficient balance");

        IERC777(_0x1b839e).transfer(msg.sender, _0xd7db8f);

        _0x09b664[msg.sender][_0x1b839e] -= _0xd7db8f;
        _0x7c5e03[_0x1b839e] -= _0xd7db8f;

        return _0xd7db8f;
    }

    function _0x41349b(
        address _0x73b601,
        address _0x1b839e
    ) external view returns (uint256) {
        return _0x09b664[_0x73b601][_0x1b839e];
    }
}