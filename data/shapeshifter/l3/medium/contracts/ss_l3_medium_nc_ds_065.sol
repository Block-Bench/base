pragma solidity ^0.4.16;


contract Owned {


    modifier _0x610520() {
        require(msg.sender == _0x7e2e34);
        _;
    }

    address public _0x7e2e34;


    function Owned() {
        _0x7e2e34 = msg.sender;
    }

    address public _0xfca273;


    function _0x84c9b4(address _0x2bfa2f) _0x610520 {
        _0xfca273 = _0x2bfa2f;
    }


    function _0xf4e9d2() {
        if (msg.sender == _0xfca273) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x7e2e34 = _0xfca273; }
        }
    }


    function _0x11f6e1(address _0xa49478, uint _0x908980, bytes _0xa8053d) _0x610520 {
        _0xa49478.call.value(_0x908980)(_0xa8053d);
    }
}


contract WedIndex is Owned {


    string public _0xaa2208;
    string public _0x459e8e;
    uint public _0x66c3c7;
    uint public _0x0a3c6f;
    uint public _0xad1495;

    IndexArray[] public _0xcfd5cc;

    struct IndexArray {
        uint _0x66c3c7;
        string _0xaa2208;
        string _0x459e8e;
        uint _0x0a3c6f;
        uint _0xad1495;
    }

    function _0x198232() constant public returns (uint) {
        return _0xcfd5cc.length;
    }


    function _0x17ae05(uint _0x66c3c7, string _0xaa2208, string _0x459e8e, uint _0x0a3c6f, uint _0xad1495) {
        _0xcfd5cc.push(IndexArray(_0xd1274b, _0xaa2208, _0x459e8e, _0x0a3c6f, _0xad1495));
        IndexWritten(_0xd1274b, _0xaa2208, _0x459e8e, _0x0a3c6f, _0xad1495);
    }


    event IndexWritten (uint _0x399695, string _0x76d079, string _0x813ffd, uint _0x0a3c6f, uint _0x49f86d);
}