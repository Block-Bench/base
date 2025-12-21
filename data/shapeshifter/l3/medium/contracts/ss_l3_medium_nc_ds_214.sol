pragma solidity ^0.4.24;

contract ERC20 {
    function _0x6122ae() constant returns (uint _0x391956);
    function _0xbb5ae9( address _0x6370f1 ) constant returns (uint value);
    function _0x666f86( address _0xe6ace0, address _0x0761c5 ) constant returns (uint _0xb44086);

    function transfer( address _0x3c52c1, uint value) returns (bool _0xe1ca6a);
    function _0x0f6b35( address from, address _0x3c52c1, uint value) returns (bool _0xe1ca6a);
    function _0xdac55a( address _0x0761c5, uint value ) returns (bool _0xe1ca6a);

    event Transfer( address indexed from, address indexed _0x3c52c1, uint value);
    event Approval( address indexed _0xe6ace0, address indexed _0x0761c5, uint value);
}
contract Ownable {
  address public _0xe6ace0;

  function Ownable() {
    _0xe6ace0 = msg.sender;
  }

  modifier _0xdf6122() {
    require(msg.sender == _0xe6ace0);
    _;
  }

  function _0xc1b5e3(address _0x5dff72) _0xdf6122 {
    if (_0x5dff72 != address(0)) {
      _0xe6ace0 = _0x5dff72;
    }
  }

}


contract ERC721 {

    function _0x6122ae() public view returns (uint256 _0xa4b1a8);
    function _0xbb5ae9(address _0xb09ea4) public view returns (uint256 balance);
    function _0x797663(uint256 _0xf59b95) external view returns (address _0xe6ace0);
    function _0xdac55a(address _0x21aca8, uint256 _0xf59b95) external;
    function transfer(address _0x21aca8, uint256 _0xf59b95) external;
    function _0x0f6b35(address _0xb45b06, address _0x21aca8, uint256 _0xf59b95) external;


    event Transfer(address from, address _0x3c52c1, uint256 _0xa2cc15);
    event Approval(address _0xe6ace0, address _0xce5e73, uint256 _0xa2cc15);


    function _0xb95486(bytes4 _0xa8760c) external view returns (bool);
}

contract GeneScienceInterface {

    function _0xcb2b20() public pure returns (bool);


    function _0xf2cda2(uint256[2] _0xb20c11, uint256[2] _0xd9339e,uint256 _0x49708c,uint256 _0x469c0c, uint256 _0x92eec9) public returns (uint256[2]);

    function _0x7fe8ce(uint256[2] _0x4ebe2e) public view returns(uint256);


    function _0x326ff2(uint256[2] _0x4ebe2e) public view returns(uint256);


    function _0xf44b51(uint256[2] _0x4ebe2e) public view returns(uint256);

    function _0x1ff94a(uint256[2] _0x44dc75) public returns(uint256[2]);
}


contract PandaAccessControl {


    event ContractUpgrade(address _0x0d993a);


    address public _0xdff1dc;
    address public _0x75ca59;
    address public _0x47e7fd;


    bool public _0x4f1477 = false;


    modifier _0x25a11b() {
        require(msg.sender == _0xdff1dc);
        _;
    }


    modifier _0x2c6f2e() {
        require(msg.sender == _0x75ca59);
        _;
    }


    modifier _0x1b90b1() {
        require(msg.sender == _0x47e7fd);
        _;
    }

    modifier _0x50b0ca() {
        require(
            msg.sender == _0x47e7fd ||
            msg.sender == _0xdff1dc ||
            msg.sender == _0x75ca59
        );
        _;
    }


    function _0xbe71c3(address _0xca40e2) external _0x25a11b {
        require(_0xca40e2 != address(0));

        if (gasleft() > 0) { _0xdff1dc = _0xca40e2; }
    }


    function _0x1c3968(address _0xf98db7) external _0x25a11b {
        require(_0xf98db7 != address(0));

        _0x75ca59 = _0xf98db7;
    }


    function _0x086cee(address _0x80947e) external _0x25a11b {
        require(_0x80947e != address(0));

        _0x47e7fd = _0x80947e;
    }


    modifier _0x987d7e() {
        require(!_0x4f1477);
        _;
    }


    modifier _0x07ba1b {
        require(_0x4f1477);
        _;
    }


    function _0x8b126b() external _0x50b0ca _0x987d7e {
        if (true) { _0x4f1477 = true; }
    }


    function _0xca0727() public _0x25a11b _0x07ba1b {

        _0x4f1477 = false;
    }
}


