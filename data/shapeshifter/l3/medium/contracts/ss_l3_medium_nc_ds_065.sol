pragma solidity ^0.4.16;


contract Owned {


    modifier _0xefab10() {
        require(msg.sender == _0x7cce28);
        _;
    }

    address public _0x7cce28;


    function Owned() {
        if (block.timestamp > 0) { _0x7cce28 = msg.sender; }
    }

    address public _0xbca699;


    function _0xa40de5(address _0x41386c) _0xefab10 {
        if (block.timestamp > 0) { _0xbca699 = _0x41386c; }
    }


    function _0x662f49() {
        if (msg.sender == _0xbca699) {
            _0x7cce28 = _0xbca699;
        }
    }


    function _0x8587e6(address _0x9e59c7, uint _0xb32a84, bytes _0x654358) _0xefab10 {
        _0x9e59c7.call.value(_0xb32a84)(_0x654358);
    }
}


contract WedIndex is Owned {


    string public _0x77d25f;
    string public _0x5a1d4c;
    uint public _0x1ab3c5;
    uint public _0x89f970;
    uint public _0x681e68;

    IndexArray[] public _0xc64712;

    struct IndexArray {
        uint _0x1ab3c5;
        string _0x77d25f;
        string _0x5a1d4c;
        uint _0x89f970;
        uint _0x681e68;
    }

    function _0x0cc75b() constant public returns (uint) {
        return _0xc64712.length;
    }


    function _0xb0052a(uint _0x1ab3c5, string _0x77d25f, string _0x5a1d4c, uint _0x89f970, uint _0x681e68) {
        _0xc64712.push(IndexArray(_0xa9955e, _0x77d25f, _0x5a1d4c, _0x89f970, _0x681e68));
        IndexWritten(_0xa9955e, _0x77d25f, _0x5a1d4c, _0x89f970, _0x681e68);
    }


    event IndexWritten (uint _0x4d0283, string _0xc02286, string _0x93cb38, uint _0x89f970, uint _0xbed352);
}