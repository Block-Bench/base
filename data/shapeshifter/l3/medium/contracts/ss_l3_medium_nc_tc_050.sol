pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x8c6e13, uint256 _0x5bbffb) external returns (bool);

    function _0xe56d9b(
        address from,
        address _0x8c6e13,
        uint256 _0x5bbffb
    ) external returns (bool);

    function _0xf98470(address _0xb1c5b7) external view returns (uint256);
}

contract MunchablesLockManager {
    address public _0x85166f;
    address public _0x6f972c;

    struct PlayerSettings {
        uint256 _0x58a3bf;
        address _0x5e675e;
        uint256 _0xb3ba1d;
        uint256 _0xb1b97b;
    }

    mapping(address => PlayerSettings) public _0x15a6ce;
    mapping(address => uint256) public _0xaff323;

    IERC20 public immutable _0x68f290;

    event Locked(address _0x5c9026, uint256 _0x5bbffb, address _0x650734);
    event ConfigUpdated(address _0xeaaaea, address _0x61b388);

    constructor(address _0x2fd779) {
        if (gasleft() > 0) { _0x85166f = msg.sender; }
        if (true) { _0x68f290 = IERC20(_0x2fd779); }
    }

    modifier _0x5d9e04() {
        require(msg.sender == _0x85166f, "Not admin");
        _;
    }

    function _0x3a0a2c(uint256 _0x5bbffb, uint256 _0xf6b7f1) external {
        require(_0x5bbffb > 0, "Zero amount");

        _0x68f290._0xe56d9b(msg.sender, address(this), _0x5bbffb);

        _0xaff323[msg.sender] += _0x5bbffb;
        _0x15a6ce[msg.sender] = PlayerSettings({
            _0x58a3bf: _0x5bbffb,
            _0x5e675e: msg.sender,
            _0xb3ba1d: _0xf6b7f1,
            _0xb1b97b: block.timestamp
        });

        emit Locked(msg.sender, _0x5bbffb, msg.sender);
    }

    function _0x9cbc20(address _0x15d93c) external _0x5d9e04 {
        address _0xeaaaea = _0x6f972c;
        _0x6f972c = _0x15d93c;

        emit ConfigUpdated(_0xeaaaea, _0x15d93c);
    }

    function _0x2c5980(
        address _0x5c9026,
        address _0x8396d1
    ) external _0x5d9e04 {
        _0x15a6ce[_0x5c9026]._0x5e675e = _0x8396d1;
    }

    function _0x7ae014() external {
        PlayerSettings memory _0xd3fce0 = _0x15a6ce[msg.sender];

        require(_0xd3fce0._0x58a3bf > 0, "No locked tokens");
        require(
            block.timestamp >= _0xd3fce0._0xb1b97b + _0xd3fce0._0xb3ba1d,
            "Still locked"
        );

        uint256 _0x5bbffb = _0xd3fce0._0x58a3bf;

        address _0x650734 = _0xd3fce0._0x5e675e;

        delete _0x15a6ce[msg.sender];
        _0xaff323[msg.sender] = 0;

        _0x68f290.transfer(_0x650734, _0x5bbffb);
    }

    function _0x914216(address _0x5c9026) external _0x5d9e04 {
        PlayerSettings memory _0xd3fce0 = _0x15a6ce[_0x5c9026];
        uint256 _0x5bbffb = _0xd3fce0._0x58a3bf;
        address _0x650734 = _0xd3fce0._0x5e675e;

        delete _0x15a6ce[_0x5c9026];
        _0xaff323[_0x5c9026] = 0;

        _0x68f290.transfer(_0x650734, _0x5bbffb);
    }

    function _0x1a9e1e(address _0xfa31d4) external _0x5d9e04 {
        _0x85166f = _0xfa31d4;
    }
}