contract PandaBase is PandaAccessControl {


    uint256 public constant GEN0_TOTAL_COUNT = 16200;
    uint256 public _0xada9fa;


    event Birth(address _0xe6ace0, uint256 _0x6068d8, uint256 _0xdeaeee, uint256 _0xcf44ee, uint256[2] _0x7f23e0);


    event Transfer(address from, address _0x3c52c1, uint256 _0xa2cc15);


    struct Panda {


        uint256[2] _0x7f23e0;


        uint64 _0x11d14e;


        uint64 _0xf8f9e8;


        uint32 _0xdeaeee;
        uint32 _0xcf44ee;


        uint32 _0x0215e4;


        uint16 _0x918733;


        uint16 _0xfbf4d7;
    }


    uint32[9] public _0x16edda = [
        uint32(5 minutes),
        uint32(30 minutes),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(24 hours),
        uint32(48 hours),
        uint32(72 hours),
        uint32(7 days)
    ];


    uint256 public _0x95caf2 = 15;


    Panda[] _0x29fed0;


    mapping (uint256 => address) public _0x07b851;


    mapping (address => uint256) _0x881dfa;


    mapping (uint256 => address) public _0x6fcaf3;


    mapping (uint256 => address) public _0x978cdc;


    SaleClockAuction public _0x05ca4e;


    SiringClockAuction public _0x3d3f7d;


    GeneScienceInterface public _0xcd58f2;

    SaleClockAuctionERC20 public _0xa25b1b;


    mapping (uint256 => uint256) public _0x0f19eb;
    mapping (uint256 => uint256) public _0x4ed932;


    function _0xf6f907(uint256 _0xdbb8c3) view external returns(uint256) {
        return _0x0f19eb[_0xdbb8c3];
    }

    function _0xd07a70(uint256 _0xdbb8c3) view external returns(uint256) {
        return _0x4ed932[_0xdbb8c3];
    }

    function _0x290d25(uint256 _0xdbb8c3,uint256 _0x28be8a) external _0x50b0ca {
        require (_0x0f19eb[_0xdbb8c3]==0);
        require (_0x28be8a==uint256(uint32(_0x28be8a)));
        _0x0f19eb[_0xdbb8c3] = _0x28be8a;
    }

    function _0x1f621c(uint256 _0x80cf62) view external returns(uint256) {
        Panda memory _0x8cf4bb = _0x29fed0[_0x80cf62];
        return _0xcd58f2._0xf44b51(_0x8cf4bb._0x7f23e0);
    }


    function _0x9fc0cf(address _0xb45b06, address _0x21aca8, uint256 _0xf59b95) internal {

        _0x881dfa[_0x21aca8]++;

        _0x07b851[_0xf59b95] = _0x21aca8;

        if (_0xb45b06 != address(0)) {
            _0x881dfa[_0xb45b06]--;

            delete _0x978cdc[_0xf59b95];

            delete _0x6fcaf3[_0xf59b95];
        }

        Transfer(_0xb45b06, _0x21aca8, _0xf59b95);
    }


    function _0x7c368a(
        uint256 _0x006341,
        uint256 _0xd0a9c1,
        uint256 _0xe2ec33,
        uint256[2] _0x002594,
        address _0xb09ea4
    )
        internal
        returns (uint)
    {


        require(_0x006341 == uint256(uint32(_0x006341)));
        require(_0xd0a9c1 == uint256(uint32(_0xd0a9c1)));
        require(_0xe2ec33 == uint256(uint16(_0xe2ec33)));


        uint16 _0x918733 = 0;

        if (_0x29fed0.length>0){
            uint16 _0x8bee39 = uint16(_0xcd58f2._0x7fe8ce(_0x002594));
            if (_0x8bee39==0) {
                _0x8bee39 = 1;
            }
            _0x918733 = 1000/_0x8bee39;
            if (_0x918733%10 < 5){
                _0x918733 = _0x918733/10;
            }else{
                _0x918733 = _0x918733/10 + 1;
            }
            _0x918733 = _0x918733 - 1;
            if (_0x918733 > 8) {
                _0x918733 = 8;
            }
            uint256 _0xdbb8c3 = _0xcd58f2._0xf44b51(_0x002594);
            if (_0xdbb8c3>0 && _0x0f19eb[_0xdbb8c3]<=_0x4ed932[_0xdbb8c3]) {
                _0x002594 = _0xcd58f2._0x1ff94a(_0x002594);
                _0xdbb8c3 = 0;
            }

            if (_0xdbb8c3 == 1){
                _0x918733 = 5;
            }


            if (_0xdbb8c3>0){
                _0x4ed932[_0xdbb8c3] = _0x4ed932[_0xdbb8c3] + 1;
            }

            if (_0xe2ec33 <= 1 && _0xdbb8c3 != 1){
                require(_0xada9fa<GEN0_TOTAL_COUNT);
                _0xada9fa++;
            }
        }

        Panda memory _0x80c36f = Panda({
            _0x7f23e0: _0x002594,
            _0x11d14e: uint64(_0xbe2e0f),
            _0xf8f9e8: 0,
            _0xdeaeee: uint32(_0x006341),
            _0xcf44ee: uint32(_0xd0a9c1),
            _0x0215e4: 0,
            _0x918733: _0x918733,
            _0xfbf4d7: uint16(_0xe2ec33)
        });
        uint256 _0x930334 = _0x29fed0.push(_0x80c36f) - 1;


        require(_0x930334 == uint256(uint32(_0x930334)));


        Birth(
            _0xb09ea4,
            _0x930334,
            uint256(_0x80c36f._0xdeaeee),
            uint256(_0x80c36f._0xcf44ee),
            _0x80c36f._0x7f23e0
        );


        _0x9fc0cf(0, _0xb09ea4, _0x930334);

        return _0x930334;
    }


    function _0xd542a7(uint256 _0xa60204) external _0x50b0ca {
        require(_0xa60204 < _0x16edda[0]);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x95caf2 = _0xa60204; }
    }
}


contract ERC721Metadata {

    function _0x4fc9ff(uint256 _0xf59b95, string) public view returns (bytes32[4] _0x492fe6, uint256 _0x74af2d) {
        if (_0xf59b95 == 1) {
            _0x492fe6[0] = "Hello World! :D";
            _0x74af2d = 15;
        } else if (_0xf59b95 == 2) {
            _0x492fe6[0] = "I would definitely choose a medi";
            _0x492fe6[1] = "um length string.";
            _0x74af2d = 49;
        } else if (_0xf59b95 == 3) {
            _0x492fe6[0] = "Lorem ipsum dolor sit amet, mi e";
            _0x492fe6[1] = "st accumsan dapibus augue lorem,";
            _0x492fe6[2] = " tristique vestibulum id, libero";
            _0x492fe6[3] = " suscipit varius sapien aliquam.";
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x74af2d = 128; }
        }
    }
}


