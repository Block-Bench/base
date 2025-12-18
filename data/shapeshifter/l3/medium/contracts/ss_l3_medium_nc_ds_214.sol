pragma solidity ^0.4.24;

contract ERC20 {
    function _0x49a9d9() constant returns (uint _0x760bb5);
    function _0xf3f607( address _0x7ac5c1 ) constant returns (uint value);
    function _0x2417a5( address _0x1b19dc, address _0xc1441e ) constant returns (uint _0x28ad66);

    function transfer( address _0x8e674c, uint value) returns (bool _0xa2fdf8);
    function _0x098b75( address from, address _0x8e674c, uint value) returns (bool _0xa2fdf8);
    function _0xe3d056( address _0xc1441e, uint value ) returns (bool _0xa2fdf8);

    event Transfer( address indexed from, address indexed _0x8e674c, uint value);
    event Approval( address indexed _0x1b19dc, address indexed _0xc1441e, uint value);
}
contract Ownable {
  address public _0x1b19dc;

  function Ownable() {
    _0x1b19dc = msg.sender;
  }

  modifier _0x5ba008() {
    require(msg.sender == _0x1b19dc);
    _;
  }

  function _0xc45e45(address _0x5a267d) _0x5ba008 {
    if (_0x5a267d != address(0)) {
      if (block.timestamp > 0) { _0x1b19dc = _0x5a267d; }
    }
  }

}


contract ERC721 {

    function _0x49a9d9() public view returns (uint256 _0xaff473);
    function _0xf3f607(address _0x144d59) public view returns (uint256 balance);
    function _0x70b986(uint256 _0xe6b571) external view returns (address _0x1b19dc);
    function _0xe3d056(address _0x8fc99e, uint256 _0xe6b571) external;
    function transfer(address _0x8fc99e, uint256 _0xe6b571) external;
    function _0x098b75(address _0x88faf9, address _0x8fc99e, uint256 _0xe6b571) external;


    event Transfer(address from, address _0x8e674c, uint256 _0x7ac0c4);
    event Approval(address _0x1b19dc, address _0xdf3bc2, uint256 _0x7ac0c4);


    function _0x61598d(bytes4 _0x2b7ffc) external view returns (bool);
}

contract GeneScienceInterface {

    function _0x40cef8() public pure returns (bool);


    function _0x38321b(uint256[2] _0xdac696, uint256[2] _0x58f878,uint256 _0xe15868,uint256 _0x5c4041, uint256 _0x3e8c87) public returns (uint256[2]);

    function _0x7e8128(uint256[2] _0x82c179) public view returns(uint256);


    function _0x7352a1(uint256[2] _0x82c179) public view returns(uint256);


    function _0x79044c(uint256[2] _0x82c179) public view returns(uint256);

    function _0x316167(uint256[2] _0x962e8d) public returns(uint256[2]);
}


contract PandaAccessControl {


    event ContractUpgrade(address _0xc2e3f6);


    address public _0x50c4ae;
    address public _0x159ced;
    address public _0x7682f4;


    bool public _0xefa17e = false;


    modifier _0xd3ce9c() {
        require(msg.sender == _0x50c4ae);
        _;
    }


    modifier _0xdfeaf4() {
        require(msg.sender == _0x159ced);
        _;
    }


    modifier _0x480e18() {
        require(msg.sender == _0x7682f4);
        _;
    }

    modifier _0x31ec4b() {
        require(
            msg.sender == _0x7682f4 ||
            msg.sender == _0x50c4ae ||
            msg.sender == _0x159ced
        );
        _;
    }


    function _0x785dcd(address _0x7b45cc) external _0xd3ce9c {
        require(_0x7b45cc != address(0));

        _0x50c4ae = _0x7b45cc;
    }


    function _0x8b14ab(address _0x08b6d9) external _0xd3ce9c {
        require(_0x08b6d9 != address(0));

        _0x159ced = _0x08b6d9;
    }


    function _0x1fb4de(address _0x041161) external _0xd3ce9c {
        require(_0x041161 != address(0));

        _0x7682f4 = _0x041161;
    }


    modifier _0xb1b00b() {
        require(!_0xefa17e);
        _;
    }


    modifier _0xe7c49d {
        require(_0xefa17e);
        _;
    }


    function _0x18f13f() external _0x31ec4b _0xb1b00b {
        _0xefa17e = true;
    }


    function _0x344a9d() public _0xd3ce9c _0xe7c49d {

        _0xefa17e = false;
    }
}


