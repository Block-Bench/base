pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x683424, uint256 _0x43ce44) external returns (bool);

    function _0x12dfff(address _0x5bf6ee) external view returns (uint256);
}

contract PlayDappToken {
    string public _0xbedade = "PlayDapp Token";
    string public _0x6cd379 = "PLA";
    uint8 public _0x8b348a = 18;

    uint256 public _0xbbb781;

    address public _0x1de7ac;

    mapping(address => uint256) public _0x12dfff;
    mapping(address => mapping(address => uint256)) public _0xe55df8;

    event Transfer(address indexed from, address indexed _0x683424, uint256 value);
    event Approval(
        address indexed _0x68254f,
        address indexed _0x7cc5b5,
        uint256 value
    );
    event Minted(address indexed _0x683424, uint256 _0x43ce44);

    constructor() {
        _0x1de7ac = msg.sender;
        _0x7257ba(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier _0x919d4d() {
        require(msg.sender == _0x1de7ac, "Not minter");
        _;
    }

    function _0x1dac0e(address _0x683424, uint256 _0x43ce44) external _0x919d4d {
        _0x7257ba(_0x683424, _0x43ce44);
        emit Minted(_0x683424, _0x43ce44);
    }

    function _0x7257ba(address _0x683424, uint256 _0x43ce44) internal {
        require(_0x683424 != address(0), "Mint to zero address");

        _0xbbb781 += _0x43ce44;
        _0x12dfff[_0x683424] += _0x43ce44;

        emit Transfer(address(0), _0x683424, _0x43ce44);
    }

    function _0x86340b(address _0x03e504) external _0x919d4d {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x1de7ac = _0x03e504; }
    }

    function transfer(address _0x683424, uint256 _0x43ce44) external returns (bool) {
        require(_0x12dfff[msg.sender] >= _0x43ce44, "Insufficient balance");
        _0x12dfff[msg.sender] -= _0x43ce44;
        _0x12dfff[_0x683424] += _0x43ce44;
        emit Transfer(msg.sender, _0x683424, _0x43ce44);
        return true;
    }

    function _0x3305d8(address _0x7cc5b5, uint256 _0x43ce44) external returns (bool) {
        _0xe55df8[msg.sender][_0x7cc5b5] = _0x43ce44;
        emit Approval(msg.sender, _0x7cc5b5, _0x43ce44);
        return true;
    }

    function _0xeb26c1(
        address from,
        address _0x683424,
        uint256 _0x43ce44
    ) external returns (bool) {
        require(_0x12dfff[from] >= _0x43ce44, "Insufficient balance");
        require(
            _0xe55df8[from][msg.sender] >= _0x43ce44,
            "Insufficient allowance"
        );

        _0x12dfff[from] -= _0x43ce44;
        _0x12dfff[_0x683424] += _0x43ce44;
        _0xe55df8[from][msg.sender] -= _0x43ce44;

        emit Transfer(from, _0x683424, _0x43ce44);
        return true;
    }
}