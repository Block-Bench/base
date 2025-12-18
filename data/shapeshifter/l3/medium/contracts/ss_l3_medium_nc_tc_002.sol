pragma solidity ^0.8.0;


interface IDiamondCut {
    struct FacetCut {
        address _0x6d9644;
        uint8 _0x3f5df4;
        bytes4[] _0xe604a8;
    }
}

contract GovernanceSystem {

    mapping(address => uint256) public _0x3447d6;
    mapping(address => uint256) public _0x4512b9;


    struct Proposal {
        address _0x2f6433;
        address _0x410f6d;
        bytes data;
        uint256 _0xabb50f;
        uint256 _0x87496d;
        bool _0xb965e5;
    }

    mapping(uint256 => Proposal) public _0xa04c00;
    mapping(uint256 => mapping(address => bool)) public _0x47fa25;
    uint256 public _0x8c1b06;

    uint256 public _0x30572c;


    uint256 constant EMERGENCY_THRESHOLD = 66;

    event ProposalCreated(
        uint256 indexed _0xc6293e,
        address _0x2f6433,
        address _0x410f6d
    );
    event Voted(uint256 indexed _0xc6293e, address _0xe658e3, uint256 _0xe5b31f);
    event ProposalExecuted(uint256 indexed _0xc6293e);


    function _0xba36ef(uint256 _0x7a05c0) external {
        _0x3447d6[msg.sender] += _0x7a05c0;
        _0x4512b9[msg.sender] += _0x7a05c0;
        _0x30572c += _0x7a05c0;
    }


    function _0x5165be(
        IDiamondCut.FacetCut[] calldata,
        address _0x1b4559,
        bytes calldata _0xe6e1fd,
        uint8
    ) external returns (uint256) {
        _0x8c1b06++;

        Proposal storage _0x88e7d5 = _0xa04c00[_0x8c1b06];
        _0x88e7d5._0x2f6433 = msg.sender;
        _0x88e7d5._0x410f6d = _0x1b4559;
        _0x88e7d5.data = _0xe6e1fd;
        _0x88e7d5._0x87496d = block.timestamp;
        _0x88e7d5._0xb965e5 = false;


        _0x88e7d5._0xabb50f = _0x4512b9[msg.sender];
        _0x47fa25[_0x8c1b06][msg.sender] = true;

        emit ProposalCreated(_0x8c1b06, msg.sender, _0x1b4559);
        return _0x8c1b06;
    }


    function _0x11361a(uint256 _0xc6293e) external {
        require(!_0x47fa25[_0xc6293e][msg.sender], "Already voted");
        require(!_0xa04c00[_0xc6293e]._0xb965e5, "Already executed");

        _0xa04c00[_0xc6293e]._0xabb50f += _0x4512b9[msg.sender];
        _0x47fa25[_0xc6293e][msg.sender] = true;

        emit Voted(_0xc6293e, msg.sender, _0x4512b9[msg.sender]);
    }


    function _0xb745ba(uint256 _0xc6293e) external {
        Proposal storage _0x88e7d5 = _0xa04c00[_0xc6293e];
        require(!_0x88e7d5._0xb965e5, "Already executed");

        uint256 _0x9610a8 = (_0x88e7d5._0xabb50f * 100) / _0x30572c;
        require(_0x9610a8 >= EMERGENCY_THRESHOLD, "Insufficient votes");

        _0x88e7d5._0xb965e5 = true;


        (bool _0xac533e, ) = _0x88e7d5._0x410f6d.call(_0x88e7d5.data);
        require(_0xac533e, "Execution failed");

        emit ProposalExecuted(_0xc6293e);
    }
}