contract PandaBase is PandaAccessControl {


    uint256 public constant GEN0_TOTAL_COUNT = 16200;
    uint256 public _0xda8fa5;


    event Birth(address _0x1b19dc, uint256 _0xf6f4a7, uint256 _0xdb3659, uint256 _0x8b6a36, uint256[2] _0xa55f04);


    event Transfer(address from, address _0x8e674c, uint256 _0x7ac0c4);


    struct Panda {


        uint256[2] _0xa55f04;


        uint64 _0xf7f2ba;


        uint64 _0x7cd360;


        uint32 _0xdb3659;
        uint32 _0x8b6a36;


        uint32 _0xac30de;


        uint16 _0x676d0f;


        uint16 _0x1d0791;
    }


    uint32[9] public _0x9360d1 = [
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


    uint256 public _0xa6a440 = 15;


    Panda[] _0x83f9be;


    mapping (uint256 => address) public _0x7ed4bf;


    mapping (address => uint256) _0x31cb13;


    mapping (uint256 => address) public _0xe846c4;


    mapping (uint256 => address) public _0x13fd6e;


    SaleClockAuction public _0x3c50ba;


    SiringClockAuction public _0xba0376;


    GeneScienceInterface public _0x79bdcc;

    SaleClockAuctionERC20 public _0xa1d48b;


    mapping (uint256 => uint256) public _0x3c636a;
    mapping (uint256 => uint256) public _0xa421ef;


    function _0x00e385(uint256 _0xbd5784) view external returns(uint256) {
        return _0x3c636a[_0xbd5784];
    }

    function _0x82bad5(uint256 _0xbd5784) view external returns(uint256) {
        return _0xa421ef[_0xbd5784];
    }

    function _0x248a59(uint256 _0xbd5784,uint256 _0x763e9c) external _0x31ec4b {
        require (_0x3c636a[_0xbd5784]==0);
        require (_0x763e9c==uint256(uint32(_0x763e9c)));
        _0x3c636a[_0xbd5784] = _0x763e9c;
    }

    function _0xd017f6(uint256 _0x7572fa) view external returns(uint256) {
        Panda memory _0x3a6fce = _0x83f9be[_0x7572fa];
        return _0x79bdcc._0x79044c(_0x3a6fce._0xa55f04);
    }


    function _0x1775a9(address _0x88faf9, address _0x8fc99e, uint256 _0xe6b571) internal {

        _0x31cb13[_0x8fc99e]++;

        _0x7ed4bf[_0xe6b571] = _0x8fc99e;

        if (_0x88faf9 != address(0)) {
            _0x31cb13[_0x88faf9]--;

            delete _0x13fd6e[_0xe6b571];

            delete _0xe846c4[_0xe6b571];
        }

        Transfer(_0x88faf9, _0x8fc99e, _0xe6b571);
    }


    function _0xec0b14(
        uint256 _0xe581b6,
        uint256 _0xfc7f1d,
        uint256 _0xe846a5,
        uint256[2] _0x91561f,
        address _0x144d59
    )
        internal
        returns (uint)
    {


        require(_0xe581b6 == uint256(uint32(_0xe581b6)));
        require(_0xfc7f1d == uint256(uint32(_0xfc7f1d)));
        require(_0xe846a5 == uint256(uint16(_0xe846a5)));


        uint16 _0x676d0f = 0;

        if (_0x83f9be.length>0){
            uint16 _0x375310 = uint16(_0x79bdcc._0x7e8128(_0x91561f));
            if (_0x375310==0) {
                _0x375310 = 1;
            }
            _0x676d0f = 1000/_0x375310;
            if (_0x676d0f%10 < 5){
                _0x676d0f = _0x676d0f/10;
            }else{
                _0x676d0f = _0x676d0f/10 + 1;
            }
            _0x676d0f = _0x676d0f - 1;
            if (_0x676d0f > 8) {
                _0x676d0f = 8;
            }
            uint256 _0xbd5784 = _0x79bdcc._0x79044c(_0x91561f);
            if (_0xbd5784>0 && _0x3c636a[_0xbd5784]<=_0xa421ef[_0xbd5784]) {
                _0x91561f = _0x79bdcc._0x316167(_0x91561f);
                _0xbd5784 = 0;
            }

            if (_0xbd5784 == 1){
                _0x676d0f = 5;
            }


            if (_0xbd5784>0){
                _0xa421ef[_0xbd5784] = _0xa421ef[_0xbd5784] + 1;
            }

            if (_0xe846a5 <= 1 && _0xbd5784 != 1){
                require(_0xda8fa5<GEN0_TOTAL_COUNT);
                _0xda8fa5++;
            }
        }

        Panda memory _0x0c4f29 = Panda({
            _0xa55f04: _0x91561f,
            _0xf7f2ba: uint64(_0x342d59),
            _0x7cd360: 0,
            _0xdb3659: uint32(_0xe581b6),
            _0x8b6a36: uint32(_0xfc7f1d),
            _0xac30de: 0,
            _0x676d0f: _0x676d0f,
            _0x1d0791: uint16(_0xe846a5)
        });
        uint256 _0x44d598 = _0x83f9be.push(_0x0c4f29) - 1;


        require(_0x44d598 == uint256(uint32(_0x44d598)));


        Birth(
            _0x144d59,
            _0x44d598,
            uint256(_0x0c4f29._0xdb3659),
            uint256(_0x0c4f29._0x8b6a36),
            _0x0c4f29._0xa55f04
        );


        _0x1775a9(0, _0x144d59, _0x44d598);

        return _0x44d598;
    }


    function _0x17632c(uint256 _0xb72fd5) external _0x31ec4b {
        require(_0xb72fd5 < _0x9360d1[0]);
        _0xa6a440 = _0xb72fd5;
    }
}


contract ERC721Metadata {

    function _0xcd7bc5(uint256 _0xe6b571, string) public view returns (bytes32[4] _0x6fa760, uint256 _0xe589eb) {
        if (_0xe6b571 == 1) {
            _0x6fa760[0] = "Hello World! :D";
            _0xe589eb = 15;
        } else if (_0xe6b571 == 2) {
            _0x6fa760[0] = "I would definitely choose a medi";
            _0x6fa760[1] = "um length string.";
            if (1 == 1) { _0xe589eb = 49; }
        } else if (_0xe6b571 == 3) {
            _0x6fa760[0] = "Lorem ipsum dolor sit amet, mi e";
            _0x6fa760[1] = "st accumsan dapibus augue lorem,";
            _0x6fa760[2] = " tristique vestibulum id, libero";
            _0x6fa760[3] = " suscipit varius sapien aliquam.";
            if (gasleft() > 0) { _0xe589eb = 128; }
        }
    }
}


contract PandaOwnership is PandaBase, ERC721 {


    string public constant _0xa3d2f6 = "PandaEarth";
    string public constant _0xa33f3d = "PE";

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(_0x46c7d6('_0x61598d(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(_0x46c7d6('_0xa3d2f6()')) ^
        bytes4(_0x46c7d6('_0xa33f3d()')) ^
        bytes4(_0x46c7d6('_0x49a9d9()')) ^
        bytes4(_0x46c7d6('_0xf3f607(address)')) ^
        bytes4(_0x46c7d6('_0x70b986(uint256)')) ^
        bytes4(_0x46c7d6('_0xe3d056(address,uint256)')) ^
        bytes4(_0x46c7d6('transfer(address,uint256)')) ^
        bytes4(_0x46c7d6('_0x098b75(address,address,uint256)')) ^
        bytes4(_0x46c7d6('_0x9c4d1d(address)')) ^
        bytes4(_0x46c7d6('tokenMetadata(uint256,string)'));


    function _0x61598d(bytes4 _0x2b7ffc) external view returns (bool)
    {


        return ((_0x2b7ffc == InterfaceSignature_ERC165) || (_0x2b7ffc == InterfaceSignature_ERC721));
    }


    function _0x1022ca(address _0x46bf26, uint256 _0xe6b571) internal view returns (bool) {
        return _0x7ed4bf[_0xe6b571] == _0x46bf26;
    }


    function _0x4bfca7(address _0x46bf26, uint256 _0xe6b571) internal view returns (bool) {
        return _0xe846c4[_0xe6b571] == _0x46bf26;
    }


    function _0x1b7941(uint256 _0xe6b571, address _0x252c00) internal {
        _0xe846c4[_0xe6b571] = _0x252c00;
    }


    function _0xf3f607(address _0x144d59) public view returns (uint256 _0xe589eb) {
        return _0x31cb13[_0x144d59];
    }


    function transfer(
        address _0x8fc99e,
        uint256 _0xe6b571
    )
        external
        _0xb1b00b
    {

        require(_0x8fc99e != address(0));


        require(_0x8fc99e != address(this));


        require(_0x8fc99e != address(_0x3c50ba));
        require(_0x8fc99e != address(_0xba0376));


        require(_0x1022ca(msg.sender, _0xe6b571));


        _0x1775a9(msg.sender, _0x8fc99e, _0xe6b571);
    }


    function _0xe3d056(
        address _0x8fc99e,
        uint256 _0xe6b571
    )
        external
        _0xb1b00b
    {

        require(_0x1022ca(msg.sender, _0xe6b571));


        _0x1b7941(_0xe6b571, _0x8fc99e);


        Approval(msg.sender, _0x8fc99e, _0xe6b571);
    }


    function _0x098b75(
        address _0x88faf9,
        address _0x8fc99e,
        uint256 _0xe6b571
    )
        external
        _0xb1b00b
    {

        require(_0x8fc99e != address(0));


        require(_0x8fc99e != address(this));

        require(_0x4bfca7(msg.sender, _0xe6b571));
        require(_0x1022ca(_0x88faf9, _0xe6b571));


        _0x1775a9(_0x88faf9, _0x8fc99e, _0xe6b571);
    }


    function _0x49a9d9() public view returns (uint) {
        return _0x83f9be.length - 1;
    }


    function _0x70b986(uint256 _0xe6b571)
        external
        view
        returns (address _0x1b19dc)
    {
        _0x1b19dc = _0x7ed4bf[_0xe6b571];

        require(_0x1b19dc != address(0));
    }


    function _0x9c4d1d(address _0x144d59) external view returns(uint256[] _0x33efaa) {
        uint256 _0xc74df4 = _0xf3f607(_0x144d59);

        if (_0xc74df4 == 0) {

            return new uint256[](0);
        } else {
            uint256[] memory _0x44d527 = new uint256[](_0xc74df4);
            uint256 _0x0b40b4 = _0x49a9d9();
            uint256 _0x774125 = 0;


            uint256 _0x528890;

            for (_0x528890 = 1; _0x528890 <= _0x0b40b4; _0x528890++) {
                if (_0x7ed4bf[_0x528890] == _0x144d59) {
                    _0x44d527[_0x774125] = _0x528890;
                    _0x774125++;
                }
            }

            return _0x44d527;
        }
    }


    function _0x2e034c(uint _0xb1c7d3, uint _0x3d37a4, uint _0x1783e2) private view {

        for(; _0x1783e2 >= 32; _0x1783e2 -= 32) {
            assembly {
                mstore(_0xb1c7d3, mload(_0x3d37a4))
            }
            _0xb1c7d3 += 32;
            _0x3d37a4 += 32;
        }


        uint256 _0xd0f89d = 256 ** (32 - _0x1783e2) - 1;
        assembly {
            let _0xc298c4 := and(mload(_0x3d37a4), not(_0xd0f89d))
            let _0x1e6d8c := and(mload(_0xb1c7d3), _0xd0f89d)
            mstore(_0xb1c7d3, or(_0x1e6d8c, _0xc298c4))
        }
    }


    function _0x4956c8(bytes32[4] _0x08f457, uint256 _0xd35013) private view returns (string) {
        var _0x3d90d8 = new string(_0xd35013);
        uint256 _0xe1b589;
        uint256 _0xa3afa8;

        assembly {
            _0xe1b589 := add(_0x3d90d8, 32)
            _0xa3afa8 := _0x08f457
        }

        _0x2e034c(_0xe1b589, _0xa3afa8, _0xd35013);

        return _0x3d90d8;
    }

}


contract PandaBreeding is PandaOwnership {

    uint256 public constant GENSIS_TOTAL_COUNT = 100;


    event Pregnant(address _0x1b19dc, uint256 _0xdb3659, uint256 _0x8b6a36, uint256 _0x7cd360);

    event Abortion(address _0x1b19dc, uint256 _0xdb3659, uint256 _0x8b6a36);


    uint256 public _0x679c14 = 2 finney;


    uint256 public _0xa6197a;

    mapping(uint256 => address) _0xccb616;


    function _0x266bc6(address _0x32d23c) external _0xd3ce9c {
        GeneScienceInterface _0x03d3aa = GeneScienceInterface(_0x32d23c);


        require(_0x03d3aa._0x40cef8());


        if (1 == 1) { _0x79bdcc = _0x03d3aa; }
    }


    function _0x08e46f(Panda _0x8dd728) internal view returns(bool) {


        return (_0x8dd728._0xac30de == 0) && (_0x8dd728._0x7cd360 <= uint64(block.number));
    }


    function _0x55a52e(uint256 _0xfc7f1d, uint256 _0xe581b6) internal view returns(bool) {
        address _0xa79b14 = _0x7ed4bf[_0xe581b6];
        address _0x564782 = _0x7ed4bf[_0xfc7f1d];


        return (_0xa79b14 == _0x564782 || _0x13fd6e[_0xfc7f1d] == _0xa79b14);
    }


    function _0x0e7097(Panda storage _0x005ce2) internal {

        _0x005ce2._0x7cd360 = uint64((_0x9360d1[_0x005ce2._0x676d0f] / _0xa6a440) + block.number);


        if (_0x005ce2._0x676d0f < 8 && _0x79bdcc._0x79044c(_0x005ce2._0xa55f04) != 1) {
            _0x005ce2._0x676d0f += 1;
        }
    }


    function _0xa6741b(address _0x05d8b6, uint256 _0xfc7f1d)
    external
    _0xb1b00b {
        require(_0x1022ca(msg.sender, _0xfc7f1d));
        _0x13fd6e[_0xfc7f1d] = _0x05d8b6;
    }


    function _0x9309ae(uint256 _0x0f666a) external _0x480e18 {
        if (1 == 1) { _0x679c14 = _0x0f666a; }
    }


    function _0xeb2697(Panda _0x48e4f8) private view returns(bool) {
        return (_0x48e4f8._0xac30de != 0) && (_0x48e4f8._0x7cd360 <= uint64(block.number));
    }


    function _0x793690(uint256 _0xd161a3)
    public
    view
    returns(bool) {
        require(_0xd161a3 > 0);
        Panda storage _0x4d6fb3 = _0x83f9be[_0xd161a3];
        return _0x08e46f(_0x4d6fb3);
    }


    function _0x12717b(uint256 _0xd161a3)
    public
    view
    returns(bool) {
        require(_0xd161a3 > 0);

        return _0x83f9be[_0xd161a3]._0xac30de != 0;
    }


    function _0x8c6ffd(
        Panda storage _0x48e4f8,
        uint256 _0xe581b6,
        Panda storage _0xdaea44,
        uint256 _0xfc7f1d
    )
    private
    view
    returns(bool) {

        if (_0xe581b6 == _0xfc7f1d) {
            return false;
        }


        if (_0x48e4f8._0xdb3659 == _0xfc7f1d || _0x48e4f8._0x8b6a36 == _0xfc7f1d) {
            return false;
        }
        if (_0xdaea44._0xdb3659 == _0xe581b6 || _0xdaea44._0x8b6a36 == _0xe581b6) {
            return false;
        }


        if (_0xdaea44._0xdb3659 == 0 || _0x48e4f8._0xdb3659 == 0) {
            return true;
        }


        if (_0xdaea44._0xdb3659 == _0x48e4f8._0xdb3659 || _0xdaea44._0xdb3659 == _0x48e4f8._0x8b6a36) {
            return false;
        }
        if (_0xdaea44._0x8b6a36 == _0x48e4f8._0xdb3659 || _0xdaea44._0x8b6a36 == _0x48e4f8._0x8b6a36) {
            return false;
        }


        if (_0x79bdcc._0x7352a1(_0x48e4f8._0xa55f04) + _0x79bdcc._0x7352a1(_0xdaea44._0xa55f04) != 1) {
            return false;
        }


        return true;
    }


    function _0xfc0085(uint256 _0xe581b6, uint256 _0xfc7f1d)
    internal
    view
    returns(bool) {
        Panda storage _0xb1ed00 = _0x83f9be[_0xe581b6];
        Panda storage _0x15b6ca = _0x83f9be[_0xfc7f1d];
        return _0x8c6ffd(_0xb1ed00, _0xe581b6, _0x15b6ca, _0xfc7f1d);
    }


    function _0x8e6b38(uint256 _0xe581b6, uint256 _0xfc7f1d)
    external
    view
    returns(bool) {
        require(_0xe581b6 > 0);
        require(_0xfc7f1d > 0);
        Panda storage _0xb1ed00 = _0x83f9be[_0xe581b6];
        Panda storage _0x15b6ca = _0x83f9be[_0xfc7f1d];
        return _0x8c6ffd(_0xb1ed00, _0xe581b6, _0x15b6ca, _0xfc7f1d) &&
            _0x55a52e(_0xfc7f1d, _0xe581b6);
    }

    function _0xb49ed2(uint256 _0xe581b6, uint256 _0xfc7f1d) internal returns(uint256, uint256) {
        if (_0x79bdcc._0x7352a1(_0x83f9be[_0xe581b6]._0xa55f04) == 1) {
            return (_0xfc7f1d, _0xe581b6);
        } else {
            return (_0xe581b6, _0xfc7f1d);
        }
    }


    function _0xb42f96(uint256 _0xe581b6, uint256 _0xfc7f1d, address _0x144d59) internal {

        (_0xe581b6, _0xfc7f1d) = _0xb49ed2(_0xe581b6, _0xfc7f1d);

        Panda storage _0x15b6ca = _0x83f9be[_0xfc7f1d];
        Panda storage _0xb1ed00 = _0x83f9be[_0xe581b6];


        _0xb1ed00._0xac30de = uint32(_0xfc7f1d);


        _0x0e7097(_0x15b6ca);
        _0x0e7097(_0xb1ed00);


        delete _0x13fd6e[_0xe581b6];
        delete _0x13fd6e[_0xfc7f1d];


        _0xa6197a++;

        _0xccb616[_0xe581b6] = _0x144d59;


        Pregnant(_0x7ed4bf[_0xe581b6], _0xe581b6, _0xfc7f1d, _0xb1ed00._0x7cd360);
    }


    function _0x497d24(uint256 _0xe581b6, uint256 _0xfc7f1d)
    external
    payable
    _0xb1b00b {

        require(msg.value >= _0x679c14);


        require(_0x1022ca(msg.sender, _0xe581b6));


        require(_0x55a52e(_0xfc7f1d, _0xe581b6));


        Panda storage _0xb1ed00 = _0x83f9be[_0xe581b6];


        require(_0x08e46f(_0xb1ed00));


        Panda storage _0x15b6ca = _0x83f9be[_0xfc7f1d];


        require(_0x08e46f(_0x15b6ca));


        require(_0x8c6ffd(
            _0xb1ed00,
            _0xe581b6,
            _0x15b6ca,
            _0xfc7f1d
        ));


        _0xb42f96(_0xe581b6, _0xfc7f1d, msg.sender);
    }


    function _0x0d661e(uint256 _0xe581b6, uint256[2] _0x9cec1f, uint256[2] _0x44c83d)
    external
    _0xb1b00b
    _0x31ec4b
    returns(uint256) {

        Panda storage _0xb1ed00 = _0x83f9be[_0xe581b6];


        require(_0xb1ed00._0xf7f2ba != 0);


        require(_0xeb2697(_0xb1ed00));


        uint256 _0x8b6a36 = _0xb1ed00._0xac30de;
        Panda storage _0x15b6ca = _0x83f9be[_0x8b6a36];


        uint16 _0xa6fe98 = _0xb1ed00._0x1d0791;
        if (_0x15b6ca._0x1d0791 > _0xb1ed00._0x1d0791) {
            _0xa6fe98 = _0x15b6ca._0x1d0791;
        }


        uint256[2] memory _0xdf88c7 = _0x9cec1f;

        uint256 _0x38cd73 = 0;


        uint256 _0xd836c0 = (_0x79bdcc._0x7e8128(_0xb1ed00._0xa55f04) + _0x79bdcc._0x7e8128(_0x15b6ca._0xa55f04)) / 2 + _0x44c83d[0];
        if (_0xd836c0 >= (_0xa6fe98 + 1) * _0x44c83d[1]) {
            _0xd836c0 = _0xd836c0 - (_0xa6fe98 + 1) * _0x44c83d[1];
        } else {
            _0xd836c0 = 0;
        }
        if (_0xa6fe98 == 0 && _0xda8fa5 == GEN0_TOTAL_COUNT) {
            _0xd836c0 = 0;
        }
        if (uint256(_0x46c7d6(block.blockhash(block.number - 2), _0x342d59)) % 100 < _0xd836c0) {

            address _0x1b19dc = _0xccb616[_0xe581b6];
            _0x38cd73 = _0xec0b14(_0xe581b6, _0xb1ed00._0xac30de, _0xa6fe98 + 1, _0xdf88c7, _0x1b19dc);
        } else {
            Abortion(_0x7ed4bf[_0xe581b6], _0xe581b6, _0x8b6a36);
        }


        delete _0xb1ed00._0xac30de;


        _0xa6197a--;


        msg.sender.send(_0x679c14);

        delete _0xccb616[_0xe581b6];


        return _0x38cd73;
    }
}


contract ClockAuctionBase {


    struct Auction {

        address _0x3d47c6;

        uint128 _0x056ce4;

        uint128 _0x3802fe;

        uint64 _0x3b0bc2;


        uint64 _0x4d4008;

        uint64 _0x6235b8;
    }


    ERC721 public _0x6eeda2;


    uint256 public _0x7d4e55;


    mapping (uint256 => Auction) _0xd87d14;

    event AuctionCreated(uint256 _0x7ac0c4, uint256 _0x056ce4, uint256 _0x3802fe, uint256 _0x3b0bc2);
    event AuctionSuccessful(uint256 _0x7ac0c4, uint256 _0xf7c284, address _0x319a06);
    event AuctionCancelled(uint256 _0x7ac0c4);


    function _0x1022ca(address _0x46bf26, uint256 _0xe6b571) internal view returns (bool) {
        return (_0x6eeda2._0x70b986(_0xe6b571) == _0x46bf26);
    }


    function _0x20f94b(address _0x144d59, uint256 _0xe6b571) internal {

        _0x6eeda2._0x098b75(_0x144d59, this, _0xe6b571);
    }


    function _0x1775a9(address _0xdcab94, uint256 _0xe6b571) internal {

        _0x6eeda2.transfer(_0xdcab94, _0xe6b571);
    }


    function _0x70108f(uint256 _0xe6b571, Auction _0x072d27) internal {


        require(_0x072d27._0x3b0bc2 >= 1 minutes);

        _0xd87d14[_0xe6b571] = _0x072d27;

        AuctionCreated(
            uint256(_0xe6b571),
            uint256(_0x072d27._0x056ce4),
            uint256(_0x072d27._0x3802fe),
            uint256(_0x072d27._0x3b0bc2)
        );
    }


    function _0x633cda(uint256 _0xe6b571, address _0xde1afc) internal {
        _0x7c5c50(_0xe6b571);
        _0x1775a9(_0xde1afc, _0xe6b571);
        AuctionCancelled(_0xe6b571);
    }


    function _0x06975d(uint256 _0xe6b571, uint256 _0x125c85)
        internal
        returns (uint256)
    {

        Auction storage _0x1d0b83 = _0xd87d14[_0xe6b571];


        require(_0x69cef1(_0x1d0b83));


        uint256 _0x5c9a2e = _0x79e659(_0x1d0b83);
        require(_0x125c85 >= _0x5c9a2e);


        address _0x3d47c6 = _0x1d0b83._0x3d47c6;


        _0x7c5c50(_0xe6b571);


        if (_0x5c9a2e > 0) {


            uint256 _0x408d59 = _0x3a37bf(_0x5c9a2e);
            uint256 _0x858154 = _0x5c9a2e - _0x408d59;


            _0x3d47c6.transfer(_0x858154);
        }


        uint256 _0xdfd2e7 = _0x125c85 - _0x5c9a2e;


        msg.sender.transfer(_0xdfd2e7);


        AuctionSuccessful(_0xe6b571, _0x5c9a2e, msg.sender);

        return _0x5c9a2e;
    }


    function _0x7c5c50(uint256 _0xe6b571) internal {
        delete _0xd87d14[_0xe6b571];
    }


    function _0x69cef1(Auction storage _0x072d27) internal view returns (bool) {
        return (_0x072d27._0x4d4008 > 0);
    }


    function _0x79e659(Auction storage _0x072d27)
        internal
        view
        returns (uint256)
    {
        uint256 _0x23ab89 = 0;


        if (_0x342d59 > _0x072d27._0x4d4008) {
            _0x23ab89 = _0x342d59 - _0x072d27._0x4d4008;
        }

        return _0x96e7f6(
            _0x072d27._0x056ce4,
            _0x072d27._0x3802fe,
            _0x072d27._0x3b0bc2,
            _0x23ab89
        );
    }


    function _0x96e7f6(
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34,
        uint256 _0x8d1370
    )
        internal
        pure
        returns (uint256)
    {


        if (_0x8d1370 >= _0x87bd34) {


            return _0x47f7c7;
        } else {


            int256 _0x38f15b = int256(_0x47f7c7) - int256(_0x154331);


            int256 _0xe1b931 = _0x38f15b * int256(_0x8d1370) / int256(_0x87bd34);


            int256 _0x64951d = int256(_0x154331) + _0xe1b931;

            return uint256(_0x64951d);
        }
    }


    function _0x3a37bf(uint256 _0xa07077) internal view returns (uint256) {


        return _0xa07077 * _0x7d4e55 / 10000;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public _0xefa17e = false;

  modifier _0xb1b00b() {
    require(!_0xefa17e);
    _;
  }

  modifier _0xe7c49d {
    require(_0xefa17e);
    _;
  }

  function _0x18f13f() _0x5ba008 _0xb1b00b returns (bool) {
    if (true) { _0xefa17e = true; }
    Pause();
    return true;
  }

  function _0x344a9d() _0x5ba008 _0xe7c49d returns (bool) {
    if (true) { _0xefa17e = false; }
    Unpause();
    return true;
  }
}


contract ClockAuction is Pausable, ClockAuctionBase {


    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);


    function ClockAuction(address _0x4149e9, uint256 _0x89656c) public {
        require(_0x89656c <= 10000);
        if (block.timestamp > 0) { _0x7d4e55 = _0x89656c; }

        ERC721 _0x03d3aa = ERC721(_0x4149e9);
        require(_0x03d3aa._0x61598d(InterfaceSignature_ERC721));
        if (block.timestamp > 0) { _0x6eeda2 = _0x03d3aa; }
    }


    function _0x2c3937() external {
        address _0x38f123 = address(_0x6eeda2);

        require(
            msg.sender == _0x1b19dc ||
            msg.sender == _0x38f123
        );

        bool _0xd92350 = _0x38f123.send(this.balance);
    }


    function _0xb280b7(
        uint256 _0xe6b571,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34,
        address _0xde1afc
    )
        external
        _0xb1b00b
    {


        require(_0x154331 == uint256(uint128(_0x154331)));
        require(_0x47f7c7 == uint256(uint128(_0x47f7c7)));
        require(_0x87bd34 == uint256(uint64(_0x87bd34)));

        require(_0x1022ca(msg.sender, _0xe6b571));
        _0x20f94b(msg.sender, _0xe6b571);
        Auction memory _0x1d0b83 = Auction(
            _0xde1afc,
            uint128(_0x154331),
            uint128(_0x47f7c7),
            uint64(_0x87bd34),
            uint64(_0x342d59),
            0
        );
        _0x70108f(_0xe6b571, _0x1d0b83);
    }


    function _0xffa76b(uint256 _0xe6b571)
        external
        payable
        _0xb1b00b
    {

        _0x06975d(_0xe6b571, msg.value);
        _0x1775a9(msg.sender, _0xe6b571);
    }


    function _0xd25097(uint256 _0xe6b571)
        external
    {
        Auction storage _0x1d0b83 = _0xd87d14[_0xe6b571];
        require(_0x69cef1(_0x1d0b83));
        address _0x3d47c6 = _0x1d0b83._0x3d47c6;
        require(msg.sender == _0x3d47c6);
        _0x633cda(_0xe6b571, _0x3d47c6);
    }


    function _0x748512(uint256 _0xe6b571)
        _0xe7c49d
        _0x5ba008
        external
    {
        Auction storage _0x1d0b83 = _0xd87d14[_0xe6b571];
        require(_0x69cef1(_0x1d0b83));
        _0x633cda(_0xe6b571, _0x1d0b83._0x3d47c6);
    }


    function _0x798645(uint256 _0xe6b571)
        external
        view
        returns
    (
        address _0x3d47c6,
        uint256 _0x056ce4,
        uint256 _0x3802fe,
        uint256 _0x3b0bc2,
        uint256 _0x4d4008
    ) {
        Auction storage _0x1d0b83 = _0xd87d14[_0xe6b571];
        require(_0x69cef1(_0x1d0b83));
        return (
            _0x1d0b83._0x3d47c6,
            _0x1d0b83._0x056ce4,
            _0x1d0b83._0x3802fe,
            _0x1d0b83._0x3b0bc2,
            _0x1d0b83._0x4d4008
        );
    }


    function _0x7360fb(uint256 _0xe6b571)
        external
        view
        returns (uint256)
    {
        Auction storage _0x1d0b83 = _0xd87d14[_0xe6b571];
        require(_0x69cef1(_0x1d0b83));
        return _0x79e659(_0x1d0b83);
    }

}


contract SiringClockAuction is ClockAuction {


    bool public _0xb4afd8 = true;


    function SiringClockAuction(address _0xff50c6, uint256 _0x89656c) public
        ClockAuction(_0xff50c6, _0x89656c) {}


    function _0xb280b7(
        uint256 _0xe6b571,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34,
        address _0xde1afc
    )
        external
    {


        require(_0x154331 == uint256(uint128(_0x154331)));
        require(_0x47f7c7 == uint256(uint128(_0x47f7c7)));
        require(_0x87bd34 == uint256(uint64(_0x87bd34)));

        require(msg.sender == address(_0x6eeda2));
        _0x20f94b(_0xde1afc, _0xe6b571);
        Auction memory _0x1d0b83 = Auction(
            _0xde1afc,
            uint128(_0x154331),
            uint128(_0x47f7c7),
            uint64(_0x87bd34),
            uint64(_0x342d59),
            0
        );
        _0x70108f(_0xe6b571, _0x1d0b83);
    }


    function _0xffa76b(uint256 _0xe6b571)
        external
        payable
    {
        require(msg.sender == address(_0x6eeda2));
        address _0x3d47c6 = _0xd87d14[_0xe6b571]._0x3d47c6;

        _0x06975d(_0xe6b571, msg.value);


        _0x1775a9(_0x3d47c6, _0xe6b571);
    }

}


contract SaleClockAuction is ClockAuction {


    bool public _0x4cecb0 = true;


    uint256 public _0x023eb8;
    uint256[5] public _0x0ab9db;
    uint256 public constant SurpriseValue = 10 finney;

    uint256[] CommonPanda;
    uint256[] RarePanda;
    uint256   CommonPandaIndex;
    uint256   RarePandaIndex;


    function SaleClockAuction(address _0xff50c6, uint256 _0x89656c) public
        ClockAuction(_0xff50c6, _0x89656c) {
            CommonPandaIndex = 1;
            RarePandaIndex   = 1;
    }


    function _0xb280b7(
        uint256 _0xe6b571,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34,
        address _0xde1afc
    )
        external
    {


        require(_0x154331 == uint256(uint128(_0x154331)));
        require(_0x47f7c7 == uint256(uint128(_0x47f7c7)));
        require(_0x87bd34 == uint256(uint64(_0x87bd34)));

        require(msg.sender == address(_0x6eeda2));
        _0x20f94b(_0xde1afc, _0xe6b571);
        Auction memory _0x1d0b83 = Auction(
            _0xde1afc,
            uint128(_0x154331),
            uint128(_0x47f7c7),
            uint64(_0x87bd34),
            uint64(_0x342d59),
            0
        );
        _0x70108f(_0xe6b571, _0x1d0b83);
    }

    function _0x41c981(
        uint256 _0xe6b571,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34,
        address _0xde1afc
    )
        external
    {


        require(_0x154331 == uint256(uint128(_0x154331)));
        require(_0x47f7c7 == uint256(uint128(_0x47f7c7)));
        require(_0x87bd34 == uint256(uint64(_0x87bd34)));

        require(msg.sender == address(_0x6eeda2));
        _0x20f94b(_0xde1afc, _0xe6b571);
        Auction memory _0x1d0b83 = Auction(
            _0xde1afc,
            uint128(_0x154331),
            uint128(_0x47f7c7),
            uint64(_0x87bd34),
            uint64(_0x342d59),
            1
        );
        _0x70108f(_0xe6b571, _0x1d0b83);
    }


    function _0xffa76b(uint256 _0xe6b571)
        external
        payable
    {

        uint64 _0x6235b8 = _0xd87d14[_0xe6b571]._0x6235b8;
        uint256 _0x5c9a2e = _0x06975d(_0xe6b571, msg.value);
        _0x1775a9(msg.sender, _0xe6b571);


        if (_0x6235b8 == 1) {

            _0x0ab9db[_0x023eb8 % 5] = _0x5c9a2e;
            _0x023eb8++;
        }
    }

    function _0xb3a7c2(uint256 _0xe6b571,uint256 _0x580195)
        external
    {
        require(msg.sender == address(_0x6eeda2));
        if (_0x580195 == 0) {
            CommonPanda.push(_0xe6b571);
        }else {
            RarePanda.push(_0xe6b571);
        }
    }

    function _0x02b821()
        external
        payable
    {
        bytes32 _0xf43fbb = _0x46c7d6(block.blockhash(block.number),block.blockhash(block.number-1));
        uint256 PandaIndex;
        if (_0xf43fbb[25] > 0xC8) {
            require(uint256(RarePanda.length) >= RarePandaIndex);
            PandaIndex = RarePandaIndex;
            RarePandaIndex ++;

        } else{
            require(uint256(CommonPanda.length) >= CommonPandaIndex);
            PandaIndex = CommonPandaIndex;
            CommonPandaIndex ++;
        }
        _0x1775a9(msg.sender,PandaIndex);
    }

    function _0xc73c60() external view returns(uint256 _0x52f606,uint256 _0x46f9e4) {
        _0x52f606   = CommonPanda.length + 1 - CommonPandaIndex;
        _0x46f9e4 = RarePanda.length + 1 - RarePandaIndex;
    }

    function _0x4b3e06() external view returns (uint256) {
        uint256 _0xf3a032 = 0;
        for (uint256 i = 0; i < 5; i++) {
            _0xf3a032 += _0x0ab9db[i];
        }
        return _0xf3a032 / 5;
    }

}


contract SaleClockAuctionERC20 is ClockAuction {

    event AuctionERC20Created(uint256 _0x7ac0c4, uint256 _0x056ce4, uint256 _0x3802fe, uint256 _0x3b0bc2, address _0x688786);


    bool public _0xf6c7f4 = true;

    mapping (uint256 => address) public _0x9fb296;

    mapping (address => uint256) public _0xeaa4fc;

    mapping (address => uint256) public _0x2b687c;


    function SaleClockAuctionERC20(address _0xff50c6, uint256 _0x89656c) public
        ClockAuction(_0xff50c6, _0x89656c) {}

    function _0x8119f9(address _0x9986f8, uint256 _0xd83a06) external{
        require (msg.sender == address(_0x6eeda2));

        require (_0x9986f8 != address(0));

        _0xeaa4fc[_0x9986f8] = _0xd83a06;
    }


    function _0xb280b7(
        uint256 _0xe6b571,
        address _0x4fee2c,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34,
        address _0xde1afc
    )
        external
    {


        require(_0x154331 == uint256(uint128(_0x154331)));
        require(_0x47f7c7 == uint256(uint128(_0x47f7c7)));
        require(_0x87bd34 == uint256(uint64(_0x87bd34)));

        require(msg.sender == address(_0x6eeda2));

        require (_0xeaa4fc[_0x4fee2c] > 0);

        _0x20f94b(_0xde1afc, _0xe6b571);
        Auction memory _0x1d0b83 = Auction(
            _0xde1afc,
            uint128(_0x154331),
            uint128(_0x47f7c7),
            uint64(_0x87bd34),
            uint64(_0x342d59),
            0
        );
        _0xae0286(_0xe6b571, _0x1d0b83, _0x4fee2c);
        _0x9fb296[_0xe6b571] = _0x4fee2c;
    }


    function _0xae0286(uint256 _0xe6b571, Auction _0x072d27, address _0x9986f8) internal {


        require(_0x072d27._0x3b0bc2 >= 1 minutes);

        _0xd87d14[_0xe6b571] = _0x072d27;

        AuctionERC20Created(
            uint256(_0xe6b571),
            uint256(_0x072d27._0x056ce4),
            uint256(_0x072d27._0x3802fe),
            uint256(_0x072d27._0x3b0bc2),
            _0x9986f8
        );
    }

    function _0xffa76b(uint256 _0xe6b571)
        external
        payable{

    }


    function _0x09dd23(uint256 _0xe6b571,uint256 _0x2e42fa)
        external
    {

        address _0x3d47c6 = _0xd87d14[_0xe6b571]._0x3d47c6;
        address _0x9986f8 = _0x9fb296[_0xe6b571];
        require (_0x9986f8 != address(0));
        uint256 _0x5c9a2e = _0x4d88ad(_0x9986f8,msg.sender,_0xe6b571, _0x2e42fa);
        _0x1775a9(msg.sender, _0xe6b571);
        delete _0x9fb296[_0xe6b571];
    }

    function _0xd25097(uint256 _0xe6b571)
        external
    {
        Auction storage _0x1d0b83 = _0xd87d14[_0xe6b571];
        require(_0x69cef1(_0x1d0b83));
        address _0x3d47c6 = _0x1d0b83._0x3d47c6;
        require(msg.sender == _0x3d47c6);
        _0x633cda(_0xe6b571, _0x3d47c6);
        delete _0x9fb296[_0xe6b571];
    }

    function _0x5ec046(address _0x4fee2c, address _0x8fc99e) external returns(bool _0xd92350)  {
        require (_0x2b687c[_0x4fee2c] > 0);
        require(msg.sender == address(_0x6eeda2));
        ERC20(_0x4fee2c).transfer(_0x8fc99e, _0x2b687c[_0x4fee2c]);
    }


    function _0x4d88ad(address _0x4fee2c,address _0x3ae069, uint256 _0xe6b571, uint256 _0x125c85)
        internal
        returns (uint256)
    {

        Auction storage _0x1d0b83 = _0xd87d14[_0xe6b571];


        require(_0x69cef1(_0x1d0b83));

        require (_0x4fee2c != address(0) && _0x4fee2c == _0x9fb296[_0xe6b571]);


        uint256 _0x5c9a2e = _0x79e659(_0x1d0b83);
        require(_0x125c85 >= _0x5c9a2e);


        address _0x3d47c6 = _0x1d0b83._0x3d47c6;


        _0x7c5c50(_0xe6b571);


        if (_0x5c9a2e > 0) {


            uint256 _0x408d59 = _0x3a37bf(_0x5c9a2e);
            uint256 _0x858154 = _0x5c9a2e - _0x408d59;


            require(ERC20(_0x4fee2c)._0x098b75(_0x3ae069,_0x3d47c6,_0x858154));
            if (_0x408d59 > 0){
                require(ERC20(_0x4fee2c)._0x098b75(_0x3ae069,address(this),_0x408d59));
                _0x2b687c[_0x4fee2c] += _0x408d59;
            }
        }


        AuctionSuccessful(_0xe6b571, _0x5c9a2e, msg.sender);

        return _0x5c9a2e;
    }
}


contract PandaAuction is PandaBreeding {


    function _0x48801a(address _0x32d23c) external _0xd3ce9c {
        SaleClockAuction _0x03d3aa = SaleClockAuction(_0x32d23c);


        require(_0x03d3aa._0x4cecb0());


        _0x3c50ba = _0x03d3aa;
    }

    function _0xd108a2(address _0x32d23c) external _0xd3ce9c {
        SaleClockAuctionERC20 _0x03d3aa = SaleClockAuctionERC20(_0x32d23c);


        require(_0x03d3aa._0xf6c7f4());


        _0xa1d48b = _0x03d3aa;
    }


    function _0x8dd8ed(address _0x32d23c) external _0xd3ce9c {
        SiringClockAuction _0x03d3aa = SiringClockAuction(_0x32d23c);


        require(_0x03d3aa._0xb4afd8());


        _0xba0376 = _0x03d3aa;
    }


    function _0x3421d7(
        uint256 _0xd161a3,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34
    )
        external
        _0xb1b00b
    {


        require(_0x1022ca(msg.sender, _0xd161a3));


        require(!_0x12717b(_0xd161a3));
        _0x1b7941(_0xd161a3, _0x3c50ba);


        _0x3c50ba._0xb280b7(
            _0xd161a3,
            _0x154331,
            _0x47f7c7,
            _0x87bd34,
            msg.sender
        );
    }


    function _0x710107(
        uint256 _0xd161a3,
        address _0x9986f8,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34
    )
        external
        _0xb1b00b
    {


        require(_0x1022ca(msg.sender, _0xd161a3));


        require(!_0x12717b(_0xd161a3));
        _0x1b7941(_0xd161a3, _0xa1d48b);


        _0xa1d48b._0xb280b7(
            _0xd161a3,
            _0x9986f8,
            _0x154331,
            _0x47f7c7,
            _0x87bd34,
            msg.sender
        );
    }

    function _0x796c9c(address _0x9986f8, uint256 _0xd83a06) external _0x480e18{
        _0xa1d48b._0x8119f9(_0x9986f8,_0xd83a06);
    }


    function _0x515aaa(
        uint256 _0xd161a3,
        uint256 _0x154331,
        uint256 _0x47f7c7,
        uint256 _0x87bd34
    )
        external
        _0xb1b00b
    {


        require(_0x1022ca(msg.sender, _0xd161a3));
        require(_0x793690(_0xd161a3));
        _0x1b7941(_0xd161a3, _0xba0376);


        _0xba0376._0xb280b7(
            _0xd161a3,
            _0x154331,
            _0x47f7c7,
            _0x87bd34,
            msg.sender
        );
    }


    function _0x2d21c5(
        uint256 _0xfc7f1d,
        uint256 _0xe581b6
    )
        external
        payable
        _0xb1b00b
    {

        require(_0x1022ca(msg.sender, _0xe581b6));
        require(_0x793690(_0xe581b6));
        require(_0xfc0085(_0xe581b6, _0xfc7f1d));


        uint256 _0x64951d = _0xba0376._0x7360fb(_0xfc7f1d);
        require(msg.value >= _0x64951d + _0x679c14);


        _0xba0376._0xffa76b.value(msg.value - _0x679c14)(_0xfc7f1d);
        _0xb42f96(uint32(_0xe581b6), uint32(_0xfc7f1d), msg.sender);
    }


    function _0xefbb5e() external _0x31ec4b {
        _0x3c50ba._0x2c3937();
        _0xba0376._0x2c3937();
    }

    function _0x5ec046(address _0x4fee2c, address _0x8fc99e) external _0x31ec4b {
        require(_0xa1d48b != address(0));
        _0xa1d48b._0x5ec046(_0x4fee2c,_0x8fc99e);
    }
}


contract PandaMinting is PandaAuction {


    uint256 public constant GEN0_CREATION_LIMIT = 45000;


    uint256 public constant GEN0_STARTING_PRICE = 100 finney;
    uint256 public constant GEN0_AUCTION_DURATION = 1 days;
    uint256 public constant OPEN_PACKAGE_PRICE = 10 finney;


    function _0x737443(uint256[2] _0x91561f, uint256 _0xe846a5, address _0x144d59) external _0x480e18 {
        address _0xf024fc = _0x144d59;
        if (_0xf024fc == address(0)) {
            _0xf024fc = _0x7682f4;
        }

        _0xec0b14(0, 0, _0xe846a5, _0x91561f, _0xf024fc);
    }


    function _0xb3a7c2(uint256[2] _0x91561f,uint256 _0xe846a5,uint256 _0x580195)
        external
        payable
        _0x480e18
        _0xb1b00b
    {
        require(msg.value >= OPEN_PACKAGE_PRICE);
        uint256 _0x38cd73 = _0xec0b14(0, 0, _0xe846a5, _0x91561f, _0x3c50ba);
        _0x3c50ba._0xb3a7c2(_0x38cd73,_0x580195);
    }


    function _0x41c981(uint256 _0xd161a3) external _0x480e18 {
        require(_0x1022ca(msg.sender, _0xd161a3));


        _0x1b7941(_0xd161a3, _0x3c50ba);

        _0x3c50ba._0x41c981(
            _0xd161a3,
            _0x94aaab(),
            0,
            GEN0_AUCTION_DURATION,
            msg.sender
        );
    }


    function _0x94aaab() internal view returns(uint256) {
        uint256 _0xb131e2 = _0x3c50ba._0x4b3e06();

        require(_0xb131e2 == uint256(uint128(_0xb131e2)));

        uint256 _0x7dd416 = _0xb131e2 + (_0xb131e2 / 2);


        if (_0x7dd416 < GEN0_STARTING_PRICE) {
            _0x7dd416 = GEN0_STARTING_PRICE;
        }

        return _0x7dd416;
    }
}


contract PandaCore is PandaMinting {


    address public _0x07f65f;


    function PandaCore() public {

        _0xefa17e = true;


        _0x50c4ae = msg.sender;


        _0x7682f4 = msg.sender;


    }


    function _0x72de6d() external _0xd3ce9c _0xe7c49d {

        require(_0x83f9be.length == 0);

        uint256[2] memory _0x91561f = [uint256(-1),uint256(-1)];

        _0x3c636a[1] = 100;
       _0xec0b14(0, 0, 0, _0x91561f, address(0));
    }


    function _0xa8a270(address _0xe8a796) external _0xd3ce9c _0xe7c49d {

        _0x07f65f = _0xe8a796;
        ContractUpgrade(_0xe8a796);
    }


    function() external payable {
        require(
            msg.sender == address(_0x3c50ba) ||
            msg.sender == address(_0xba0376)
        );
    }


    function _0x484df4(uint256 _0x7572fa)
        external
        view
        returns (
        bool _0xdfe31f,
        bool _0xd01dae,
        uint256 _0x676d0f,
        uint256 _0x3e3f45,
        uint256 _0xac30de,
        uint256 _0xf7f2ba,
        uint256 _0xdb3659,
        uint256 _0x8b6a36,
        uint256 _0x1d0791,
        uint256[2] _0xa55f04
    ) {
        Panda storage _0x4d6fb3 = _0x83f9be[_0x7572fa];


        _0xdfe31f = (_0x4d6fb3._0xac30de != 0);
        _0xd01dae = (_0x4d6fb3._0x7cd360 <= block.number);
        _0x676d0f = uint256(_0x4d6fb3._0x676d0f);
        _0x3e3f45 = uint256(_0x4d6fb3._0x7cd360);
        _0xac30de = uint256(_0x4d6fb3._0xac30de);
        _0xf7f2ba = uint256(_0x4d6fb3._0xf7f2ba);
        _0xdb3659 = uint256(_0x4d6fb3._0xdb3659);
        _0x8b6a36 = uint256(_0x4d6fb3._0x8b6a36);
        _0x1d0791 = uint256(_0x4d6fb3._0x1d0791);
        _0xa55f04 = _0x4d6fb3._0xa55f04;
    }


    function _0x344a9d() public _0xd3ce9c _0xe7c49d {
        require(_0x3c50ba != address(0));
        require(_0xba0376 != address(0));
        require(_0x79bdcc != address(0));
        require(_0x07f65f == address(0));


        super._0x344a9d();
    }


    function _0x2c3937() external _0xdfeaf4 {
        uint256 balance = this.balance;

        uint256 _0x37e328 = (_0xa6197a + 1) * _0x679c14;

        if (balance > _0x37e328) {
            _0x159ced.send(balance - _0x37e328);
        }
    }
}