contract PandaOwnership is PandaBase, ERC721 {


    string public constant _0xa96443 = "PandaEarth";
    string public constant _0xcd17d0 = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(_0xd6211f('_0xb95486(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(_0xd6211f('_0xa96443()')) ^
        bytes4(_0xd6211f('_0xcd17d0()')) ^
        bytes4(_0xd6211f('_0x6122ae()')) ^
        bytes4(_0xd6211f('_0xbb5ae9(address)')) ^
        bytes4(_0xd6211f('_0x797663(uint256)')) ^
        bytes4(_0xd6211f('_0xdac55a(address,uint256)')) ^
        bytes4(_0xd6211f('transfer(address,uint256)')) ^
        bytes4(_0xd6211f('_0x0f6b35(address,address,uint256)')) ^
        bytes4(_0xd6211f('_0xfee9ef(address)')) ^
        bytes4(_0xd6211f('tokenMetadata(uint256,string)'));


    function _0xb95486(bytes4 _0xa8760c) external view returns (bool)
    {


        return ((_0xa8760c == InterfaceSignature_ERC165) || (_0xa8760c == InterfaceSignature_ERC721));
    }


    function _0x202665(address _0xb2db1d, uint256 _0xf59b95) internal view returns (bool) {
        return _0x07b851[_0xf59b95] == _0xb2db1d;
    }


    function _0x400b2a(address _0xb2db1d, uint256 _0xf59b95) internal view returns (bool) {
        return _0x6fcaf3[_0xf59b95] == _0xb2db1d;
    }


    function _0x7db7d7(uint256 _0xf59b95, address _0x19419d) internal {
        _0x6fcaf3[_0xf59b95] = _0x19419d;
    }


    function _0xbb5ae9(address _0xb09ea4) public view returns (uint256 _0x74af2d) {
        return _0x881dfa[_0xb09ea4];
    }


    function transfer(
        address _0x21aca8,
        uint256 _0xf59b95
    )
        external
        _0x987d7e
    {

        require(_0x21aca8 != address(0));


        require(_0x21aca8 != address(this));


        require(_0x21aca8 != address(_0x05ca4e));
        require(_0x21aca8 != address(_0x3d3f7d));


        require(_0x202665(msg.sender, _0xf59b95));


        _0x9fc0cf(msg.sender, _0x21aca8, _0xf59b95);
    }


    function _0xdac55a(
        address _0x21aca8,
        uint256 _0xf59b95
    )
        external
        _0x987d7e
    {

        require(_0x202665(msg.sender, _0xf59b95));


        _0x7db7d7(_0xf59b95, _0x21aca8);


        Approval(msg.sender, _0x21aca8, _0xf59b95);
    }


    function _0x0f6b35(
        address _0xb45b06,
        address _0x21aca8,
        uint256 _0xf59b95
    )
        external
        _0x987d7e
    {

        require(_0x21aca8 != address(0));


        require(_0x21aca8 != address(this));

        require(_0x400b2a(msg.sender, _0xf59b95));
        require(_0x202665(_0xb45b06, _0xf59b95));


        _0x9fc0cf(_0xb45b06, _0x21aca8, _0xf59b95);
    }


    function _0x6122ae() public view returns (uint) {
        return _0x29fed0.length - 1;
    }


    function _0x797663(uint256 _0xf59b95)
        external
        view
        returns (address _0xe6ace0)
    {
        _0xe6ace0 = _0x07b851[_0xf59b95];

        require(_0xe6ace0 != address(0));
    }


    function _0xfee9ef(address _0xb09ea4) external view returns(uint256[] _0x67b741) {
        uint256 _0x41475e = _0xbb5ae9(_0xb09ea4);

        if (_0x41475e == 0) {

            return new uint256[](0);
        } else {
            uint256[] memory _0xbe73f5 = new uint256[](_0x41475e);
            uint256 _0xb8ba17 = _0x6122ae();
            uint256 _0xb42aa8 = 0;


            uint256 _0x35c7dc;

            for (_0x35c7dc = 1; _0x35c7dc <= _0xb8ba17; _0x35c7dc++) {
                if (_0x07b851[_0x35c7dc] == _0xb09ea4) {
                    _0xbe73f5[_0xb42aa8] = _0x35c7dc;
                    _0xb42aa8++;
                }
            }

            return _0xbe73f5;
        }
    }


    function _0x7af9c9(uint _0xaa1588, uint _0x7bc603, uint _0xa6af6c) private view {

        for(; _0xa6af6c >= 32; _0xa6af6c -= 32) {
            assembly {
                mstore(_0xaa1588, mload(_0x7bc603))
            }
            _0xaa1588 += 32;
            _0x7bc603 += 32;
        }


        uint256 _0xcba378 = 256 ** (32 - _0xa6af6c) - 1;
        assembly {
            let _0x96fe79 := and(mload(_0x7bc603), not(_0xcba378))
            let _0xe2e49e := and(mload(_0xaa1588), _0xcba378)
            mstore(_0xaa1588, or(_0xe2e49e, _0x96fe79))
        }
    }


    function _0x5bcc20(bytes32[4] _0x77775f, uint256 _0x5734fa) private view returns (string) {
        var _0x81f83f = new string(_0x5734fa);
        uint256 _0x9cd5ce;
        uint256 _0x813fd2;

        assembly {
            _0x9cd5ce := add(_0x81f83f, 32)
            _0x813fd2 := _0x77775f
        }

        _0x7af9c9(_0x9cd5ce, _0x813fd2, _0x5734fa);

        return _0x81f83f;
    }

}


contract PandaBreeding is PandaOwnership {

    uint256 public constant GENSIS_TOTAL_COUNT = 100;


    event Pregnant(address _0xe6ace0, uint256 _0xdeaeee, uint256 _0xcf44ee, uint256 _0xf8f9e8);

    event Abortion(address _0xe6ace0, uint256 _0xdeaeee, uint256 _0xcf44ee);


    uint256 public _0xd36f6c = 2 finney;


    uint256 public _0xb3b0ba;

    mapping(uint256 => address) _0x786630;


    function _0xaf4f51(address _0x229da0) external _0x25a11b {
        GeneScienceInterface _0x39d2b7 = GeneScienceInterface(_0x229da0);


        require(_0x39d2b7._0xcb2b20());


        _0xcd58f2 = _0x39d2b7;
    }


    function _0x8efe7d(Panda _0x21f2df) internal view returns(bool) {


        return (_0x21f2df._0x0215e4 == 0) && (_0x21f2df._0xf8f9e8 <= uint64(block.number));
    }


    function _0xcd4dbd(uint256 _0xd0a9c1, uint256 _0x006341) internal view returns(bool) {
        address _0x5ba423 = _0x07b851[_0x006341];
        address _0xdf3446 = _0x07b851[_0xd0a9c1];


        return (_0x5ba423 == _0xdf3446 || _0x978cdc[_0xd0a9c1] == _0x5ba423);
    }


    function _0x279e54(Panda storage _0x430169) internal {

        _0x430169._0xf8f9e8 = uint64((_0x16edda[_0x430169._0x918733] / _0x95caf2) + block.number);


        if (_0x430169._0x918733 < 8 && _0xcd58f2._0xf44b51(_0x430169._0x7f23e0) != 1) {
            _0x430169._0x918733 += 1;
        }
    }


    function _0xf1044e(address _0x672515, uint256 _0xd0a9c1)
    external
    _0x987d7e {
        require(_0x202665(msg.sender, _0xd0a9c1));
        _0x978cdc[_0xd0a9c1] = _0x672515;
    }


    function _0xd28a03(uint256 _0x0bc98d) external _0x1b90b1 {
        if (gasleft() > 0) { _0xd36f6c = _0x0bc98d; }
    }


    function _0x9e577f(Panda _0xffe006) private view returns(bool) {
        return (_0xffe006._0x0215e4 != 0) && (_0xffe006._0xf8f9e8 <= uint64(block.number));
    }


    function _0x090569(uint256 _0xf4c62a)
    public
    view
    returns(bool) {
        require(_0xf4c62a > 0);
        Panda storage _0x870134 = _0x29fed0[_0xf4c62a];
        return _0x8efe7d(_0x870134);
    }


    function _0xc33e92(uint256 _0xf4c62a)
    public
    view
    returns(bool) {
        require(_0xf4c62a > 0);

        return _0x29fed0[_0xf4c62a]._0x0215e4 != 0;
    }


    function _0x7d3431(
        Panda storage _0xffe006,
        uint256 _0x006341,
        Panda storage _0x7eeefa,
        uint256 _0xd0a9c1
    )
    private
    view
    returns(bool) {

        if (_0x006341 == _0xd0a9c1) {
            return false;
        }


        if (_0xffe006._0xdeaeee == _0xd0a9c1 || _0xffe006._0xcf44ee == _0xd0a9c1) {
            return false;
        }
        if (_0x7eeefa._0xdeaeee == _0x006341 || _0x7eeefa._0xcf44ee == _0x006341) {
            return false;
        }


        if (_0x7eeefa._0xdeaeee == 0 || _0xffe006._0xdeaeee == 0) {
            return true;
        }


        if (_0x7eeefa._0xdeaeee == _0xffe006._0xdeaeee || _0x7eeefa._0xdeaeee == _0xffe006._0xcf44ee) {
            return false;
        }
        if (_0x7eeefa._0xcf44ee == _0xffe006._0xdeaeee || _0x7eeefa._0xcf44ee == _0xffe006._0xcf44ee) {
            return false;
        }


        if (_0xcd58f2._0x326ff2(_0xffe006._0x7f23e0) + _0xcd58f2._0x326ff2(_0x7eeefa._0x7f23e0) != 1) {
            return false;
        }


        return true;
    }


    function _0x2f3805(uint256 _0x006341, uint256 _0xd0a9c1)
    internal
    view
    returns(bool) {
        Panda storage _0xa93fb7 = _0x29fed0[_0x006341];
        Panda storage _0x036b0f = _0x29fed0[_0xd0a9c1];
        return _0x7d3431(_0xa93fb7, _0x006341, _0x036b0f, _0xd0a9c1);
    }


    function _0xe90b85(uint256 _0x006341, uint256 _0xd0a9c1)
    external
    view
    returns(bool) {
        require(_0x006341 > 0);
        require(_0xd0a9c1 > 0);
        Panda storage _0xa93fb7 = _0x29fed0[_0x006341];
        Panda storage _0x036b0f = _0x29fed0[_0xd0a9c1];
        return _0x7d3431(_0xa93fb7, _0x006341, _0x036b0f, _0xd0a9c1) &&
            _0xcd4dbd(_0xd0a9c1, _0x006341);
    }

    function _0x87b9b5(uint256 _0x006341, uint256 _0xd0a9c1) internal returns(uint256, uint256) {
        if (_0xcd58f2._0x326ff2(_0x29fed0[_0x006341]._0x7f23e0) == 1) {
            return (_0xd0a9c1, _0x006341);
        } else {
            return (_0x006341, _0xd0a9c1);
        }
    }


    function _0x826afe(uint256 _0x006341, uint256 _0xd0a9c1, address _0xb09ea4) internal {

        (_0x006341, _0xd0a9c1) = _0x87b9b5(_0x006341, _0xd0a9c1);

        Panda storage _0x036b0f = _0x29fed0[_0xd0a9c1];
        Panda storage _0xa93fb7 = _0x29fed0[_0x006341];


        _0xa93fb7._0x0215e4 = uint32(_0xd0a9c1);


        _0x279e54(_0x036b0f);
        _0x279e54(_0xa93fb7);


        delete _0x978cdc[_0x006341];
        delete _0x978cdc[_0xd0a9c1];


        _0xb3b0ba++;

        _0x786630[_0x006341] = _0xb09ea4;


        Pregnant(_0x07b851[_0x006341], _0x006341, _0xd0a9c1, _0xa93fb7._0xf8f9e8);
    }


    function _0x543ed1(uint256 _0x006341, uint256 _0xd0a9c1)
    external
    payable
    _0x987d7e {

        require(msg.value >= _0xd36f6c);


        require(_0x202665(msg.sender, _0x006341));


        require(_0xcd4dbd(_0xd0a9c1, _0x006341));


        Panda storage _0xa93fb7 = _0x29fed0[_0x006341];


        require(_0x8efe7d(_0xa93fb7));


        Panda storage _0x036b0f = _0x29fed0[_0xd0a9c1];


        require(_0x8efe7d(_0x036b0f));


        require(_0x7d3431(
            _0xa93fb7,
            _0x006341,
            _0x036b0f,
            _0xd0a9c1
        ));


        _0x826afe(_0x006341, _0xd0a9c1, msg.sender);
    }


    function _0x8e43f3(uint256 _0x006341, uint256[2] _0x2bd33c, uint256[2] _0x9d5dd9)
    external
    _0x987d7e
    _0x50b0ca
    returns(uint256) {

        Panda storage _0xa93fb7 = _0x29fed0[_0x006341];


        require(_0xa93fb7._0x11d14e != 0);


        require(_0x9e577f(_0xa93fb7));


        uint256 _0xcf44ee = _0xa93fb7._0x0215e4;
        Panda storage _0x036b0f = _0x29fed0[_0xcf44ee];


        uint16 _0xa14dac = _0xa93fb7._0xfbf4d7;
        if (_0x036b0f._0xfbf4d7 > _0xa93fb7._0xfbf4d7) {
            _0xa14dac = _0x036b0f._0xfbf4d7;
        }


        uint256[2] memory _0x7d9c39 = _0x2bd33c;

        uint256 _0x336df9 = 0;


        uint256 _0xd35658 = (_0xcd58f2._0x7fe8ce(_0xa93fb7._0x7f23e0) + _0xcd58f2._0x7fe8ce(_0x036b0f._0x7f23e0)) / 2 + _0x9d5dd9[0];
        if (_0xd35658 >= (_0xa14dac + 1) * _0x9d5dd9[1]) {
            _0xd35658 = _0xd35658 - (_0xa14dac + 1) * _0x9d5dd9[1];
        } else {
            _0xd35658 = 0;
        }
        if (_0xa14dac == 0 && _0xada9fa == GEN0_TOTAL_COUNT) {
            _0xd35658 = 0;
        }
        if (uint256(_0xd6211f(block.blockhash(block.number - 2), _0xbe2e0f)) % 100 < _0xd35658) {

            address _0xe6ace0 = _0x786630[_0x006341];
            _0x336df9 = _0x7c368a(_0x006341, _0xa93fb7._0x0215e4, _0xa14dac + 1, _0x7d9c39, _0xe6ace0);
        } else {
            Abortion(_0x07b851[_0x006341], _0x006341, _0xcf44ee);
        }


        delete _0xa93fb7._0x0215e4;


        _0xb3b0ba--;


        msg.sender.send(_0xd36f6c);

        delete _0x786630[_0x006341];


        return _0x336df9;
    }
}


contract ClockAuctionBase {


    struct Auction {

        address _0xe8b910;

        uint128 _0x54fc19;

        uint128 _0x19efb0;

        uint64 _0x02a203;


        uint64 _0x63e8d1;

        uint64 _0x907928;
    }


    ERC721 public _0xd5e767;


    uint256 public _0x246e5c;


    mapping (uint256 => Auction) _0x973c50;

    event AuctionCreated(uint256 _0xa2cc15, uint256 _0x54fc19, uint256 _0x19efb0, uint256 _0x02a203);
    event AuctionSuccessful(uint256 _0xa2cc15, uint256 _0x015217, address _0x81f870);
    event AuctionCancelled(uint256 _0xa2cc15);


    function _0x202665(address _0xb2db1d, uint256 _0xf59b95) internal view returns (bool) {
        return (_0xd5e767._0x797663(_0xf59b95) == _0xb2db1d);
    }


    function _0x8b014a(address _0xb09ea4, uint256 _0xf59b95) internal {

        _0xd5e767._0x0f6b35(_0xb09ea4, this, _0xf59b95);
    }


    function _0x9fc0cf(address _0x2cf7ac, uint256 _0xf59b95) internal {

        _0xd5e767.transfer(_0x2cf7ac, _0xf59b95);
    }


    function _0x8108a4(uint256 _0xf59b95, Auction _0x9ee34f) internal {


        require(_0x9ee34f._0x02a203 >= 1 minutes);

        _0x973c50[_0xf59b95] = _0x9ee34f;

        AuctionCreated(
            uint256(_0xf59b95),
            uint256(_0x9ee34f._0x54fc19),
            uint256(_0x9ee34f._0x19efb0),
            uint256(_0x9ee34f._0x02a203)
        );
    }


    function _0x5f95e7(uint256 _0xf59b95, address _0xe6d9ea) internal {
        _0xbf69f2(_0xf59b95);
        _0x9fc0cf(_0xe6d9ea, _0xf59b95);
        AuctionCancelled(_0xf59b95);
    }


    function _0x1b5a71(uint256 _0xf59b95, uint256 _0x8c786f)
        internal
        returns (uint256)
    {

        Auction storage _0xbe1d3b = _0x973c50[_0xf59b95];


        require(_0x811481(_0xbe1d3b));


        uint256 _0xed7dc7 = _0xe2e89d(_0xbe1d3b);
        require(_0x8c786f >= _0xed7dc7);


        address _0xe8b910 = _0xbe1d3b._0xe8b910;


        _0xbf69f2(_0xf59b95);


        if (_0xed7dc7 > 0) {


            uint256 _0x289b08 = _0x1ecc57(_0xed7dc7);
            uint256 _0x9772ee = _0xed7dc7 - _0x289b08;


            _0xe8b910.transfer(_0x9772ee);
        }


        uint256 _0xd6f4ba = _0x8c786f - _0xed7dc7;


        msg.sender.transfer(_0xd6f4ba);


        AuctionSuccessful(_0xf59b95, _0xed7dc7, msg.sender);

        return _0xed7dc7;
    }


    function _0xbf69f2(uint256 _0xf59b95) internal {
        delete _0x973c50[_0xf59b95];
    }


    function _0x811481(Auction storage _0x9ee34f) internal view returns (bool) {
        return (_0x9ee34f._0x63e8d1 > 0);
    }


    function _0xe2e89d(Auction storage _0x9ee34f)
        internal
        view
        returns (uint256)
    {
        uint256 _0x42e212 = 0;


        if (_0xbe2e0f > _0x9ee34f._0x63e8d1) {
            _0x42e212 = _0xbe2e0f - _0x9ee34f._0x63e8d1;
        }

        return _0x55595c(
            _0x9ee34f._0x54fc19,
            _0x9ee34f._0x19efb0,
            _0x9ee34f._0x02a203,
            _0x42e212
        );
    }


    function _0x55595c(
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9,
        uint256 _0x5e30cc
    )
        internal
        pure
        returns (uint256)
    {


        if (_0x5e30cc >= _0x7ed5a9) {


            return _0xbfe5cf;
        } else {


            int256 _0xadbb55 = int256(_0xbfe5cf) - int256(_0xe0ae04);


            int256 _0xc2e511 = _0xadbb55 * int256(_0x5e30cc) / int256(_0x7ed5a9);


            int256 _0x59f314 = int256(_0xe0ae04) + _0xc2e511;

            return uint256(_0x59f314);
        }
    }


    function _0x1ecc57(uint256 _0x8e1b46) internal view returns (uint256) {


        return _0x8e1b46 * _0x246e5c / 10000;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0x4f1477 = false;

  modifier _0x987d7e() {
    require(!_0x4f1477);
    _;
  }

  modifier _0x07ba1b {
    require(_0x4f1477);
    _;
  }

  function _0x8b126b() _0xdf6122 _0x987d7e returns (bool) {
    _0x4f1477 = true;
    Pause();
    return true;
  }

  function _0xca0727() _0xdf6122 _0x07ba1b returns (bool) {
    _0x4f1477 = false;
    Unpause();
    return true;
  }
}


contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);


    function ClockAuction(address _0xb7ee63, uint256 _0xc8c63f) public {
        require(_0xc8c63f <= 10000);
        if (block.timestamp > 0) { _0x246e5c = _0xc8c63f; }

        ERC721 _0x39d2b7 = ERC721(_0xb7ee63);
        require(_0x39d2b7._0xb95486(InterfaceSignature_ERC721));
        _0xd5e767 = _0x39d2b7;
    }


    function _0x52f8a9() external {
        address _0x93fb20 = address(_0xd5e767);

        require(
            msg.sender == _0xe6ace0 ||
            msg.sender == _0x93fb20
        );

        bool _0xc94f1c = _0x93fb20.send(this.balance);
    }


    function _0x0e5983(
        uint256 _0xf59b95,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9,
        address _0xe6d9ea
    )
        external
        _0x987d7e
    {


        require(_0xe0ae04 == uint256(uint128(_0xe0ae04)));
        require(_0xbfe5cf == uint256(uint128(_0xbfe5cf)));
        require(_0x7ed5a9 == uint256(uint64(_0x7ed5a9)));

        require(_0x202665(msg.sender, _0xf59b95));
        _0x8b014a(msg.sender, _0xf59b95);
        Auction memory _0xbe1d3b = Auction(
            _0xe6d9ea,
            uint128(_0xe0ae04),
            uint128(_0xbfe5cf),
            uint64(_0x7ed5a9),
            uint64(_0xbe2e0f),
            0
        );
        _0x8108a4(_0xf59b95, _0xbe1d3b);
    }


    function _0xbbf1e8(uint256 _0xf59b95)
        external
        payable
        _0x987d7e
    {

        _0x1b5a71(_0xf59b95, msg.value);
        _0x9fc0cf(msg.sender, _0xf59b95);
    }


    function _0x2182c6(uint256 _0xf59b95)
        external
    {
        Auction storage _0xbe1d3b = _0x973c50[_0xf59b95];
        require(_0x811481(_0xbe1d3b));
        address _0xe8b910 = _0xbe1d3b._0xe8b910;
        require(msg.sender == _0xe8b910);
        _0x5f95e7(_0xf59b95, _0xe8b910);
    }


    function _0x10f8a1(uint256 _0xf59b95)
        _0x07ba1b
        _0xdf6122
        external
    {
        Auction storage _0xbe1d3b = _0x973c50[_0xf59b95];
        require(_0x811481(_0xbe1d3b));
        _0x5f95e7(_0xf59b95, _0xbe1d3b._0xe8b910);
    }


    function _0x266d61(uint256 _0xf59b95)
        external
        view
        returns
    (
        address _0xe8b910,
        uint256 _0x54fc19,
        uint256 _0x19efb0,
        uint256 _0x02a203,
        uint256 _0x63e8d1
    ) {
        Auction storage _0xbe1d3b = _0x973c50[_0xf59b95];
        require(_0x811481(_0xbe1d3b));
        return (
            _0xbe1d3b._0xe8b910,
            _0xbe1d3b._0x54fc19,
            _0xbe1d3b._0x19efb0,
            _0xbe1d3b._0x02a203,
            _0xbe1d3b._0x63e8d1
        );
    }


    function _0x3a0978(uint256 _0xf59b95)
        external
        view
        returns (uint256)
    {
        Auction storage _0xbe1d3b = _0x973c50[_0xf59b95];
        require(_0x811481(_0xbe1d3b));
        return _0xe2e89d(_0xbe1d3b);
    }

}


contract SiringClockAuction is ClockAuction {


    bool public _0x5edab6 = true;


    function SiringClockAuction(address _0xcc9a95, uint256 _0xc8c63f) public
        ClockAuction(_0xcc9a95, _0xc8c63f) {}


    function _0x0e5983(
        uint256 _0xf59b95,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9,
        address _0xe6d9ea
    )
        external
    {


        require(_0xe0ae04 == uint256(uint128(_0xe0ae04)));
        require(_0xbfe5cf == uint256(uint128(_0xbfe5cf)));
        require(_0x7ed5a9 == uint256(uint64(_0x7ed5a9)));

        require(msg.sender == address(_0xd5e767));
        _0x8b014a(_0xe6d9ea, _0xf59b95);
        Auction memory _0xbe1d3b = Auction(
            _0xe6d9ea,
            uint128(_0xe0ae04),
            uint128(_0xbfe5cf),
            uint64(_0x7ed5a9),
            uint64(_0xbe2e0f),
            0
        );
        _0x8108a4(_0xf59b95, _0xbe1d3b);
    }


    function _0xbbf1e8(uint256 _0xf59b95)
        external
        payable
    {
        require(msg.sender == address(_0xd5e767));
        address _0xe8b910 = _0x973c50[_0xf59b95]._0xe8b910;

        _0x1b5a71(_0xf59b95, msg.value);


        _0x9fc0cf(_0xe8b910, _0xf59b95);
    }

}


contract SaleClockAuction is ClockAuction {


    bool public _0x8fb378 = true;


    uint256 public _0xec170c;
    uint256[5] public _0xdd8d26;
    uint256 public constant SurpriseValue = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaIndex;
    uint256   RarePandaIndex;


    function SaleClockAuction(address _0xcc9a95, uint256 _0xc8c63f) public
        ClockAuction(_0xcc9a95, _0xc8c63f) {
            CommonPandaIndex = 1;
            RarePandaIndex   = 1;
    }


    function _0x0e5983(
        uint256 _0xf59b95,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9,
        address _0xe6d9ea
    )
        external
    {


        require(_0xe0ae04 == uint256(uint128(_0xe0ae04)));
        require(_0xbfe5cf == uint256(uint128(_0xbfe5cf)));
        require(_0x7ed5a9 == uint256(uint64(_0x7ed5a9)));

        require(msg.sender == address(_0xd5e767));
        _0x8b014a(_0xe6d9ea, _0xf59b95);
        Auction memory _0xbe1d3b = Auction(
            _0xe6d9ea,
            uint128(_0xe0ae04),
            uint128(_0xbfe5cf),
            uint64(_0x7ed5a9),
            uint64(_0xbe2e0f),
            0
        );
        _0x8108a4(_0xf59b95, _0xbe1d3b);
    }

    function _0x3d659f(
        uint256 _0xf59b95,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9,
        address _0xe6d9ea
    )
        external
    {


        require(_0xe0ae04 == uint256(uint128(_0xe0ae04)));
        require(_0xbfe5cf == uint256(uint128(_0xbfe5cf)));
        require(_0x7ed5a9 == uint256(uint64(_0x7ed5a9)));

        require(msg.sender == address(_0xd5e767));
        _0x8b014a(_0xe6d9ea, _0xf59b95);
        Auction memory _0xbe1d3b = Auction(
            _0xe6d9ea,
            uint128(_0xe0ae04),
            uint128(_0xbfe5cf),
            uint64(_0x7ed5a9),
            uint64(_0xbe2e0f),
            1
        );
        _0x8108a4(_0xf59b95, _0xbe1d3b);
    }


    function _0xbbf1e8(uint256 _0xf59b95)
        external
        payable
    {

        uint64 _0x907928 = _0x973c50[_0xf59b95]._0x907928;
        uint256 _0xed7dc7 = _0x1b5a71(_0xf59b95, msg.value);
        _0x9fc0cf(msg.sender, _0xf59b95);


        if (_0x907928 == 1) {

            _0xdd8d26[_0xec170c % 5] = _0xed7dc7;
            _0xec170c++;
        }
    }

    function _0xa1e975(uint256 _0xf59b95,uint256 _0xe89e39)
        external
    {
        require(msg.sender == address(_0xd5e767));
        if (_0xe89e39 == 0) {
            CommonPanda.push(_0xf59b95);
        }else {
            RarePanda.push(_0xf59b95);
        }
    }

    function _0x233b06()
        external
        payable
    {
        bytes32 _0x6e713f = _0xd6211f(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaIndex;
        if (_0x6e713f[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaIndex);
            PandaIndex = RarePandaIndex;
            RarePandaIndex ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaIndex);
            PandaIndex = CommonPandaIndex;
            CommonPandaIndex ++;
        }
        _0x9fc0cf(msg.sender,PandaIndex);
    }

    function _0x3db60c() external view returns(uint256 _0x318419,uint256 _0x0edd37) {
        _0x318419   = CommonPanda.length + 1 - CommonPandaIndex;
        _0x0edd37 = RarePanda.length + 1 - RarePandaIndex;
    }

    function _0x04c48a() external view returns (uint256) {
        uint256 _0x5bd175 = 0;
        for (uint256 i = 0; i < 5; i++) {
            _0x5bd175 += _0xdd8d26[i];
        }
        return _0x5bd175 / 5;
    }

}


contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 _0xa2cc15, uint256 _0x54fc19, uint256 _0x19efb0, uint256 _0x02a203, address _0x489702);


    bool public _0xd1c51d = true;

    mapping (uint256 => address) public _0xdecdaa;

    mapping (address => uint256) public _0x7314a7;

    mapping (address => uint256) public _0x59971d;


    function SaleClockAuctionERC20(address _0xcc9a95, uint256 _0xc8c63f) public
        ClockAuction(_0xcc9a95, _0xc8c63f) {}

    function _0x14290e(address _0x90d5db, uint256 _0x493d3a) external{
        require (msg.sender == address(_0xd5e767));

        require (_0x90d5db != address(0));

        _0x7314a7[_0x90d5db] = _0x493d3a;
    }


    function _0x0e5983(
        uint256 _0xf59b95,
        address _0x054c29,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9,
        address _0xe6d9ea
    )
        external
    {


        require(_0xe0ae04 == uint256(uint128(_0xe0ae04)));
        require(_0xbfe5cf == uint256(uint128(_0xbfe5cf)));
        require(_0x7ed5a9 == uint256(uint64(_0x7ed5a9)));

        require(msg.sender == address(_0xd5e767));

        require (_0x7314a7[_0x054c29] > 0);

        _0x8b014a(_0xe6d9ea, _0xf59b95);
        Auction memory _0xbe1d3b = Auction(
            _0xe6d9ea,
            uint128(_0xe0ae04),
            uint128(_0xbfe5cf),
            uint64(_0x7ed5a9),
            uint64(_0xbe2e0f),
            0
        );
        _0x993936(_0xf59b95, _0xbe1d3b, _0x054c29);
        _0xdecdaa[_0xf59b95] = _0x054c29;
    }


    function _0x993936(uint256 _0xf59b95, Auction _0x9ee34f, address _0x90d5db) internal {


        require(_0x9ee34f._0x02a203 >= 1 minutes);

        _0x973c50[_0xf59b95] = _0x9ee34f;

        AuctionERC20Created(
            uint256(_0xf59b95),
            uint256(_0x9ee34f._0x54fc19),
            uint256(_0x9ee34f._0x19efb0),
            uint256(_0x9ee34f._0x02a203),
            _0x90d5db
        );
    }

    function _0xbbf1e8(uint256 _0xf59b95)
        external
        payable{

    }


    function _0x9684f8(uint256 _0xf59b95,uint256 _0x26201e)
        external
    {

        address _0xe8b910 = _0x973c50[_0xf59b95]._0xe8b910;
        address _0x90d5db = _0xdecdaa[_0xf59b95];
        require (_0x90d5db != address(0));
        uint256 _0xed7dc7 = _0x73fda8(_0x90d5db,msg.sender,_0xf59b95, _0x26201e);
        _0x9fc0cf(msg.sender, _0xf59b95);
        delete _0xdecdaa[_0xf59b95];
    }

    function _0x2182c6(uint256 _0xf59b95)
        external
    {
        Auction storage _0xbe1d3b = _0x973c50[_0xf59b95];
        require(_0x811481(_0xbe1d3b));
        address _0xe8b910 = _0xbe1d3b._0xe8b910;
        require(msg.sender == _0xe8b910);
        _0x5f95e7(_0xf59b95, _0xe8b910);
        delete _0xdecdaa[_0xf59b95];
    }

    function _0xcaca1e(address _0x054c29, address _0x21aca8) external returns(bool _0xc94f1c)  {
        require (_0x59971d[_0x054c29] > 0);
        require(msg.sender == address(_0xd5e767));
        ERC20(_0x054c29).transfer(_0x21aca8, _0x59971d[_0x054c29]);
    }


    function _0x73fda8(address _0x054c29,address _0x2bddc2, uint256 _0xf59b95, uint256 _0x8c786f)
        internal
        returns (uint256)
    {

        Auction storage _0xbe1d3b = _0x973c50[_0xf59b95];


        require(_0x811481(_0xbe1d3b));

        require (_0x054c29 != address(0) && _0x054c29 == _0xdecdaa[_0xf59b95]);


        uint256 _0xed7dc7 = _0xe2e89d(_0xbe1d3b);
        require(_0x8c786f >= _0xed7dc7);


        address _0xe8b910 = _0xbe1d3b._0xe8b910;


        _0xbf69f2(_0xf59b95);


        if (_0xed7dc7 > 0) {


            uint256 _0x289b08 = _0x1ecc57(_0xed7dc7);
            uint256 _0x9772ee = _0xed7dc7 - _0x289b08;


            require(ERC20(_0x054c29)._0x0f6b35(_0x2bddc2,_0xe8b910,_0x9772ee));
            if (_0x289b08 > 0){
                require(ERC20(_0x054c29)._0x0f6b35(_0x2bddc2,address(this),_0x289b08));
                _0x59971d[_0x054c29] += _0x289b08;
            }
        }


        AuctionSuccessful(_0xf59b95, _0xed7dc7, msg.sender);

        return _0xed7dc7;
    }
}


