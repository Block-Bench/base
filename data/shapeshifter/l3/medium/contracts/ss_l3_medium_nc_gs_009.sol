pragma solidity 0.8.13;

import {IERC721, IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import "./interfaces/IHybra.sol";
import {IHybraVotes} from "./interfaces/IHybraVotes.sol";
import {IVeArtProxy} from "./interfaces/IVeArtProxy.sol";
import {IVotingEscrow} from "./interfaces/IVotingEscrow.sol";
import {IVoter} from "./interfaces/IVoter.sol";
import {HybraTimeLibrary} from "./libraries/HybraTimeLibrary.sol";
import {VotingDelegationLib} from "./libraries/VotingDelegationLib.sol";
import {VotingBalanceLogic} from "./libraries/VotingBalanceLogic.sol";


contract VotingEscrow is IERC721, IERC721Metadata, IHybraVotes {
    enum DepositType {
        DEPOSIT_FOR_TYPE,
        CREATE_LOCK_TYPE,
        INCREASE_LOCK_AMOUNT,
        INCREASE_UNLOCK_TIME
    }


    event Deposit(
        address indexed _0x35ba7e,
        uint _0x2a032a,
        uint value,
        uint indexed _0x40eb07,
        DepositType _0x13755b,
        uint _0xd71070
    );

    event Merge(
        address indexed _0x4c2e7b,
        uint256 indexed _0x25182c,
        uint256 indexed _0x53d6d5,
        uint256 _0x1e05eb,
        uint256 _0x98ddcf,
        uint256 _0x29bd1e,
        uint256 _0xdb950d,
        uint256 _0xc8a992
    );
    event Split(
        uint256 indexed _0x25182c,
        uint256 indexed _0x559d71,
        uint256 indexed _0xf4eece,
        address _0x4c2e7b,
        uint256 _0x64e7d5,
        uint256 _0x362994,
        uint256 _0xdb950d,
        uint256 _0xc8a992
    );

    event MultiSplit(
        uint256 indexed _0x25182c,
        uint256[] _0x9339b0,
        address _0x4c2e7b,
        uint256[] _0xf2202e,
        uint256 _0xdb950d,
        uint256 _0xc8a992
    );

    event MetadataUpdate(uint256 _0xf4b082);
    event BatchMetadataUpdate(uint256 _0x7e82d1, uint256 _0x7fb5cc);

    event Withdraw(address indexed _0x35ba7e, uint _0x2a032a, uint value, uint _0xd71070);
    event LockPermanent(address indexed _0xbff7e2, uint256 indexed _0xf4b082, uint256 _0xfae49d, uint256 _0xc8a992);
    event UnlockPermanent(address indexed _0xbff7e2, uint256 indexed _0xf4b082, uint256 _0xfae49d, uint256 _0xc8a992);
    event Supply(uint _0x4e54df, uint _0x232a81);


    address public immutable _0x6e3f8e;
    address public _0xdddfbf;
    address public _0x8d0c8c;
    address public _0xf8fc1b;


    uint public PRECISISON = 10000;


    mapping(bytes4 => bool) internal _0x96edd0;
    mapping(uint => bool) internal _0x165e3a;


    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;


    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;


    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;


    uint internal _0x2a032a;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal _0x9f393f;
    IHybra public _0x412385;


    VotingDelegationLib.Data private _0x8e8b32;

    VotingBalanceLogic.Data private _0x3ae538;


    constructor(address _0xe15817, address _0x550069) {
        if (true) { _0x6e3f8e = _0xe15817; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xdddfbf = msg.sender; }
        _0x8d0c8c = msg.sender;
        if (gasleft() > 0) { _0xf8fc1b = _0x550069; }
        if (true) { WEEK = HybraTimeLibrary.WEEK; }
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        _0x9f393f = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION));

        _0x3ae538._0xd77151[0]._0x648eb3 = block.number;
        _0x3ae538._0xd77151[0]._0xd71070 = block.timestamp;

        _0x96edd0[ERC165_INTERFACE_ID] = true;
        _0x96edd0[ERC721_INTERFACE_ID] = true;
        _0x96edd0[ERC721_METADATA_INTERFACE_ID] = true;
        _0x412385 = IHybra(_0x6e3f8e);


        emit Transfer(address(0), address(this), _0x2a032a);

        emit Transfer(address(this), address(0), _0x2a032a);
    }


    uint8 internal constant _0xbe30b5 = 1;
    uint8 internal constant _0xa88331 = 2;
    uint8 internal _0x2930a7 = 1;
    modifier _0xa523b5() {
        require(_0x2930a7 == _0xbe30b5);
        _0x2930a7 = _0xa88331;
        _;
        _0x2930a7 = _0xbe30b5;
    }

    modifier _0x2af2f1(uint256 _0xf4b082) {
        require(!_0x165e3a[_0xf4b082], "PNFT");
        _;
    }

    modifier _0x40ba25(uint _0x25182c) {
        require(_0xb965c7[msg.sender] || _0xb965c7[address(0)], "!SPLIT");
        require(_0x82ac4e[_0x25182c] == 0 && !_0x57ecf6[_0x25182c], "ATT");
        require(_0xcc72fd(msg.sender, _0x25182c), "NAO");
        _;
    }


    string constant public _0xf20ba5 = "veHYBR";
    string constant public _0xf81541 = "veHYBR";
    string constant public _0x76c514 = "1.0.0";
    uint8 constant public _0x5e83ee = 18;

    function _0x47b64b(address _0x7e83b1) external {
        require(msg.sender == _0x8d0c8c);
        _0x8d0c8c = _0x7e83b1;
    }

    function _0xd685e8(address _0xad2df3) external {
        require(msg.sender == _0x8d0c8c);
        _0xf8fc1b = _0xad2df3;
        emit BatchMetadataUpdate(0, type(uint256)._0x345b7b);
    }


    function _0x11429f(uint _0xf4b082, bool _0xd478fb) external {
        require(msg.sender == _0x8d0c8c, "NA");
        require(_0x8b7a52[_0xf4b082] != address(0), "DNE");
        _0x165e3a[_0xf4b082] = _0xd478fb;
    }


    function _0xeaac9b(uint _0xf4b082) external view returns (string memory) {
        require(_0x8b7a52[_0xf4b082] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory _0x326dce = _0x8dd7d9[_0xf4b082];

        return IVeArtProxy(_0xf8fc1b)._0x38b0f7(_0xf4b082,VotingBalanceLogic._0xf37287(_0xf4b082, block.timestamp, _0x3ae538),_0x326dce._0xd7f592,uint(int256(_0x326dce._0xfae49d)));
    }


    mapping(uint => address) internal _0x8b7a52;


    mapping(address => uint) internal _0x25b46c;


    function _0x54d806(uint _0xf4b082) public view returns (address) {
        return _0x8b7a52[_0xf4b082];
    }

    function _0x6e30e1(address _0x71344c) public view returns (uint) {

        return _0x25b46c[_0x71344c];
    }


    function _0x0f9488(address _0xbff7e2) internal view returns (uint) {
        return _0x25b46c[_0xbff7e2];
    }


    function _0x2d8ae5(address _0xbff7e2) external view returns (uint) {
        return _0x0f9488(_0xbff7e2);
    }


    mapping(uint => address) internal _0xa3ce20;


    mapping(address => mapping(address => bool)) internal _0xe65978;

    mapping(uint => uint) public _0xc38ced;


    function _0x747b09(uint _0xf4b082) external view returns (address) {
        return _0xa3ce20[_0xf4b082];
    }


    function _0xa756d8(address _0xbff7e2, address _0x7b3f5f) external view returns (bool) {
        return (_0xe65978[_0xbff7e2])[_0x7b3f5f];
    }


    function _0xfa6eff(address _0xe5356c, uint _0xf4b082) public {
        address _0x71344c = _0x8b7a52[_0xf4b082];

        require(_0x71344c != address(0), "ZA");

        require(_0xe5356c != _0x71344c, "IA");

        bool _0x3353b4 = (_0x8b7a52[_0xf4b082] == msg.sender);
        bool _0x5f36cc = (_0xe65978[_0x71344c])[msg.sender];
        require(_0x3353b4 || _0x5f36cc, "NAO");

        _0xa3ce20[_0xf4b082] = _0xe5356c;
        emit Approval(_0x71344c, _0xe5356c, _0xf4b082);
    }


    function _0xc07721(address _0x7b3f5f, bool _0xe5356c) external {

        assert(_0x7b3f5f != msg.sender);
        _0xe65978[msg.sender][_0x7b3f5f] = _0xe5356c;
        emit ApprovalForAll(msg.sender, _0x7b3f5f, _0xe5356c);
    }


    function _0x7fe2d1(address _0xbff7e2, uint _0xf4b082) internal {

        assert(_0x8b7a52[_0xf4b082] == _0xbff7e2);
        if (_0xa3ce20[_0xf4b082] != address(0)) {

            _0xa3ce20[_0xf4b082] = address(0);
        }
    }


    function _0xcc72fd(address _0x76c48b, uint _0xf4b082) internal view returns (bool) {
        address _0x71344c = _0x8b7a52[_0xf4b082];
        bool _0x512cf9 = _0x71344c == _0x76c48b;
        bool _0x22ee77 = _0x76c48b == _0xa3ce20[_0xf4b082];
        bool _0x2650e2 = (_0xe65978[_0x71344c])[_0x76c48b];
        return _0x512cf9 || _0x22ee77 || _0x2650e2;
    }

    function _0x1c7580(address _0x76c48b, uint _0xf4b082) external view returns (bool) {
        return _0xcc72fd(_0x76c48b, _0xf4b082);
    }


    function _0xce0951(
        address _0x25182c,
        address _0x53d6d5,
        uint _0xf4b082,
        address _0x4c2e7b
    ) internal _0x2af2f1(_0xf4b082) {
        require(_0x82ac4e[_0xf4b082] == 0 && !_0x57ecf6[_0xf4b082], "ATT");

        require(_0xcc72fd(_0x4c2e7b, _0xf4b082), "NAO");


        _0x7fe2d1(_0x25182c, _0xf4b082);

        _0x5fd1fa(_0x25182c, _0xf4b082);

        VotingDelegationLib._0x2ea56a(_0x8e8b32, _0x36ebcd(_0x25182c), _0x36ebcd(_0x53d6d5), _0xf4b082, _0x54d806);

        _0xdc36a0(_0x53d6d5, _0xf4b082);

        _0xc38ced[_0xf4b082] = block.number;


        emit Transfer(_0x25182c, _0x53d6d5, _0xf4b082);
    }


    function _0xe12f9d(
        address _0x25182c,
        address _0x53d6d5,
        uint _0xf4b082
    ) external {
        _0xce0951(_0x25182c, _0x53d6d5, _0xf4b082, msg.sender);
    }


    function _0x0eed22(
        address _0x25182c,
        address _0x53d6d5,
        uint _0xf4b082
    ) external {
        _0x0eed22(_0x25182c, _0x53d6d5, _0xf4b082, "");
    }

    function _0xda59b1(address _0x779979) internal view returns (bool) {


        uint _0xd4c948;
        assembly {
            _0xd4c948 := extcodesize(_0x779979)
        }
        return _0xd4c948 > 0;
    }


    function _0x0eed22(
        address _0x25182c,
        address _0x53d6d5,
        uint _0xf4b082,
        bytes memory _0x027bfa
    ) public {
        _0xce0951(_0x25182c, _0x53d6d5, _0xf4b082, msg.sender);

        if (_0xda59b1(_0x53d6d5)) {

            try IERC721Receiver(_0x53d6d5)._0x780076(msg.sender, _0x25182c, _0xf4b082, _0x027bfa) returns (bytes4 _0xdd897c) {
                if (_0xdd897c != IERC721Receiver(_0x53d6d5)._0x780076.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory _0xe4ac9e) {
                if (_0xe4ac9e.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, _0xe4ac9e), mload(_0xe4ac9e))
                    }
                }
            }
        }
    }


    function _0x634148(bytes4 _0x61a95f) external view returns (bool) {
        return _0x96edd0[_0x61a95f];
    }


    mapping(address => mapping(uint => uint)) internal _0xd6354d;


    mapping(uint => uint) internal _0x93cb59;


    function _0x5fb461(address _0xbff7e2, uint _0x772984) public view returns (uint) {
        return _0xd6354d[_0xbff7e2][_0x772984];
    }


    function _0x4eb0fb(address _0x53d6d5, uint _0xf4b082) internal {
        uint _0xa38991 = _0x0f9488(_0x53d6d5);

        _0xd6354d[_0x53d6d5][_0xa38991] = _0xf4b082;
        _0x93cb59[_0xf4b082] = _0xa38991;
    }


    function _0xdc36a0(address _0x53d6d5, uint _0xf4b082) internal {

        assert(_0x8b7a52[_0xf4b082] == address(0));

        _0x8b7a52[_0xf4b082] = _0x53d6d5;

        _0x4eb0fb(_0x53d6d5, _0xf4b082);

        _0x25b46c[_0x53d6d5] += 1;
    }


    function _0xdbf96f(address _0x53d6d5, uint _0xf4b082) internal returns (bool) {

        assert(_0x53d6d5 != address(0));

        VotingDelegationLib._0x2ea56a(_0x8e8b32, address(0), _0x36ebcd(_0x53d6d5), _0xf4b082, _0x54d806);

        _0xdc36a0(_0x53d6d5, _0xf4b082);
        emit Transfer(address(0), _0x53d6d5, _0xf4b082);
        return true;
    }


    function _0xc4a0dc(address _0x25182c, uint _0xf4b082) internal {

        uint _0xa38991 = _0x0f9488(_0x25182c) - 1;
        uint _0xc1fad5 = _0x93cb59[_0xf4b082];

        if (_0xa38991 == _0xc1fad5) {

            _0xd6354d[_0x25182c][_0xa38991] = 0;

            _0x93cb59[_0xf4b082] = 0;
        } else {
            uint _0xc123f2 = _0xd6354d[_0x25182c][_0xa38991];


            _0xd6354d[_0x25182c][_0xc1fad5] = _0xc123f2;

            _0x93cb59[_0xc123f2] = _0xc1fad5;


            _0xd6354d[_0x25182c][_0xa38991] = 0;

            _0x93cb59[_0xf4b082] = 0;
        }
    }


    function _0x5fd1fa(address _0x25182c, uint _0xf4b082) internal {

        assert(_0x8b7a52[_0xf4b082] == _0x25182c);

        _0x8b7a52[_0xf4b082] = address(0);

        _0xc4a0dc(_0x25182c, _0xf4b082);

        _0x25b46c[_0x25182c] -= 1;
    }

    function _0xf299bf(uint _0xf4b082) internal {
        require(_0xcc72fd(msg.sender, _0xf4b082), "NAO");

        address _0x71344c = _0x54d806(_0xf4b082);


        delete _0xa3ce20[_0xf4b082];


        _0x5fd1fa(_0x71344c, _0xf4b082);

        VotingDelegationLib._0x2ea56a(_0x8e8b32, _0x36ebcd(_0x71344c), address(0), _0xf4b082, _0x54d806);

        emit Transfer(_0x71344c, address(0), _0xf4b082);
    }


    mapping(uint => IVotingEscrow.LockedBalance) public _0x8dd7d9;
    uint public _0xb7f294;
    uint public _0x73d159;
    mapping(uint => int128) public _0xed2249;
    uint public _0x232a81;
    mapping(address => bool) public _0xb965c7;

    uint internal constant MULTIPLIER = 1 ether;


    function _0x243e65(uint _0xf4b082) external view returns (int128) {
        uint _0x16ca53 = _0x3ae538._0x2c9b4c[_0xf4b082];
        return _0x3ae538._0xc33fc4[_0xf4b082][_0x16ca53]._0xc227be;
    }


    function _0xc33fc4(uint _0xf4b082, uint _0x0e8e9b) external view returns (IVotingEscrow.Point memory) {
        return _0x3ae538._0xc33fc4[_0xf4b082][_0x0e8e9b];
    }

    function _0xd77151(uint _0x73d159) external view returns (IVotingEscrow.Point memory) {
        return _0x3ae538._0xd77151[_0x73d159];
    }

    function _0x2c9b4c(uint _0x2a032a) external view returns (uint) {
        return _0x3ae538._0x2c9b4c[_0x2a032a];
    }


    function _0xe1d8a8(
        uint _0xf4b082,
        IVotingEscrow.LockedBalance memory _0xb5b06d,
        IVotingEscrow.LockedBalance memory _0x69d5c2
    ) internal {
        IVotingEscrow.Point memory _0xaf5bd6;
        IVotingEscrow.Point memory _0x4a624a;
        int128 _0x43e923 = 0;
        int128 _0x1bf499 = 0;
        uint _0xe097d0 = _0x73d159;

        if (_0xf4b082 != 0) {
            _0x4a624a._0xcc3a56 = 0;

            if(_0x69d5c2._0xfd9240){
                _0x4a624a._0xcc3a56 = uint(int256(_0x69d5c2._0xfae49d));
            }


            if (_0xb5b06d._0xd7f592 > block.timestamp && _0xb5b06d._0xfae49d > 0) {
                _0xaf5bd6._0xc227be = _0xb5b06d._0xfae49d / _0x9f393f;
                _0xaf5bd6._0x731df2 = _0xaf5bd6._0xc227be * int128(int256(_0xb5b06d._0xd7f592 - block.timestamp));
            }
            if (_0x69d5c2._0xd7f592 > block.timestamp && _0x69d5c2._0xfae49d > 0) {
                _0x4a624a._0xc227be = _0x69d5c2._0xfae49d / _0x9f393f;
                _0x4a624a._0x731df2 = _0x4a624a._0xc227be * int128(int256(_0x69d5c2._0xd7f592 - block.timestamp));
            }


            _0x43e923 = _0xed2249[_0xb5b06d._0xd7f592];
            if (_0x69d5c2._0xd7f592 != 0) {
                if (_0x69d5c2._0xd7f592 == _0xb5b06d._0xd7f592) {
                    _0x1bf499 = _0x43e923;
                } else {
                    _0x1bf499 = _0xed2249[_0x69d5c2._0xd7f592];
                }
            }
        }

        IVotingEscrow.Point memory _0xcb7dd3 = IVotingEscrow.Point({_0x731df2: 0, _0xc227be: 0, _0xd71070: block.timestamp, _0x648eb3: block.number, _0xcc3a56: 0});
        if (_0xe097d0 > 0) {
            _0xcb7dd3 = _0x3ae538._0xd77151[_0xe097d0];
        }
        uint _0xe9b869 = _0xcb7dd3._0xd71070;


        IVotingEscrow.Point memory _0x418b88 = _0xcb7dd3;
        uint _0x47e707 = 0;
        if (block.timestamp > _0xcb7dd3._0xd71070) {
            _0x47e707 = (MULTIPLIER * (block.number - _0xcb7dd3._0x648eb3)) / (block.timestamp - _0xcb7dd3._0xd71070);
        }


        {
            uint _0x441ba4 = (_0xe9b869 / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {


                _0x441ba4 += WEEK;
                int128 _0xbf447e = 0;
                if (_0x441ba4 > block.timestamp) {
                    _0x441ba4 = block.timestamp;
                } else {
                    _0xbf447e = _0xed2249[_0x441ba4];
                }
                _0xcb7dd3._0x731df2 -= _0xcb7dd3._0xc227be * int128(int256(_0x441ba4 - _0xe9b869));
                _0xcb7dd3._0xc227be += _0xbf447e;
                if (_0xcb7dd3._0x731df2 < 0) {

                    _0xcb7dd3._0x731df2 = 0;
                }
                if (_0xcb7dd3._0xc227be < 0) {

                    _0xcb7dd3._0xc227be = 0;
                }
                _0xe9b869 = _0x441ba4;
                _0xcb7dd3._0xd71070 = _0x441ba4;
                _0xcb7dd3._0x648eb3 = _0x418b88._0x648eb3 + (_0x47e707 * (_0x441ba4 - _0x418b88._0xd71070)) / MULTIPLIER;
                _0xe097d0 += 1;
                if (_0x441ba4 == block.timestamp) {
                    _0xcb7dd3._0x648eb3 = block.number;
                    break;
                } else {
                    _0x3ae538._0xd77151[_0xe097d0] = _0xcb7dd3;
                }
            }
        }

        _0x73d159 = _0xe097d0;


        if (_0xf4b082 != 0) {


            _0xcb7dd3._0xc227be += (_0x4a624a._0xc227be - _0xaf5bd6._0xc227be);
            _0xcb7dd3._0x731df2 += (_0x4a624a._0x731df2 - _0xaf5bd6._0x731df2);
            if (_0xcb7dd3._0xc227be < 0) {
                _0xcb7dd3._0xc227be = 0;
            }
            if (_0xcb7dd3._0x731df2 < 0) {
                _0xcb7dd3._0x731df2 = 0;
            }
            _0xcb7dd3._0xcc3a56 = _0xb7f294;
        }


        _0x3ae538._0xd77151[_0xe097d0] = _0xcb7dd3;

        if (_0xf4b082 != 0) {


            if (_0xb5b06d._0xd7f592 > block.timestamp) {

                _0x43e923 += _0xaf5bd6._0xc227be;
                if (_0x69d5c2._0xd7f592 == _0xb5b06d._0xd7f592) {
                    _0x43e923 -= _0x4a624a._0xc227be;
                }
                _0xed2249[_0xb5b06d._0xd7f592] = _0x43e923;
            }

            if (_0x69d5c2._0xd7f592 > block.timestamp) {
                if (_0x69d5c2._0xd7f592 > _0xb5b06d._0xd7f592) {
                    _0x1bf499 -= _0x4a624a._0xc227be;
                    _0xed2249[_0x69d5c2._0xd7f592] = _0x1bf499;
                }

            }

            uint _0x508f33 = _0x3ae538._0x2c9b4c[_0xf4b082] + 1;

            _0x3ae538._0x2c9b4c[_0xf4b082] = _0x508f33;
            _0x4a624a._0xd71070 = block.timestamp;
            _0x4a624a._0x648eb3 = block.number;
            _0x3ae538._0xc33fc4[_0xf4b082][_0x508f33] = _0x4a624a;
        }
    }


    function _0x116ccc(
        uint _0xf4b082,
        uint _0x2f33c4,
        uint _0x66ca59,
        IVotingEscrow.LockedBalance memory _0xb59186,
        DepositType _0x13755b
    ) internal {
        IVotingEscrow.LockedBalance memory _0x326dce = _0xb59186;
        uint _0xc34a00 = _0x232a81;

        _0x232a81 = _0xc34a00 + _0x2f33c4;
        IVotingEscrow.LockedBalance memory _0xb5b06d;
        (_0xb5b06d._0xfae49d, _0xb5b06d._0xd7f592, _0xb5b06d._0xfd9240) = (_0x326dce._0xfae49d, _0x326dce._0xd7f592, _0x326dce._0xfd9240);

        _0x326dce._0xfae49d += int128(int256(_0x2f33c4));

        if (_0x66ca59 != 0) {
            _0x326dce._0xd7f592 = _0x66ca59;
        }
        _0x8dd7d9[_0xf4b082] = _0x326dce;


        _0xe1d8a8(_0xf4b082, _0xb5b06d, _0x326dce);

        address from = msg.sender;
        if (_0x2f33c4 != 0) {
            assert(IERC20(_0x6e3f8e)._0xe12f9d(from, address(this), _0x2f33c4));
        }

        emit Deposit(from, _0xf4b082, _0x2f33c4, _0x326dce._0xd7f592, _0x13755b, block.timestamp);
        emit Supply(_0xc34a00, _0xc34a00 + _0x2f33c4);
    }


    function _0xd0edff() external {
        _0xe1d8a8(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }


    function _0x1c3810(uint _0xf4b082, uint _0x2f33c4) external _0xa523b5 {
        IVotingEscrow.LockedBalance memory _0x326dce = _0x8dd7d9[_0xf4b082];

        require(_0x2f33c4 > 0, "ZV");
        require(_0x326dce._0xfae49d > 0, 'ZL');
        require(_0x326dce._0xd7f592 > block.timestamp || _0x326dce._0xfd9240, 'EXP');

        if (_0x326dce._0xfd9240) _0xb7f294 += _0x2f33c4;

        _0x116ccc(_0xf4b082, _0x2f33c4, 0, _0x326dce, DepositType.DEPOSIT_FOR_TYPE);

        if(_0x57ecf6[_0xf4b082]) {
            IVoter(_0xdddfbf)._0x7433c9(_0xf4b082);
        }
    }


    function _0xa9e72b(uint _0x2f33c4, uint _0x58160b, address _0x53d6d5) internal returns (uint) {
        uint _0x66ca59 = (block.timestamp + _0x58160b) / WEEK * WEEK;

        require(_0x2f33c4 > 0, "ZV");
        require(_0x66ca59 > block.timestamp && (_0x66ca59 <= block.timestamp + MAXTIME), 'IUT');

        ++_0x2a032a;
        uint _0xf4b082 = _0x2a032a;
        _0xdbf96f(_0x53d6d5, _0xf4b082);

        IVotingEscrow.LockedBalance memory _0x326dce = _0x8dd7d9[_0xf4b082];

        _0x116ccc(_0xf4b082, _0x2f33c4, _0x66ca59, _0x326dce, DepositType.CREATE_LOCK_TYPE);
        return _0xf4b082;
    }


    function _0xbe3544(uint _0x2f33c4, uint _0x58160b) external _0xa523b5 returns (uint) {
        return _0xa9e72b(_0x2f33c4, _0x58160b, msg.sender);
    }


    function _0xc55101(uint _0x2f33c4, uint _0x58160b, address _0x53d6d5) external _0xa523b5 returns (uint) {
        return _0xa9e72b(_0x2f33c4, _0x58160b, _0x53d6d5);
    }


    function _0x8e2b28(uint _0xf4b082, uint _0x2f33c4) external _0xa523b5 {
        assert(_0xcc72fd(msg.sender, _0xf4b082));

        IVotingEscrow.LockedBalance memory _0x326dce = _0x8dd7d9[_0xf4b082];

        assert(_0x2f33c4 > 0);
        require(_0x326dce._0xfae49d > 0, 'ZL');
        require(_0x326dce._0xd7f592 > block.timestamp || _0x326dce._0xfd9240, 'EXP');

        if (_0x326dce._0xfd9240) _0xb7f294 += _0x2f33c4;
        _0x116ccc(_0xf4b082, _0x2f33c4, 0, _0x326dce, DepositType.INCREASE_LOCK_AMOUNT);


        if(_0x57ecf6[_0xf4b082]) {
            IVoter(_0xdddfbf)._0x7433c9(_0xf4b082);
        }
        emit MetadataUpdate(_0xf4b082);
    }


    function _0x4bcdc2(uint _0xf4b082, uint _0x58160b) external _0xa523b5 {
        assert(_0xcc72fd(msg.sender, _0xf4b082));

        IVotingEscrow.LockedBalance memory _0x326dce = _0x8dd7d9[_0xf4b082];
        require(!_0x326dce._0xfd9240, "!NORM");
        uint _0x66ca59 = (block.timestamp + _0x58160b) / WEEK * WEEK;

        require(_0x326dce._0xd7f592 > block.timestamp && _0x326dce._0xfae49d > 0, 'EXP||ZV');
        require(_0x66ca59 > _0x326dce._0xd7f592 && (_0x66ca59 <= block.timestamp + MAXTIME), 'IUT');

        _0x116ccc(_0xf4b082, 0, _0x66ca59, _0x326dce, DepositType.INCREASE_UNLOCK_TIME);


        if(_0x57ecf6[_0xf4b082]) {
            IVoter(_0xdddfbf)._0x7433c9(_0xf4b082);
        }
        emit MetadataUpdate(_0xf4b082);
    }


    function _0x3455f3(uint _0xf4b082) external _0xa523b5 {
        assert(_0xcc72fd(msg.sender, _0xf4b082));
        require(_0x82ac4e[_0xf4b082] == 0 && !_0x57ecf6[_0xf4b082], "ATT");

        IVotingEscrow.LockedBalance memory _0x326dce = _0x8dd7d9[_0xf4b082];
        require(!_0x326dce._0xfd9240, "!NORM");
        require(block.timestamp >= _0x326dce._0xd7f592, "!EXP");
        uint value = uint(int256(_0x326dce._0xfae49d));

        _0x8dd7d9[_0xf4b082] = IVotingEscrow.LockedBalance(0, 0, false);
        uint _0xc34a00 = _0x232a81;
        _0x232a81 = _0xc34a00 - value;


        _0xe1d8a8(_0xf4b082, _0x326dce, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(_0x6e3f8e).transfer(msg.sender, value));


        _0xf299bf(_0xf4b082);

        emit Withdraw(msg.sender, _0xf4b082, value, block.timestamp);
        emit Supply(_0xc34a00, _0xc34a00 - value);
    }

    function _0xbb7f9e(uint _0xf4b082) external {
        address sender = msg.sender;
        require(_0xcc72fd(sender, _0xf4b082), "NAO");

        IVotingEscrow.LockedBalance memory _0x461bc5 = _0x8dd7d9[_0xf4b082];
        require(!_0x461bc5._0xfd9240, "!NORM");
        require(_0x461bc5._0xd7f592 > block.timestamp, "EXP");
        require(_0x461bc5._0xfae49d > 0, "ZV");

        uint _0x6ddf40 = uint(int256(_0x461bc5._0xfae49d));
        _0xb7f294 += _0x6ddf40;
        _0x461bc5._0xd7f592 = 0;
        _0x461bc5._0xfd9240 = true;
        _0xe1d8a8(_0xf4b082, _0x8dd7d9[_0xf4b082], _0x461bc5);
        _0x8dd7d9[_0xf4b082] = _0x461bc5;
        if(_0x57ecf6[_0xf4b082]) {
            IVoter(_0xdddfbf)._0x7433c9(_0xf4b082);
        }
        emit LockPermanent(sender, _0xf4b082, _0x6ddf40, block.timestamp);
        emit MetadataUpdate(_0xf4b082);
    }

    function _0x03c311(uint _0xf4b082) external {
        address sender = msg.sender;
        require(_0xcc72fd(msg.sender, _0xf4b082), "NAO");

        require(_0x82ac4e[_0xf4b082] == 0 && !_0x57ecf6[_0xf4b082], "ATT");
        IVotingEscrow.LockedBalance memory _0x461bc5 = _0x8dd7d9[_0xf4b082];
        require(_0x461bc5._0xfd9240, "!NORM");
        uint _0x6ddf40 = uint(int256(_0x461bc5._0xfae49d));
        _0xb7f294 -= _0x6ddf40;
        _0x461bc5._0xd7f592 = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _0x461bc5._0xfd9240 = false;

        _0xe1d8a8(_0xf4b082, _0x8dd7d9[_0xf4b082], _0x461bc5);
        _0x8dd7d9[_0xf4b082] = _0x461bc5;

        emit UnlockPermanent(sender, _0xf4b082, _0x6ddf40, block.timestamp);
        emit MetadataUpdate(_0xf4b082);
    }


    function _0xf37287(uint _0xf4b082) external view returns (uint) {
        if (_0xc38ced[_0xf4b082] == block.number) return 0;
        return VotingBalanceLogic._0xf37287(_0xf4b082, block.timestamp, _0x3ae538);
    }

    function _0x79e8d9(uint _0xf4b082, uint _0xacb016) external view returns (uint) {
        return VotingBalanceLogic._0xf37287(_0xf4b082, _0xacb016, _0x3ae538);
    }

    function _0x6bc905(uint _0xf4b082, uint _0xfb9f6c) external view returns (uint) {
        return VotingBalanceLogic._0x6bc905(_0xf4b082, _0xfb9f6c, _0x3ae538, _0x73d159);
    }


    function _0x30829c(uint _0xfb9f6c) external view returns (uint) {
        return VotingBalanceLogic._0x30829c(_0xfb9f6c, _0x73d159, _0x3ae538, _0xed2249);
    }

    function _0x1eddd7() external view returns (uint) {
        return _0x41c737(block.timestamp);
    }


    function _0x41c737(uint t) public view returns (uint) {
        return VotingBalanceLogic._0x41c737(t, _0x73d159, _0xed2249,  _0x3ae538);
    }


    mapping(uint => uint) public _0x82ac4e;
    mapping(uint => bool) public _0x57ecf6;

    function _0x0a88d4(address _0xb2676b) external {
        require(msg.sender == _0x8d0c8c);
        _0xdddfbf = _0xb2676b;
    }

    function _0xcd6c56(uint _0xf4b082) external {
        require(msg.sender == _0xdddfbf);
        _0x57ecf6[_0xf4b082] = true;
    }

    function _0x4f32ae(uint _0xf4b082) external {
        require(msg.sender == _0xdddfbf, "NA");
        _0x57ecf6[_0xf4b082] = false;
    }

    function _0xf5b117(uint _0xf4b082) external {
        require(msg.sender == _0xdddfbf, "NA");
        _0x82ac4e[_0xf4b082] = _0x82ac4e[_0xf4b082] + 1;
    }

    function _0x09b05b(uint _0xf4b082) external {
        require(msg.sender == _0xdddfbf, "NA");
        _0x82ac4e[_0xf4b082] = _0x82ac4e[_0xf4b082] - 1;
    }

    function _0x1a6fbe(uint _0x25182c, uint _0x53d6d5) external _0xa523b5 _0x2af2f1(_0x25182c) {
        require(_0x82ac4e[_0x25182c] == 0 && !_0x57ecf6[_0x25182c], "ATT");
        require(_0x25182c != _0x53d6d5, "SAME");
        require(_0xcc72fd(msg.sender, _0x25182c) &&
        _0xcc72fd(msg.sender, _0x53d6d5), "NAO");

        IVotingEscrow.LockedBalance memory _0xeabea0 = _0x8dd7d9[_0x25182c];
        IVotingEscrow.LockedBalance memory _0xb844cd = _0x8dd7d9[_0x53d6d5];
        require(_0xb844cd._0xd7f592 > block.timestamp ||  _0xb844cd._0xfd9240,"EXP||PERM");
        require(_0xeabea0._0xfd9240 ? _0xb844cd._0xfd9240 : true, "!MERGE");

        uint _0x002189 = uint(int256(_0xeabea0._0xfae49d));
        uint _0xd7f592 = _0xeabea0._0xd7f592 >= _0xb844cd._0xd7f592 ? _0xeabea0._0xd7f592 : _0xb844cd._0xd7f592;

        _0x8dd7d9[_0x25182c] = IVotingEscrow.LockedBalance(0, 0, false);
        _0xe1d8a8(_0x25182c, _0xeabea0, IVotingEscrow.LockedBalance(0, 0, false));
        _0xf299bf(_0x25182c);

        IVotingEscrow.LockedBalance memory _0xf42f45;
        _0xf42f45._0xfd9240 = _0xb844cd._0xfd9240;

        if (_0xf42f45._0xfd9240){
            _0xf42f45._0xfae49d = _0xb844cd._0xfae49d + _0xeabea0._0xfae49d;
            if (!_0xeabea0._0xfd9240) {
                _0xb7f294 += _0x002189;
            }
        }else{
            _0xf42f45._0xfae49d = _0xb844cd._0xfae49d + _0xeabea0._0xfae49d;
            _0xf42f45._0xd7f592 = _0xd7f592;
        }


        _0xe1d8a8(_0x53d6d5, _0xb844cd, _0xf42f45);
        _0x8dd7d9[_0x53d6d5] = _0xf42f45;

        if(_0x57ecf6[_0x53d6d5]) {
            IVoter(_0xdddfbf)._0x7433c9(_0x53d6d5);
        }
        emit Merge(
            msg.sender,
            _0x25182c,
            _0x53d6d5,
            uint(int256(_0xeabea0._0xfae49d)),
            uint(int256(_0xb844cd._0xfae49d)),
            uint(int256(_0xf42f45._0xfae49d)),
            _0xf42f45._0xd7f592,
            block.timestamp
        );
        emit MetadataUpdate(_0x53d6d5);
    }


    function _0x0d19d0(
        uint _0x25182c,
        uint[] memory _0x58a924
    ) external _0xa523b5 _0x40ba25(_0x25182c) _0x2af2f1(_0x25182c) returns (uint256[] memory _0xa0977d) {
        require(_0x58a924.length >= 2 && _0x58a924.length <= 10, "MIN2MAX10");

        address _0x71344c = _0x8b7a52[_0x25182c];

        IVotingEscrow.LockedBalance memory _0xbab212 = _0x8dd7d9[_0x25182c];
        require(_0xbab212._0xd7f592 > block.timestamp || _0xbab212._0xfd9240, "EXP");
        require(_0xbab212._0xfae49d > 0, "ZV");


        uint _0x5f11a2 = 0;
        for(uint i = 0; i < _0x58a924.length; i++) {
            require(_0x58a924[i] > 0, "ZW");
            _0x5f11a2 += _0x58a924[i];
        }


        _0x8dd7d9[_0x25182c] = IVotingEscrow.LockedBalance(0, 0, false);
        _0xe1d8a8(_0x25182c, _0xbab212, IVotingEscrow.LockedBalance(0, 0, false));
        _0xf299bf(_0x25182c);


        _0xa0977d = new uint256[](_0x58a924.length);
        uint[] memory _0x9ba99d = new uint[](_0x58a924.length);

        for(uint i = 0; i < _0x58a924.length; i++) {
            IVotingEscrow.LockedBalance memory _0x8f44f5 = IVotingEscrow.LockedBalance({
                _0xfae49d: int128(int256(uint256(int256(_0xbab212._0xfae49d)) * _0x58a924[i] / _0x5f11a2)),
                _0xd7f592: _0xbab212._0xd7f592,
                _0xfd9240: _0xbab212._0xfd9240
            });

            _0xa0977d[i] = _0xff0382(_0x71344c, _0x8f44f5);
            _0x9ba99d[i] = uint256(int256(_0x8f44f5._0xfae49d));
        }

        emit MultiSplit(
            _0x25182c,
            _0xa0977d,
            msg.sender,
            _0x9ba99d,
            _0xbab212._0xd7f592,
            block.timestamp
        );
    }

    function _0xff0382(address _0x53d6d5, IVotingEscrow.LockedBalance memory _0x461bc5) private returns (uint256 _0xf4b082) {
        _0xf4b082 = ++_0x2a032a;
        _0x8dd7d9[_0xf4b082] = _0x461bc5;
        _0xe1d8a8(_0xf4b082, IVotingEscrow.LockedBalance(0, 0, false), _0x461bc5);
        _0xdbf96f(_0x53d6d5, _0xf4b082);
    }

    function _0xd71cad(address _0x87e01d, bool _0x003535) external {
        require(msg.sender == _0x8d0c8c);
        _0xb965c7[_0x87e01d] = _0x003535;
    }


    bytes32 public constant DOMAIN_TYPEHASH = _0xc1869c("EIP712Domain(string name,uint256 chainId,address verifyingContract)");


    bytes32 public constant DELEGATION_TYPEHASH = _0xc1869c("Delegation(address delegatee,uint256 nonce,uint256 expiry)");


    mapping(address => address) private _0xc2126b;


    mapping(address => uint) public _0x688165;


    function _0x36ebcd(address _0x4524b6) public view returns (address) {
        address _0x5e78b2 = _0xc2126b[_0x4524b6];
        return _0x5e78b2 == address(0) ? _0x4524b6 : _0x5e78b2;
    }


    function _0x0d8b8d(address _0x779979) external view returns (uint) {
        uint32 _0xcdbfcd = _0x8e8b32._0xe1146f[_0x779979];
        if (_0xcdbfcd == 0) {
            return 0;
        }
        uint[] storage _0xf87eac = _0x8e8b32._0x013e6e[_0x779979][_0xcdbfcd - 1]._0x9af72f;
        uint _0xce3fed = 0;
        for (uint i = 0; i < _0xf87eac.length; i++) {
            uint _0xbe3efa = _0xf87eac[i];
            if (block.timestamp > 0) { _0xce3fed = _0xce3fed + VotingBalanceLogic._0xf37287(_0xbe3efa, block.timestamp, _0x3ae538); }
        }
        return _0xce3fed;
    }

    function _0xa97b0f(address _0x779979, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 _0x6ab456 = VotingDelegationLib._0x61bfd5(_0x8e8b32, _0x779979, timestamp);

        uint[] storage _0xf87eac = _0x8e8b32._0x013e6e[_0x779979][_0x6ab456]._0x9af72f;
        uint _0xce3fed = 0;
        for (uint i = 0; i < _0xf87eac.length; i++) {
            uint _0xbe3efa = _0xf87eac[i];

            _0xce3fed = _0xce3fed + VotingBalanceLogic._0xf37287(_0xbe3efa, timestamp,  _0x3ae538);
        }

        return _0xce3fed;
    }

    function _0x7a5334(uint256 timestamp) external view returns (uint) {
        return _0x41c737(timestamp);
    }


    function _0x7bfa51(address _0x4524b6, address _0xebefd4) internal {

        address _0x46c3f7 = _0x36ebcd(_0x4524b6);

        _0xc2126b[_0x4524b6] = _0xebefd4;

        emit DelegateChanged(_0x4524b6, _0x46c3f7, _0xebefd4);
        VotingDelegationLib.TokenHelpers memory _0x8b56d5 = VotingDelegationLib.TokenHelpers({
            _0x4ca443: _0x54d806,
            _0x6e30e1: _0x6e30e1,
            _0x5fb461:_0x5fb461
        });
        VotingDelegationLib._0x0d8339(_0x8e8b32, _0x4524b6, _0x46c3f7, _0xebefd4, _0x8b56d5);
    }


    function _0x9d04a4(address _0xebefd4) public {
        if (_0xebefd4 == address(0)) _0xebefd4 = msg.sender;
        return _0x7bfa51(msg.sender, _0xebefd4);
    }

    function _0xff8b2a(
        address _0xebefd4,
        uint _0x25c6f9,
        uint _0xf9f417,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(_0xebefd4 != msg.sender, "NA");
        require(_0xebefd4 != address(0), "ZA");

        bytes32 _0x8863a6 = _0xc1869c(
            abi._0xdab143(
                DOMAIN_TYPEHASH,
                _0xc1869c(bytes(_0xf20ba5)),
                _0xc1869c(bytes(_0x76c514)),
                block.chainid,
                address(this)
            )
        );
        bytes32 _0x621b1a = _0xc1869c(
            abi._0xdab143(DELEGATION_TYPEHASH, _0xebefd4, _0x25c6f9, _0xf9f417)
        );
        bytes32 _0x6b2001 = _0xc1869c(
            abi._0xdd2983("\x19\x01", _0x8863a6, _0x621b1a)
        );
        address _0xcfbeed = _0xd9421c(_0x6b2001, v, r, s);
        require(
            _0xcfbeed != address(0),
            "ZA"
        );
        require(
            _0x25c6f9 == _0x688165[_0xcfbeed]++,
            "!NONCE"
        );
        require(
            block.timestamp <= _0xf9f417,
            "EXP"
        );
        return _0x7bfa51(_0xcfbeed, _0xebefd4);
    }

}