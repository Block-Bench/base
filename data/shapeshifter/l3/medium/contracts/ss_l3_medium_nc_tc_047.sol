pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xe05479, uint256 _0xcef0c8) external returns (bool);

    function _0x68059a(address _0x968c6a) external view returns (uint256);
}

contract PlayDappToken {
    string public _0xf28fa2 = "PlayDapp Token";
    string public _0x3b9686 = "PLA";
    uint8 public _0xb0c630 = 18;

    uint256 public _0x8018d3;

    address public _0x7b592a;

    mapping(address => uint256) public _0x68059a;
    mapping(address => mapping(address => uint256)) public _0xaf868a;

    event Transfer(address indexed from, address indexed _0xe05479, uint256 value);
    event Approval(
        address indexed _0x126b73,
        address indexed _0x021bc5,
        uint256 value
    );
    event Minted(address indexed _0xe05479, uint256 _0xcef0c8);

    constructor() {
        _0x7b592a = msg.sender;
        _0x9da776(msg.sender, 700_000_000 * 10 ** 18);
    }

    modifier _0x37f7dc() {
        require(msg.sender == _0x7b592a, "Not minter");
        _;
    }

    function _0x3d2ce6(address _0xe05479, uint256 _0xcef0c8) external _0x37f7dc {
        _0x9da776(_0xe05479, _0xcef0c8);
        emit Minted(_0xe05479, _0xcef0c8);
    }

    function _0x9da776(address _0xe05479, uint256 _0xcef0c8) internal {
        require(_0xe05479 != address(0), "Mint to zero address");

        _0x8018d3 += _0xcef0c8;
        _0x68059a[_0xe05479] += _0xcef0c8;

        emit Transfer(address(0), _0xe05479, _0xcef0c8);
    }

    function _0xecbeab(address _0x78eaca) external _0x37f7dc {
        _0x7b592a = _0x78eaca;
    }

    function transfer(address _0xe05479, uint256 _0xcef0c8) external returns (bool) {
        require(_0x68059a[msg.sender] >= _0xcef0c8, "Insufficient balance");
        _0x68059a[msg.sender] -= _0xcef0c8;
        _0x68059a[_0xe05479] += _0xcef0c8;
        emit Transfer(msg.sender, _0xe05479, _0xcef0c8);
        return true;
    }

    function _0x2dd681(address _0x021bc5, uint256 _0xcef0c8) external returns (bool) {
        _0xaf868a[msg.sender][_0x021bc5] = _0xcef0c8;
        emit Approval(msg.sender, _0x021bc5, _0xcef0c8);
        return true;
    }

    function _0xed0b37(
        address from,
        address _0xe05479,
        uint256 _0xcef0c8
    ) external returns (bool) {
        require(_0x68059a[from] >= _0xcef0c8, "Insufficient balance");
        require(
            _0xaf868a[from][msg.sender] >= _0xcef0c8,
            "Insufficient allowance"
        );

        _0x68059a[from] -= _0xcef0c8;
        _0x68059a[_0xe05479] += _0xcef0c8;
        _0xaf868a[from][msg.sender] -= _0xcef0c8;

        emit Transfer(from, _0xe05479, _0xcef0c8);
        return true;
    }
}