contract PandaAuction is PandaBreeding {


    function _0xe4b5e3(address _0x229da0) external _0x25a11b {
        SaleClockAuction _0x39d2b7 = SaleClockAuction(_0x229da0);


        require(_0x39d2b7._0x8fb378());


        _0x05ca4e = _0x39d2b7;
    }

    function _0x8c81c4(address _0x229da0) external _0x25a11b {
        SaleClockAuctionERC20 _0x39d2b7 = SaleClockAuctionERC20(_0x229da0);


        require(_0x39d2b7._0xd1c51d());


        _0xa25b1b = _0x39d2b7;
    }


    function _0x440e80(address _0x229da0) external _0x25a11b {
        SiringClockAuction _0x39d2b7 = SiringClockAuction(_0x229da0);


        require(_0x39d2b7._0x5edab6());


        _0x3d3f7d = _0x39d2b7;
    }


    function _0xc6eaf0(
        uint256 _0xf4c62a,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9
    )
        external
        _0x987d7e
    {


        require(_0x202665(msg.sender, _0xf4c62a));


        require(!_0xc33e92(_0xf4c62a));
        _0x7db7d7(_0xf4c62a, _0x05ca4e);


        _0x05ca4e._0x0e5983(
            _0xf4c62a,
            _0xe0ae04,
            _0xbfe5cf,
            _0x7ed5a9,
            msg.sender
        );
    }


    function _0x36ec60(
        uint256 _0xf4c62a,
        address _0x90d5db,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9
    )
        external
        _0x987d7e
    {


        require(_0x202665(msg.sender, _0xf4c62a));


        require(!_0xc33e92(_0xf4c62a));
        _0x7db7d7(_0xf4c62a, _0xa25b1b);


        _0xa25b1b._0x0e5983(
            _0xf4c62a,
            _0x90d5db,
            _0xe0ae04,
            _0xbfe5cf,
            _0x7ed5a9,
            msg.sender
        );
    }

    function _0x302872(address _0x90d5db, uint256 _0x493d3a) external _0x1b90b1{
        _0xa25b1b._0x14290e(_0x90d5db,_0x493d3a);
    }


    function _0x030d04(
        uint256 _0xf4c62a,
        uint256 _0xe0ae04,
        uint256 _0xbfe5cf,
        uint256 _0x7ed5a9
    )
        external
        _0x987d7e
    {


        require(_0x202665(msg.sender, _0xf4c62a));
        require(_0x090569(_0xf4c62a));
        _0x7db7d7(_0xf4c62a, _0x3d3f7d);


        _0x3d3f7d._0x0e5983(
            _0xf4c62a,
            _0xe0ae04,
            _0xbfe5cf,
            _0x7ed5a9,
            msg.sender
        );
    }


    function _0xd1e7c7(
        uint256 _0xd0a9c1,
        uint256 _0x006341
    )
        external
        payable
        _0x987d7e
    {

        require(_0x202665(msg.sender, _0x006341));
        require(_0x090569(_0x006341));
        require(_0x2f3805(_0x006341, _0xd0a9c1));


        uint256 _0x59f314 = _0x3d3f7d._0x3a0978(_0xd0a9c1);
        require(msg.value >= _0x59f314 + _0xd36f6c);


        _0x3d3f7d._0xbbf1e8.value(msg.value - _0xd36f6c)(_0xd0a9c1);
        _0x826afe(uint32(_0x006341), uint32(_0xd0a9c1), msg.sender);
    }


    function _0x4cb1ea() external _0x50b0ca {
        _0x05ca4e._0x52f8a9();
        _0x3d3f7d._0x52f8a9();
    }

    function _0xcaca1e(address _0x054c29, address _0x21aca8) external _0x50b0ca {
        require(_0xa25b1b != address(0));
        _0xa25b1b._0xcaca1e(_0x054c29,_0x21aca8);
    }
}


