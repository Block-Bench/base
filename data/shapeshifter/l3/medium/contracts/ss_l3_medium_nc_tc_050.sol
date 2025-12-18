pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x162ede, uint256 _0x7df3d9) external returns (bool);

    function _0xab3a47(
        address from,
        address _0x162ede,
        uint256 _0x7df3d9
    ) external returns (bool);

    function _0xad3944(address _0xbb9b77) external view returns (uint256);
}

contract MunchablesLockManager {
    address public _0x0577ea;
    address public _0xfc66d8;

    struct PlayerSettings {
        uint256 _0x8b9c34;
        address _0x19c4eb;
        uint256 _0x3d116b;
        uint256 _0xdbaa4e;
    }

    mapping(address => PlayerSettings) public _0x230f65;
    mapping(address => uint256) public _0x9447e5;

    IERC20 public immutable _0xc23fb5;

    event Locked(address _0xa02e3a, uint256 _0x7df3d9, address _0x27d483);
    event ConfigUpdated(address _0x409237, address _0xa484cc);

    constructor(address _0x534a43) {
        _0x0577ea = msg.sender;
        _0xc23fb5 = IERC20(_0x534a43);
    }

    modifier _0x692d71() {
        require(msg.sender == _0x0577ea, "Not admin");
        _;
    }

    function _0x1ab300(uint256 _0x7df3d9, uint256 _0x6e2f40) external {
        require(_0x7df3d9 > 0, "Zero amount");

        _0xc23fb5._0xab3a47(msg.sender, address(this), _0x7df3d9);

        _0x9447e5[msg.sender] += _0x7df3d9;
        _0x230f65[msg.sender] = PlayerSettings({
            _0x8b9c34: _0x7df3d9,
            _0x19c4eb: msg.sender,
            _0x3d116b: _0x6e2f40,
            _0xdbaa4e: block.timestamp
        });

        emit Locked(msg.sender, _0x7df3d9, msg.sender);
    }

    function _0xd34323(address _0x35b771) external _0x692d71 {
        address _0x409237 = _0xfc66d8;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xfc66d8 = _0x35b771; }

        emit ConfigUpdated(_0x409237, _0x35b771);
    }

    function _0xab5d9d(
        address _0xa02e3a,
        address _0xd1fccc
    ) external _0x692d71 {
        _0x230f65[_0xa02e3a]._0x19c4eb = _0xd1fccc;
    }

    function _0x347cd8() external {
        PlayerSettings memory _0x5d02a3 = _0x230f65[msg.sender];

        require(_0x5d02a3._0x8b9c34 > 0, "No locked tokens");
        require(
            block.timestamp >= _0x5d02a3._0xdbaa4e + _0x5d02a3._0x3d116b,
            "Still locked"
        );

        uint256 _0x7df3d9 = _0x5d02a3._0x8b9c34;

        address _0x27d483 = _0x5d02a3._0x19c4eb;

        delete _0x230f65[msg.sender];
        _0x9447e5[msg.sender] = 0;

        _0xc23fb5.transfer(_0x27d483, _0x7df3d9);
    }

    function _0xd938b1(address _0xa02e3a) external _0x692d71 {
        PlayerSettings memory _0x5d02a3 = _0x230f65[_0xa02e3a];
        uint256 _0x7df3d9 = _0x5d02a3._0x8b9c34;
        address _0x27d483 = _0x5d02a3._0x19c4eb;

        delete _0x230f65[_0xa02e3a];
        _0x9447e5[_0xa02e3a] = 0;

        _0xc23fb5.transfer(_0x27d483, _0x7df3d9);
    }

    function _0xc49bd7(address _0xf477ea) external _0x692d71 {
        _0x0577ea = _0xf477ea;
    }
}