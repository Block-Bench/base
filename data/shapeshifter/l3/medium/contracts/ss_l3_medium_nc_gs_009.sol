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
        address indexed _0x3823bb,
        uint _0x8c9f49,
        uint value,
        uint indexed _0x09ea4d,
        DepositType _0xa28448,
        uint _0x2180e6
    );

    event Merge(
        address indexed _0x75f8c2,
        uint256 indexed _0x2d99be,
        uint256 indexed _0x2d9085,
        uint256 _0x950201,
        uint256 _0x1023f5,
        uint256 _0x29909e,
        uint256 _0xa4c215,
        uint256 _0xba3801
    );
    event Split(
        uint256 indexed _0x2d99be,
        uint256 indexed _0x9470ed,
        uint256 indexed _0xe86de0,
        address _0x75f8c2,
        uint256 _0x9950a9,
        uint256 _0x8b481c,
        uint256 _0xa4c215,
        uint256 _0xba3801
    );

    event MultiSplit(
        uint256 indexed _0x2d99be,
        uint256[] _0xb8aa14,
        address _0x75f8c2,
        uint256[] _0x368272,
        uint256 _0xa4c215,
        uint256 _0xba3801
    );

    event MetadataUpdate(uint256 _0xb1b772);
    event BatchMetadataUpdate(uint256 _0x3ce2e4, uint256 _0x2994d9);

    event Withdraw(address indexed _0x3823bb, uint _0x8c9f49, uint value, uint _0x2180e6);
    event LockPermanent(address indexed _0x5584dc, uint256 indexed _0xb1b772, uint256 _0x61f75a, uint256 _0xba3801);
    event UnlockPermanent(address indexed _0x5584dc, uint256 indexed _0xb1b772, uint256 _0x61f75a, uint256 _0xba3801);
    event Supply(uint _0x268a97, uint _0x22a398);


    address public immutable _0x70338e;
    address public _0x764840;
    address public _0xda0569;
    address public _0x485514;


    uint public PRECISISON = 10000;


    mapping(bytes4 => bool) internal _0x26e0cf;
    mapping(uint => bool) internal _0x7b03b7;


    bytes4 internal constant ERC165_INTERFACE_ID = 0x01ffc9a7;


    bytes4 internal constant ERC721_INTERFACE_ID = 0x80ac58cd;


    bytes4 internal constant ERC721_METADATA_INTERFACE_ID = 0x5b5e139f;


    uint internal _0x8c9f49;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal _0xc466cd;
    IHybra public _0x5500f3;


    VotingDelegationLib.Data private _0xa9f396;

    VotingBalanceLogic.Data private _0xf438fa;


    constructor(address _0x30bc02, address _0x2eecb4) {
        _0x70338e = _0x30bc02;
        if (block.timestamp > 0) { _0x764840 = msg.sender; }
        if (block.timestamp > 0) { _0xda0569 = msg.sender; }
        _0x485514 = _0x2eecb4;
        if (gasleft() > 0) { WEEK = HybraTimeLibrary.WEEK; }
        MAXTIME = HybraTimeLibrary.MAX_LOCK_DURATION;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xc466cd = int128(int256(HybraTimeLibrary.MAX_LOCK_DURATION)); }

        _0xf438fa._0x97dbd3[0]._0x8f5491 = block.number;
        _0xf438fa._0x97dbd3[0]._0x2180e6 = block.timestamp;

        _0x26e0cf[ERC165_INTERFACE_ID] = true;
        _0x26e0cf[ERC721_INTERFACE_ID] = true;
        _0x26e0cf[ERC721_METADATA_INTERFACE_ID] = true;
        _0x5500f3 = IHybra(_0x70338e);


        emit Transfer(address(0), address(this), _0x8c9f49);

        emit Transfer(address(this), address(0), _0x8c9f49);
    }


    uint8 internal constant _0xfa5578 = 1;
    uint8 internal constant _0x742b7a = 2;
    uint8 internal _0x257b24 = 1;
    modifier _0xd00d35() {
        require(_0x257b24 == _0xfa5578);
        _0x257b24 = _0x742b7a;
        _;
        _0x257b24 = _0xfa5578;
    }

    modifier _0x473086(uint256 _0xb1b772) {
        require(!_0x7b03b7[_0xb1b772], "PNFT");
        _;
    }

    modifier _0x6505db(uint _0x2d99be) {
        require(_0x85bc88[msg.sender] || _0x85bc88[address(0)], "!SPLIT");
        require(_0x6dcb3b[_0x2d99be] == 0 && !_0x5c88bb[_0x2d99be], "ATT");
        require(_0x7b1aba(msg.sender, _0x2d99be), "NAO");
        _;
    }


    string constant public _0x90bec8 = "veHYBR";
    string constant public _0x82485b = "veHYBR";
    string constant public _0x1b8b40 = "1.0.0";
    uint8 constant public _0xd11339 = 18;

    function _0xc04f4d(address _0xa3d5a5) external {
        require(msg.sender == _0xda0569);
        if (block.timestamp > 0) { _0xda0569 = _0xa3d5a5; }
    }

    function _0x2197fd(address _0x033f1a) external {
        require(msg.sender == _0xda0569);
        _0x485514 = _0x033f1a;
        emit BatchMetadataUpdate(0, type(uint256)._0x58d494);
    }


    function _0x9b7cb5(uint _0xb1b772, bool _0x939803) external {
        require(msg.sender == _0xda0569, "NA");
        require(_0x41d5a2[_0xb1b772] != address(0), "DNE");
        _0x7b03b7[_0xb1b772] = _0x939803;
    }


    function _0x1369dc(uint _0xb1b772) external view returns (string memory) {
        require(_0x41d5a2[_0xb1b772] != address(0), "DNE");
        IVotingEscrow.LockedBalance memory _0x26053e = _0xd3d0ae[_0xb1b772];

        return IVeArtProxy(_0x485514)._0xb7d859(_0xb1b772,VotingBalanceLogic._0x9d84c0(_0xb1b772, block.timestamp, _0xf438fa),_0x26053e._0x3b3035,uint(int256(_0x26053e._0x61f75a)));
    }


    mapping(uint => address) internal _0x41d5a2;


    mapping(address => uint) internal _0xe8dd26;


    function _0x4207a5(uint _0xb1b772) public view returns (address) {
        return _0x41d5a2[_0xb1b772];
    }

    function _0xee52fb(address _0x7be9da) public view returns (uint) {

        return _0xe8dd26[_0x7be9da];
    }


    function _0xa0c7f8(address _0x5584dc) internal view returns (uint) {
        return _0xe8dd26[_0x5584dc];
    }


    function _0x1b7cca(address _0x5584dc) external view returns (uint) {
        return _0xa0c7f8(_0x5584dc);
    }


    mapping(uint => address) internal _0xfb97d2;


    mapping(address => mapping(address => bool)) internal _0x0a94c8;

    mapping(uint => uint) public _0x28b0f3;


    function _0x6c6cc7(uint _0xb1b772) external view returns (address) {
        return _0xfb97d2[_0xb1b772];
    }


    function _0x4cdad9(address _0x5584dc, address _0x81aa27) external view returns (bool) {
        return (_0x0a94c8[_0x5584dc])[_0x81aa27];
    }


    function _0x35cebf(address _0x1cf7aa, uint _0xb1b772) public {
        address _0x7be9da = _0x41d5a2[_0xb1b772];

        require(_0x7be9da != address(0), "ZA");

        require(_0x1cf7aa != _0x7be9da, "IA");

        bool _0x245d01 = (_0x41d5a2[_0xb1b772] == msg.sender);
        bool _0x23fd37 = (_0x0a94c8[_0x7be9da])[msg.sender];
        require(_0x245d01 || _0x23fd37, "NAO");

        _0xfb97d2[_0xb1b772] = _0x1cf7aa;
        emit Approval(_0x7be9da, _0x1cf7aa, _0xb1b772);
    }


    function _0xaf099a(address _0x81aa27, bool _0x1cf7aa) external {

        assert(_0x81aa27 != msg.sender);
        _0x0a94c8[msg.sender][_0x81aa27] = _0x1cf7aa;
        emit ApprovalForAll(msg.sender, _0x81aa27, _0x1cf7aa);
    }


    function _0xc601cd(address _0x5584dc, uint _0xb1b772) internal {

        assert(_0x41d5a2[_0xb1b772] == _0x5584dc);
        if (_0xfb97d2[_0xb1b772] != address(0)) {

            _0xfb97d2[_0xb1b772] = address(0);
        }
    }


    function _0x7b1aba(address _0x51037e, uint _0xb1b772) internal view returns (bool) {
        address _0x7be9da = _0x41d5a2[_0xb1b772];
        bool _0x950f8b = _0x7be9da == _0x51037e;
        bool _0x5963bb = _0x51037e == _0xfb97d2[_0xb1b772];
        bool _0xa35593 = (_0x0a94c8[_0x7be9da])[_0x51037e];
        return _0x950f8b || _0x5963bb || _0xa35593;
    }

    function _0x61b655(address _0x51037e, uint _0xb1b772) external view returns (bool) {
        return _0x7b1aba(_0x51037e, _0xb1b772);
    }


    function _0x45c9c4(
        address _0x2d99be,
        address _0x2d9085,
        uint _0xb1b772,
        address _0x75f8c2
    ) internal _0x473086(_0xb1b772) {
        require(_0x6dcb3b[_0xb1b772] == 0 && !_0x5c88bb[_0xb1b772], "ATT");

        require(_0x7b1aba(_0x75f8c2, _0xb1b772), "NAO");


        _0xc601cd(_0x2d99be, _0xb1b772);

        _0x8aaf8f(_0x2d99be, _0xb1b772);

        VotingDelegationLib._0xb0e559(_0xa9f396, _0x7849a3(_0x2d99be), _0x7849a3(_0x2d9085), _0xb1b772, _0x4207a5);

        _0x19a75a(_0x2d9085, _0xb1b772);

        _0x28b0f3[_0xb1b772] = block.number;


        emit Transfer(_0x2d99be, _0x2d9085, _0xb1b772);
    }


    function _0xac7a97(
        address _0x2d99be,
        address _0x2d9085,
        uint _0xb1b772
    ) external {
        _0x45c9c4(_0x2d99be, _0x2d9085, _0xb1b772, msg.sender);
    }


    function _0xef5c7d(
        address _0x2d99be,
        address _0x2d9085,
        uint _0xb1b772
    ) external {
        _0xef5c7d(_0x2d99be, _0x2d9085, _0xb1b772, "");
    }

    function _0x9213d6(address _0x06e542) internal view returns (bool) {


        uint _0x161798;
        assembly {
            _0x161798 := extcodesize(_0x06e542)
        }
        return _0x161798 > 0;
    }


    function _0xef5c7d(
        address _0x2d99be,
        address _0x2d9085,
        uint _0xb1b772,
        bytes memory _0x339054
    ) public {
        _0x45c9c4(_0x2d99be, _0x2d9085, _0xb1b772, msg.sender);

        if (_0x9213d6(_0x2d9085)) {

            try IERC721Receiver(_0x2d9085)._0x7a6470(msg.sender, _0x2d99be, _0xb1b772, _0x339054) returns (bytes4 _0x3c1a73) {
                if (_0x3c1a73 != IERC721Receiver(_0x2d9085)._0x7a6470.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory _0x7262ba) {
                if (_0x7262ba.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(add(32, _0x7262ba), mload(_0x7262ba))
                    }
                }
            }
        }
    }


    function _0x075bae(bytes4 _0x993353) external view returns (bool) {
        return _0x26e0cf[_0x993353];
    }


    mapping(address => mapping(uint => uint)) internal _0x9c7844;


    mapping(uint => uint) internal _0x6a6698;


    function _0xfdae71(address _0x5584dc, uint _0x89e0f2) public view returns (uint) {
        return _0x9c7844[_0x5584dc][_0x89e0f2];
    }


    function _0x190f3c(address _0x2d9085, uint _0xb1b772) internal {
        uint _0xfa9ef8 = _0xa0c7f8(_0x2d9085);

        _0x9c7844[_0x2d9085][_0xfa9ef8] = _0xb1b772;
        _0x6a6698[_0xb1b772] = _0xfa9ef8;
    }


    function _0x19a75a(address _0x2d9085, uint _0xb1b772) internal {

        assert(_0x41d5a2[_0xb1b772] == address(0));

        _0x41d5a2[_0xb1b772] = _0x2d9085;

        _0x190f3c(_0x2d9085, _0xb1b772);

        _0xe8dd26[_0x2d9085] += 1;
    }


    function _0xd8fb69(address _0x2d9085, uint _0xb1b772) internal returns (bool) {

        assert(_0x2d9085 != address(0));

        VotingDelegationLib._0xb0e559(_0xa9f396, address(0), _0x7849a3(_0x2d9085), _0xb1b772, _0x4207a5);

        _0x19a75a(_0x2d9085, _0xb1b772);
        emit Transfer(address(0), _0x2d9085, _0xb1b772);
        return true;
    }


    function _0x724469(address _0x2d99be, uint _0xb1b772) internal {

        uint _0xfa9ef8 = _0xa0c7f8(_0x2d99be) - 1;
        uint _0x27d3cf = _0x6a6698[_0xb1b772];

        if (_0xfa9ef8 == _0x27d3cf) {

            _0x9c7844[_0x2d99be][_0xfa9ef8] = 0;

            _0x6a6698[_0xb1b772] = 0;
        } else {
            uint _0x234a4e = _0x9c7844[_0x2d99be][_0xfa9ef8];


            _0x9c7844[_0x2d99be][_0x27d3cf] = _0x234a4e;

            _0x6a6698[_0x234a4e] = _0x27d3cf;


            _0x9c7844[_0x2d99be][_0xfa9ef8] = 0;

            _0x6a6698[_0xb1b772] = 0;
        }
    }


    function _0x8aaf8f(address _0x2d99be, uint _0xb1b772) internal {

        assert(_0x41d5a2[_0xb1b772] == _0x2d99be);

        _0x41d5a2[_0xb1b772] = address(0);

        _0x724469(_0x2d99be, _0xb1b772);

        _0xe8dd26[_0x2d99be] -= 1;
    }

    function _0xa7c58a(uint _0xb1b772) internal {
        require(_0x7b1aba(msg.sender, _0xb1b772), "NAO");

        address _0x7be9da = _0x4207a5(_0xb1b772);


        delete _0xfb97d2[_0xb1b772];


        _0x8aaf8f(_0x7be9da, _0xb1b772);

        VotingDelegationLib._0xb0e559(_0xa9f396, _0x7849a3(_0x7be9da), address(0), _0xb1b772, _0x4207a5);

        emit Transfer(_0x7be9da, address(0), _0xb1b772);
    }


    mapping(uint => IVotingEscrow.LockedBalance) public _0xd3d0ae;
    uint public _0xe10e13;
    uint public _0xce8926;
    mapping(uint => int128) public _0x4884f5;
    uint public _0x22a398;
    mapping(address => bool) public _0x85bc88;

    uint internal constant MULTIPLIER = 1 ether;


    function _0x35fa77(uint _0xb1b772) external view returns (int128) {
        uint _0x71741d = _0xf438fa._0xd92255[_0xb1b772];
        return _0xf438fa._0x1ab10c[_0xb1b772][_0x71741d]._0xea73a7;
    }


    function _0x1ab10c(uint _0xb1b772, uint _0xaa6cf9) external view returns (IVotingEscrow.Point memory) {
        return _0xf438fa._0x1ab10c[_0xb1b772][_0xaa6cf9];
    }

    function _0x97dbd3(uint _0xce8926) external view returns (IVotingEscrow.Point memory) {
        return _0xf438fa._0x97dbd3[_0xce8926];
    }

    function _0xd92255(uint _0x8c9f49) external view returns (uint) {
        return _0xf438fa._0xd92255[_0x8c9f49];
    }


    function _0x694d89(
        uint _0xb1b772,
        IVotingEscrow.LockedBalance memory _0xf867f9,
        IVotingEscrow.LockedBalance memory _0xa81a40
    ) internal {
        IVotingEscrow.Point memory _0x8d8af9;
        IVotingEscrow.Point memory _0x2228f1;
        int128 _0x869c27 = 0;
        int128 _0xee348c = 0;
        uint _0x4e1c82 = _0xce8926;

        if (_0xb1b772 != 0) {
            _0x2228f1._0xf4ff4f = 0;

            if(_0xa81a40._0xc69e18){
                _0x2228f1._0xf4ff4f = uint(int256(_0xa81a40._0x61f75a));
            }


            if (_0xf867f9._0x3b3035 > block.timestamp && _0xf867f9._0x61f75a > 0) {
                _0x8d8af9._0xea73a7 = _0xf867f9._0x61f75a / _0xc466cd;
                _0x8d8af9._0x95f721 = _0x8d8af9._0xea73a7 * int128(int256(_0xf867f9._0x3b3035 - block.timestamp));
            }
            if (_0xa81a40._0x3b3035 > block.timestamp && _0xa81a40._0x61f75a > 0) {
                _0x2228f1._0xea73a7 = _0xa81a40._0x61f75a / _0xc466cd;
                _0x2228f1._0x95f721 = _0x2228f1._0xea73a7 * int128(int256(_0xa81a40._0x3b3035 - block.timestamp));
            }


            _0x869c27 = _0x4884f5[_0xf867f9._0x3b3035];
            if (_0xa81a40._0x3b3035 != 0) {
                if (_0xa81a40._0x3b3035 == _0xf867f9._0x3b3035) {
                    _0xee348c = _0x869c27;
                } else {
                    _0xee348c = _0x4884f5[_0xa81a40._0x3b3035];
                }
            }
        }

        IVotingEscrow.Point memory _0x716f24 = IVotingEscrow.Point({_0x95f721: 0, _0xea73a7: 0, _0x2180e6: block.timestamp, _0x8f5491: block.number, _0xf4ff4f: 0});
        if (_0x4e1c82 > 0) {
            _0x716f24 = _0xf438fa._0x97dbd3[_0x4e1c82];
        }
        uint _0x945ef0 = _0x716f24._0x2180e6;


        IVotingEscrow.Point memory _0x0cea1c = _0x716f24;
        uint _0x09d620 = 0;
        if (block.timestamp > _0x716f24._0x2180e6) {
            _0x09d620 = (MULTIPLIER * (block.number - _0x716f24._0x8f5491)) / (block.timestamp - _0x716f24._0x2180e6);
        }


        {
            uint _0x3e0468 = (_0x945ef0 / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {


                _0x3e0468 += WEEK;
                int128 _0x4cc5d4 = 0;
                if (_0x3e0468 > block.timestamp) {
                    _0x3e0468 = block.timestamp;
                } else {
                    _0x4cc5d4 = _0x4884f5[_0x3e0468];
                }
                _0x716f24._0x95f721 -= _0x716f24._0xea73a7 * int128(int256(_0x3e0468 - _0x945ef0));
                _0x716f24._0xea73a7 += _0x4cc5d4;
                if (_0x716f24._0x95f721 < 0) {

                    _0x716f24._0x95f721 = 0;
                }
                if (_0x716f24._0xea73a7 < 0) {

                    _0x716f24._0xea73a7 = 0;
                }
                _0x945ef0 = _0x3e0468;
                _0x716f24._0x2180e6 = _0x3e0468;
                _0x716f24._0x8f5491 = _0x0cea1c._0x8f5491 + (_0x09d620 * (_0x3e0468 - _0x0cea1c._0x2180e6)) / MULTIPLIER;
                _0x4e1c82 += 1;
                if (_0x3e0468 == block.timestamp) {
                    _0x716f24._0x8f5491 = block.number;
                    break;
                } else {
                    _0xf438fa._0x97dbd3[_0x4e1c82] = _0x716f24;
                }
            }
        }

        _0xce8926 = _0x4e1c82;


        if (_0xb1b772 != 0) {


            _0x716f24._0xea73a7 += (_0x2228f1._0xea73a7 - _0x8d8af9._0xea73a7);
            _0x716f24._0x95f721 += (_0x2228f1._0x95f721 - _0x8d8af9._0x95f721);
            if (_0x716f24._0xea73a7 < 0) {
                _0x716f24._0xea73a7 = 0;
            }
            if (_0x716f24._0x95f721 < 0) {
                _0x716f24._0x95f721 = 0;
            }
            _0x716f24._0xf4ff4f = _0xe10e13;
        }


        _0xf438fa._0x97dbd3[_0x4e1c82] = _0x716f24;

        if (_0xb1b772 != 0) {


            if (_0xf867f9._0x3b3035 > block.timestamp) {

                _0x869c27 += _0x8d8af9._0xea73a7;
                if (_0xa81a40._0x3b3035 == _0xf867f9._0x3b3035) {
                    _0x869c27 -= _0x2228f1._0xea73a7;
                }
                _0x4884f5[_0xf867f9._0x3b3035] = _0x869c27;
            }

            if (_0xa81a40._0x3b3035 > block.timestamp) {
                if (_0xa81a40._0x3b3035 > _0xf867f9._0x3b3035) {
                    _0xee348c -= _0x2228f1._0xea73a7;
                    _0x4884f5[_0xa81a40._0x3b3035] = _0xee348c;
                }

            }

            uint _0x59f687 = _0xf438fa._0xd92255[_0xb1b772] + 1;

            _0xf438fa._0xd92255[_0xb1b772] = _0x59f687;
            _0x2228f1._0x2180e6 = block.timestamp;
            _0x2228f1._0x8f5491 = block.number;
            _0xf438fa._0x1ab10c[_0xb1b772][_0x59f687] = _0x2228f1;
        }
    }


    function _0x80aa67(
        uint _0xb1b772,
        uint _0x03daa8,
        uint _0xfda2fc,
        IVotingEscrow.LockedBalance memory _0xa13fdc,
        DepositType _0xa28448
    ) internal {
        IVotingEscrow.LockedBalance memory _0x26053e = _0xa13fdc;
        uint _0xc08fe9 = _0x22a398;

        _0x22a398 = _0xc08fe9 + _0x03daa8;
        IVotingEscrow.LockedBalance memory _0xf867f9;
        (_0xf867f9._0x61f75a, _0xf867f9._0x3b3035, _0xf867f9._0xc69e18) = (_0x26053e._0x61f75a, _0x26053e._0x3b3035, _0x26053e._0xc69e18);

        _0x26053e._0x61f75a += int128(int256(_0x03daa8));

        if (_0xfda2fc != 0) {
            _0x26053e._0x3b3035 = _0xfda2fc;
        }
        _0xd3d0ae[_0xb1b772] = _0x26053e;


        _0x694d89(_0xb1b772, _0xf867f9, _0x26053e);

        address from = msg.sender;
        if (_0x03daa8 != 0) {
            assert(IERC20(_0x70338e)._0xac7a97(from, address(this), _0x03daa8));
        }

        emit Deposit(from, _0xb1b772, _0x03daa8, _0x26053e._0x3b3035, _0xa28448, block.timestamp);
        emit Supply(_0xc08fe9, _0xc08fe9 + _0x03daa8);
    }


    function _0x8ad5a8() external {
        _0x694d89(0, IVotingEscrow.LockedBalance(0, 0, false), IVotingEscrow.LockedBalance(0, 0, false));
    }


    function _0x50a78c(uint _0xb1b772, uint _0x03daa8) external _0xd00d35 {
        IVotingEscrow.LockedBalance memory _0x26053e = _0xd3d0ae[_0xb1b772];

        require(_0x03daa8 > 0, "ZV");
        require(_0x26053e._0x61f75a > 0, 'ZL');
        require(_0x26053e._0x3b3035 > block.timestamp || _0x26053e._0xc69e18, 'EXP');

        if (_0x26053e._0xc69e18) _0xe10e13 += _0x03daa8;

        _0x80aa67(_0xb1b772, _0x03daa8, 0, _0x26053e, DepositType.DEPOSIT_FOR_TYPE);

        if(_0x5c88bb[_0xb1b772]) {
            IVoter(_0x764840)._0x75ed11(_0xb1b772);
        }
    }


    function _0xc87a7a(uint _0x03daa8, uint _0x2bf73b, address _0x2d9085) internal returns (uint) {
        uint _0xfda2fc = (block.timestamp + _0x2bf73b) / WEEK * WEEK;

        require(_0x03daa8 > 0, "ZV");
        require(_0xfda2fc > block.timestamp && (_0xfda2fc <= block.timestamp + MAXTIME), 'IUT');

        ++_0x8c9f49;
        uint _0xb1b772 = _0x8c9f49;
        _0xd8fb69(_0x2d9085, _0xb1b772);

        IVotingEscrow.LockedBalance memory _0x26053e = _0xd3d0ae[_0xb1b772];

        _0x80aa67(_0xb1b772, _0x03daa8, _0xfda2fc, _0x26053e, DepositType.CREATE_LOCK_TYPE);
        return _0xb1b772;
    }


    function _0x2c5aa2(uint _0x03daa8, uint _0x2bf73b) external _0xd00d35 returns (uint) {
        return _0xc87a7a(_0x03daa8, _0x2bf73b, msg.sender);
    }


    function _0x397034(uint _0x03daa8, uint _0x2bf73b, address _0x2d9085) external _0xd00d35 returns (uint) {
        return _0xc87a7a(_0x03daa8, _0x2bf73b, _0x2d9085);
    }


    function _0x98ec83(uint _0xb1b772, uint _0x03daa8) external _0xd00d35 {
        assert(_0x7b1aba(msg.sender, _0xb1b772));

        IVotingEscrow.LockedBalance memory _0x26053e = _0xd3d0ae[_0xb1b772];

        assert(_0x03daa8 > 0);
        require(_0x26053e._0x61f75a > 0, 'ZL');
        require(_0x26053e._0x3b3035 > block.timestamp || _0x26053e._0xc69e18, 'EXP');

        if (_0x26053e._0xc69e18) _0xe10e13 += _0x03daa8;
        _0x80aa67(_0xb1b772, _0x03daa8, 0, _0x26053e, DepositType.INCREASE_LOCK_AMOUNT);


        if(_0x5c88bb[_0xb1b772]) {
            IVoter(_0x764840)._0x75ed11(_0xb1b772);
        }
        emit MetadataUpdate(_0xb1b772);
    }


    function _0x0779be(uint _0xb1b772, uint _0x2bf73b) external _0xd00d35 {
        assert(_0x7b1aba(msg.sender, _0xb1b772));

        IVotingEscrow.LockedBalance memory _0x26053e = _0xd3d0ae[_0xb1b772];
        require(!_0x26053e._0xc69e18, "!NORM");
        uint _0xfda2fc = (block.timestamp + _0x2bf73b) / WEEK * WEEK;

        require(_0x26053e._0x3b3035 > block.timestamp && _0x26053e._0x61f75a > 0, 'EXP||ZV');
        require(_0xfda2fc > _0x26053e._0x3b3035 && (_0xfda2fc <= block.timestamp + MAXTIME), 'IUT');

        _0x80aa67(_0xb1b772, 0, _0xfda2fc, _0x26053e, DepositType.INCREASE_UNLOCK_TIME);


        if(_0x5c88bb[_0xb1b772]) {
            IVoter(_0x764840)._0x75ed11(_0xb1b772);
        }
        emit MetadataUpdate(_0xb1b772);
    }


    function _0xc6ecc8(uint _0xb1b772) external _0xd00d35 {
        assert(_0x7b1aba(msg.sender, _0xb1b772));
        require(_0x6dcb3b[_0xb1b772] == 0 && !_0x5c88bb[_0xb1b772], "ATT");

        IVotingEscrow.LockedBalance memory _0x26053e = _0xd3d0ae[_0xb1b772];
        require(!_0x26053e._0xc69e18, "!NORM");
        require(block.timestamp >= _0x26053e._0x3b3035, "!EXP");
        uint value = uint(int256(_0x26053e._0x61f75a));

        _0xd3d0ae[_0xb1b772] = IVotingEscrow.LockedBalance(0, 0, false);
        uint _0xc08fe9 = _0x22a398;
        _0x22a398 = _0xc08fe9 - value;


        _0x694d89(_0xb1b772, _0x26053e, IVotingEscrow.LockedBalance(0, 0, false));

        assert(IERC20(_0x70338e).transfer(msg.sender, value));


        _0xa7c58a(_0xb1b772);

        emit Withdraw(msg.sender, _0xb1b772, value, block.timestamp);
        emit Supply(_0xc08fe9, _0xc08fe9 - value);
    }

    function _0x2214f8(uint _0xb1b772) external {
        address sender = msg.sender;
        require(_0x7b1aba(sender, _0xb1b772), "NAO");

        IVotingEscrow.LockedBalance memory _0x654575 = _0xd3d0ae[_0xb1b772];
        require(!_0x654575._0xc69e18, "!NORM");
        require(_0x654575._0x3b3035 > block.timestamp, "EXP");
        require(_0x654575._0x61f75a > 0, "ZV");

        uint _0x985219 = uint(int256(_0x654575._0x61f75a));
        _0xe10e13 += _0x985219;
        _0x654575._0x3b3035 = 0;
        _0x654575._0xc69e18 = true;
        _0x694d89(_0xb1b772, _0xd3d0ae[_0xb1b772], _0x654575);
        _0xd3d0ae[_0xb1b772] = _0x654575;
        if(_0x5c88bb[_0xb1b772]) {
            IVoter(_0x764840)._0x75ed11(_0xb1b772);
        }
        emit LockPermanent(sender, _0xb1b772, _0x985219, block.timestamp);
        emit MetadataUpdate(_0xb1b772);
    }

    function _0x07d955(uint _0xb1b772) external {
        address sender = msg.sender;
        require(_0x7b1aba(msg.sender, _0xb1b772), "NAO");

        require(_0x6dcb3b[_0xb1b772] == 0 && !_0x5c88bb[_0xb1b772], "ATT");
        IVotingEscrow.LockedBalance memory _0x654575 = _0xd3d0ae[_0xb1b772];
        require(_0x654575._0xc69e18, "!NORM");
        uint _0x985219 = uint(int256(_0x654575._0x61f75a));
        _0xe10e13 -= _0x985219;
        _0x654575._0x3b3035 = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _0x654575._0xc69e18 = false;

        _0x694d89(_0xb1b772, _0xd3d0ae[_0xb1b772], _0x654575);
        _0xd3d0ae[_0xb1b772] = _0x654575;

        emit UnlockPermanent(sender, _0xb1b772, _0x985219, block.timestamp);
        emit MetadataUpdate(_0xb1b772);
    }


    function _0x9d84c0(uint _0xb1b772) external view returns (uint) {
        if (_0x28b0f3[_0xb1b772] == block.number) return 0;
        return VotingBalanceLogic._0x9d84c0(_0xb1b772, block.timestamp, _0xf438fa);
    }

    function _0x0bc793(uint _0xb1b772, uint _0x1c1e6c) external view returns (uint) {
        return VotingBalanceLogic._0x9d84c0(_0xb1b772, _0x1c1e6c, _0xf438fa);
    }

    function _0x89ab6e(uint _0xb1b772, uint _0xb278f8) external view returns (uint) {
        return VotingBalanceLogic._0x89ab6e(_0xb1b772, _0xb278f8, _0xf438fa, _0xce8926);
    }


    function _0xf69886(uint _0xb278f8) external view returns (uint) {
        return VotingBalanceLogic._0xf69886(_0xb278f8, _0xce8926, _0xf438fa, _0x4884f5);
    }

    function _0xb40c56() external view returns (uint) {
        return _0x054dfa(block.timestamp);
    }


    function _0x054dfa(uint t) public view returns (uint) {
        return VotingBalanceLogic._0x054dfa(t, _0xce8926, _0x4884f5,  _0xf438fa);
    }


    mapping(uint => uint) public _0x6dcb3b;
    mapping(uint => bool) public _0x5c88bb;

    function _0x55adb4(address _0x13980f) external {
        require(msg.sender == _0xda0569);
        _0x764840 = _0x13980f;
    }

    function _0xf26e24(uint _0xb1b772) external {
        require(msg.sender == _0x764840);
        _0x5c88bb[_0xb1b772] = true;
    }

    function _0xeae687(uint _0xb1b772) external {
        require(msg.sender == _0x764840, "NA");
        _0x5c88bb[_0xb1b772] = false;
    }

    function _0xa0249c(uint _0xb1b772) external {
        require(msg.sender == _0x764840, "NA");
        _0x6dcb3b[_0xb1b772] = _0x6dcb3b[_0xb1b772] + 1;
    }

    function _0x271a4a(uint _0xb1b772) external {
        require(msg.sender == _0x764840, "NA");
        _0x6dcb3b[_0xb1b772] = _0x6dcb3b[_0xb1b772] - 1;
    }

    function _0x4531e5(uint _0x2d99be, uint _0x2d9085) external _0xd00d35 _0x473086(_0x2d99be) {
        require(_0x6dcb3b[_0x2d99be] == 0 && !_0x5c88bb[_0x2d99be], "ATT");
        require(_0x2d99be != _0x2d9085, "SAME");
        require(_0x7b1aba(msg.sender, _0x2d99be) &&
        _0x7b1aba(msg.sender, _0x2d9085), "NAO");

        IVotingEscrow.LockedBalance memory _0xa8f708 = _0xd3d0ae[_0x2d99be];
        IVotingEscrow.LockedBalance memory _0x826466 = _0xd3d0ae[_0x2d9085];
        require(_0x826466._0x3b3035 > block.timestamp ||  _0x826466._0xc69e18,"EXP||PERM");
        require(_0xa8f708._0xc69e18 ? _0x826466._0xc69e18 : true, "!MERGE");

        uint _0x7c4f31 = uint(int256(_0xa8f708._0x61f75a));
        uint _0x3b3035 = _0xa8f708._0x3b3035 >= _0x826466._0x3b3035 ? _0xa8f708._0x3b3035 : _0x826466._0x3b3035;

        _0xd3d0ae[_0x2d99be] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x694d89(_0x2d99be, _0xa8f708, IVotingEscrow.LockedBalance(0, 0, false));
        _0xa7c58a(_0x2d99be);

        IVotingEscrow.LockedBalance memory _0x103ff6;
        _0x103ff6._0xc69e18 = _0x826466._0xc69e18;

        if (_0x103ff6._0xc69e18){
            _0x103ff6._0x61f75a = _0x826466._0x61f75a + _0xa8f708._0x61f75a;
            if (!_0xa8f708._0xc69e18) {
                _0xe10e13 += _0x7c4f31;
            }
        }else{
            _0x103ff6._0x61f75a = _0x826466._0x61f75a + _0xa8f708._0x61f75a;
            _0x103ff6._0x3b3035 = _0x3b3035;
        }


        _0x694d89(_0x2d9085, _0x826466, _0x103ff6);
        _0xd3d0ae[_0x2d9085] = _0x103ff6;

        if(_0x5c88bb[_0x2d9085]) {
            IVoter(_0x764840)._0x75ed11(_0x2d9085);
        }
        emit Merge(
            msg.sender,
            _0x2d99be,
            _0x2d9085,
            uint(int256(_0xa8f708._0x61f75a)),
            uint(int256(_0x826466._0x61f75a)),
            uint(int256(_0x103ff6._0x61f75a)),
            _0x103ff6._0x3b3035,
            block.timestamp
        );
        emit MetadataUpdate(_0x2d9085);
    }


    function _0xc4bc8f(
        uint _0x2d99be,
        uint[] memory _0x2a3d40
    ) external _0xd00d35 _0x6505db(_0x2d99be) _0x473086(_0x2d99be) returns (uint256[] memory _0x67c4be) {
        require(_0x2a3d40.length >= 2 && _0x2a3d40.length <= 10, "MIN2MAX10");

        address _0x7be9da = _0x41d5a2[_0x2d99be];

        IVotingEscrow.LockedBalance memory _0xa6d254 = _0xd3d0ae[_0x2d99be];
        require(_0xa6d254._0x3b3035 > block.timestamp || _0xa6d254._0xc69e18, "EXP");
        require(_0xa6d254._0x61f75a > 0, "ZV");


        uint _0x68cf54 = 0;
        for(uint i = 0; i < _0x2a3d40.length; i++) {
            require(_0x2a3d40[i] > 0, "ZW");
            _0x68cf54 += _0x2a3d40[i];
        }


        _0xd3d0ae[_0x2d99be] = IVotingEscrow.LockedBalance(0, 0, false);
        _0x694d89(_0x2d99be, _0xa6d254, IVotingEscrow.LockedBalance(0, 0, false));
        _0xa7c58a(_0x2d99be);


        _0x67c4be = new uint256[](_0x2a3d40.length);
        uint[] memory _0x4547b2 = new uint[](_0x2a3d40.length);

        for(uint i = 0; i < _0x2a3d40.length; i++) {
            IVotingEscrow.LockedBalance memory _0x57f2c8 = IVotingEscrow.LockedBalance({
                _0x61f75a: int128(int256(uint256(int256(_0xa6d254._0x61f75a)) * _0x2a3d40[i] / _0x68cf54)),
                _0x3b3035: _0xa6d254._0x3b3035,
                _0xc69e18: _0xa6d254._0xc69e18
            });

            _0x67c4be[i] = _0x61a4a4(_0x7be9da, _0x57f2c8);
            _0x4547b2[i] = uint256(int256(_0x57f2c8._0x61f75a));
        }

        emit MultiSplit(
            _0x2d99be,
            _0x67c4be,
            msg.sender,
            _0x4547b2,
            _0xa6d254._0x3b3035,
            block.timestamp
        );
    }

    function _0x61a4a4(address _0x2d9085, IVotingEscrow.LockedBalance memory _0x654575) private returns (uint256 _0xb1b772) {
        if (true) { _0xb1b772 = ++_0x8c9f49; }
        _0xd3d0ae[_0xb1b772] = _0x654575;
        _0x694d89(_0xb1b772, IVotingEscrow.LockedBalance(0, 0, false), _0x654575);
        _0xd8fb69(_0x2d9085, _0xb1b772);
    }

    function _0x864bf0(address _0x247b2a, bool _0x8653b5) external {
        require(msg.sender == _0xda0569);
        _0x85bc88[_0x247b2a] = _0x8653b5;
    }


    bytes32 public constant DOMAIN_TYPEHASH = _0x784e7f("EIP712Domain(string name,uint256 chainId,address verifyingContract)");


    bytes32 public constant DELEGATION_TYPEHASH = _0x784e7f("Delegation(address delegatee,uint256 nonce,uint256 expiry)");


    mapping(address => address) private _0x14f2b5;


    mapping(address => uint) public _0xe0e56a;


    function _0x7849a3(address _0xa4451a) public view returns (address) {
        address _0xbf15f1 = _0x14f2b5[_0xa4451a];
        return _0xbf15f1 == address(0) ? _0xa4451a : _0xbf15f1;
    }


    function _0xff4d55(address _0x06e542) external view returns (uint) {
        uint32 _0x07b398 = _0xa9f396._0x20b632[_0x06e542];
        if (_0x07b398 == 0) {
            return 0;
        }
        uint[] storage _0x45fd05 = _0xa9f396._0xcecbc9[_0x06e542][_0x07b398 - 1]._0x496709;
        uint _0xf4280d = 0;
        for (uint i = 0; i < _0x45fd05.length; i++) {
            uint _0x38646e = _0x45fd05[i];
            if (msg.sender != address(0) || msg.sender == address(0)) { _0xf4280d = _0xf4280d + VotingBalanceLogic._0x9d84c0(_0x38646e, block.timestamp, _0xf438fa); }
        }
        return _0xf4280d;
    }

    function _0x3fd922(address _0x06e542, uint timestamp)
        public
        view
        returns (uint)
    {
        uint32 _0xd88c6d = VotingDelegationLib._0x22d255(_0xa9f396, _0x06e542, timestamp);

        uint[] storage _0x45fd05 = _0xa9f396._0xcecbc9[_0x06e542][_0xd88c6d]._0x496709;
        uint _0xf4280d = 0;
        for (uint i = 0; i < _0x45fd05.length; i++) {
            uint _0x38646e = _0x45fd05[i];

            _0xf4280d = _0xf4280d + VotingBalanceLogic._0x9d84c0(_0x38646e, timestamp,  _0xf438fa);
        }

        return _0xf4280d;
    }

    function _0x651cf3(uint256 timestamp) external view returns (uint) {
        return _0x054dfa(timestamp);
    }


    function _0xb3513a(address _0xa4451a, address _0xb6f452) internal {

        address _0x8514f3 = _0x7849a3(_0xa4451a);

        _0x14f2b5[_0xa4451a] = _0xb6f452;

        emit DelegateChanged(_0xa4451a, _0x8514f3, _0xb6f452);
        VotingDelegationLib.TokenHelpers memory _0x61bed5 = VotingDelegationLib.TokenHelpers({
            _0xbc4ab0: _0x4207a5,
            _0xee52fb: _0xee52fb,
            _0xfdae71:_0xfdae71
        });
        VotingDelegationLib._0x39619d(_0xa9f396, _0xa4451a, _0x8514f3, _0xb6f452, _0x61bed5);
    }


    function _0xea773b(address _0xb6f452) public {
        if (_0xb6f452 == address(0)) _0xb6f452 = msg.sender;
        return _0xb3513a(msg.sender, _0xb6f452);
    }

    function _0xe8fb0f(
        address _0xb6f452,
        uint _0x396de7,
        uint _0x3a88b3,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(_0xb6f452 != msg.sender, "NA");
        require(_0xb6f452 != address(0), "ZA");

        bytes32 _0x3bee46 = _0x784e7f(
            abi._0x692b45(
                DOMAIN_TYPEHASH,
                _0x784e7f(bytes(_0x90bec8)),
                _0x784e7f(bytes(_0x1b8b40)),
                block.chainid,
                address(this)
            )
        );
        bytes32 _0xcdbb46 = _0x784e7f(
            abi._0x692b45(DELEGATION_TYPEHASH, _0xb6f452, _0x396de7, _0x3a88b3)
        );
        bytes32 _0xf327f2 = _0x784e7f(
            abi._0x147175("\x19\x01", _0x3bee46, _0xcdbb46)
        );
        address _0xdbeb27 = _0x826046(_0xf327f2, v, r, s);
        require(
            _0xdbeb27 != address(0),
            "ZA"
        );
        require(
            _0x396de7 == _0xe0e56a[_0xdbeb27]++,
            "!NONCE"
        );
        require(
            block.timestamp <= _0x3a88b3,
            "EXP"
        );
        return _0xb3513a(_0xdbeb27, _0xb6f452);
    }

}