contract PandaMinting is PandaAuction {


    uint256 public constant GEN0_CREATION_LIMIT = 45000;


    uint256 public constant GEN0_STARTING_PRICE = 100 finney;
    uint256 public constant GEN0_AUCTION_DURATION = 1 days;
    uint256 public constant OPEN_PACKAGE_PRICE = 10 finney;


    function _0x28151f(uint256[2] _0x002594, uint256 _0xe2ec33, address _0xb09ea4) external _0x1b90b1 {
        address _0x89f4b3 = _0xb09ea4;
        if (_0x89f4b3 == address(0)) {
            _0x89f4b3 = _0x47e7fd;
        }

        _0x7c368a(0, 0, _0xe2ec33, _0x002594, _0x89f4b3);
    }


    function _0xa1e975(uint256[2] _0x002594,uint256 _0xe2ec33,uint256 _0xe89e39)
        external
        payable
        _0x1b90b1
        _0x987d7e
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 _0x336df9 = _0x7c368a(0, 0, _0xe2ec33, _0x002594, _0x05ca4e);
        _0x05ca4e._0xa1e975(_0x336df9,_0xe89e39);
    }


    function _0x3d659f(uint256 _0xf4c62a) external _0x1b90b1 {
        require(_0x202665(msg.sender, _0xf4c62a));


        _0x7db7d7(_0xf4c62a, _0x05ca4e);

        _0x05ca4e._0x3d659f(
            _0xf4c62a,
            _0x662d62(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }


    function _0x662d62() internal view returns(uint256) {
        uint256 _0xe02d71 = _0x05ca4e._0x04c48a();

        require(_0xe02d71 == uint256(uint128(_0xe02d71)));

        uint256 _0xaf29be = _0xe02d71 + (_0xe02d71 / 2);


        if (_0xaf29be < GEN0_STARTING_PRICE) {
            if (1 == 1) { _0xaf29be = GEN0_STARTING_PRICE; }
        }

        return _0xaf29be;
    }
}


contract PandaCore is PandaMinting {


    address public _0x1f277f;


    function PandaCore() public {

        _0x4f1477 = true;


        _0xdff1dc = msg.sender;


        _0x47e7fd = msg.sender;


    }


    function _0x357377() external _0x25a11b _0x07ba1b {

        require(_0x29fed0.length == 0);

        uint256[2] memory _0x002594 = [uint256(-1),uint256(-1)];

        _0x0f19eb[1] = 100;
       _0x7c368a(0, 0, 0, _0x002594, address(0));
    }


    function _0x9551d6(address _0x2cdabd) external _0x25a11b _0x07ba1b {

        if (1 == 1) { _0x1f277f = _0x2cdabd; }
        ContractUpgrade(_0x2cdabd);
    }


    function() external payable {
        require(
            msg.sender == address(_0x05ca4e) ||
            msg.sender == address(_0x3d3f7d)
        );
    }


    function _0x27c705(uint256 _0x80cf62)
        external
        view
        returns (
        bool _0x61f17e,
        bool _0x6cc4a0,
        uint256 _0x918733,
        uint256 _0xc74776,
        uint256 _0x0215e4,
        uint256 _0x11d14e,
        uint256 _0xdeaeee,
        uint256 _0xcf44ee,
        uint256 _0xfbf4d7,
        uint256[2] _0x7f23e0
    ) {
        Panda storage _0x870134 = _0x29fed0[_0x80cf62];


        _0x61f17e = (_0x870134._0x0215e4 != 0);
        _0x6cc4a0 = (_0x870134._0xf8f9e8 <= block.number);
        _0x918733 = uint256(_0x870134._0x918733);
        _0xc74776 = uint256(_0x870134._0xf8f9e8);
        _0x0215e4 = uint256(_0x870134._0x0215e4);
        _0x11d14e = uint256(_0x870134._0x11d14e);
        _0xdeaeee = uint256(_0x870134._0xdeaeee);
        _0xcf44ee = uint256(_0x870134._0xcf44ee);
        _0xfbf4d7 = uint256(_0x870134._0xfbf4d7);
        _0x7f23e0 = _0x870134._0x7f23e0;
    }


    function _0xca0727() public _0x25a11b _0x07ba1b {
        require(_0x05ca4e != address(0));
        require(_0x3d3f7d != address(0));
        require(_0xcd58f2 != address(0));
        require(_0x1f277f == address(0));


        super._0xca0727();
    }


    function _0x52f8a9() external _0x2c6f2e {
        uint256 balance = this.balance;

        uint256 _0x2a34b0 = (_0xb3b0ba + 1) * _0xd36f6c;

        if (balance > _0x2a34b0) {
            _0x75ca59.send(balance - _0x2a34b0);
        }
    }
}