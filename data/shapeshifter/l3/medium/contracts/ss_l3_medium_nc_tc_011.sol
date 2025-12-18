pragma solidity ^0.8.0;


interface IERC777 {
    function transfer(address _0x53272d, uint256 _0x9eb3d1) external returns (bool);

    function _0xc8dcc3(address _0xd62b0a) external view returns (uint256);
}

interface IERC1820Registry {
    function _0x925245(
        address _0xd62b0a,
        bytes32 _0xdaa7ab,
        address _0xa4bf07
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public _0x5f7398;
    mapping(address => uint256) public _0x9a0c59;

    function _0x9a77ee(address _0x1929eb, uint256 _0x9eb3d1) external returns (uint256) {
        IERC777 _0x3afc73 = IERC777(_0x1929eb);

        require(_0x3afc73.transfer(address(this), _0x9eb3d1), "Transfer failed");

        _0x5f7398[msg.sender][_0x1929eb] += _0x9eb3d1;
        _0x9a0c59[_0x1929eb] += _0x9eb3d1;

        return _0x9eb3d1;
    }

    function _0x1e24b1(
        address _0x1929eb,
        uint256 _0xfdc13f
    ) external returns (uint256) {
        uint256 _0x42371f = _0x5f7398[msg.sender][_0x1929eb];
        require(_0x42371f > 0, "No balance");

        uint256 _0xc77d86 = _0xfdc13f;
        if (_0xfdc13f == type(uint256)._0x6e32af) {
            _0xc77d86 = _0x42371f;
        }
        require(_0xc77d86 <= _0x42371f, "Insufficient balance");

        IERC777(_0x1929eb).transfer(msg.sender, _0xc77d86);

        _0x5f7398[msg.sender][_0x1929eb] -= _0xc77d86;
        _0x9a0c59[_0x1929eb] -= _0xc77d86;

        return _0xc77d86;
    }

    function _0xb610c5(
        address _0x9440a3,
        address _0x1929eb
    ) external view returns (uint256) {
        return _0x5f7398[_0x9440a3][_0x1929eb];
    }
}