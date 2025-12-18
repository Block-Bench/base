pragma solidity 0.4.15;

contract Token {

    uint256 public _0xa374a8;


    function _0x2b09b6(address _0x81f5ae) constant returns (uint256 balance);


    function transfer(address _0xecfdc5, uint256 _0xca76b2) returns (bool _0x04d512);


    function _0xcfb39e(address _0x924a32, address _0xecfdc5, uint256 _0xca76b2) returns (bool _0x04d512);


    function _0xf95e66(address _0xe522b1, uint256 _0xca76b2) returns (bool _0x04d512);


    function _0x7d2f42(address _0x81f5ae, address _0xe522b1) constant returns (uint256 _0xa1a8b2);

    event Transfer(address indexed _0x924a32, address indexed _0xecfdc5, uint256 _0xca76b2);
    event Approval(address indexed _0x81f5ae, address indexed _0xe522b1, uint256 _0xca76b2);
}

contract StandardToken is Token {

    function transfer(address _0xecfdc5, uint256 _0xca76b2) returns (bool _0x04d512) {


        require(_0x557220[msg.sender] >= _0xca76b2);
        _0x557220[msg.sender] -= _0xca76b2;
        _0x557220[_0xecfdc5] += _0xca76b2;
        Transfer(msg.sender, _0xecfdc5, _0xca76b2);
        return true;
    }

    function _0xcfb39e(address _0x924a32, address _0xecfdc5, uint256 _0xca76b2) returns (bool _0x04d512) {


        require(_0x557220[_0x924a32] >= _0xca76b2 && _0xeca15b[_0x924a32][msg.sender] >= _0xca76b2);
        _0x557220[_0xecfdc5] += _0xca76b2;
        _0x557220[_0x924a32] -= _0xca76b2;
        _0xeca15b[_0x924a32][msg.sender] -= _0xca76b2;
        Transfer(_0x924a32, _0xecfdc5, _0xca76b2);
        return true;
    }

    function _0x2b09b6(address _0x81f5ae) constant returns (uint256 balance) {
        return _0x557220[_0x81f5ae];
    }

    function _0xf95e66(address _0xe522b1, uint256 _0xca76b2) returns (bool _0x04d512) {
        _0xeca15b[msg.sender][_0xe522b1] = _0xca76b2;
        Approval(msg.sender, _0xe522b1, _0xca76b2);
        return true;
    }

    function _0x7d2f42(address _0x81f5ae, address _0xe522b1) constant returns (uint256 _0xa1a8b2) {
      return _0xeca15b[_0x81f5ae][_0xe522b1];
    }

    mapping (address => uint256) _0x557220;
    mapping (address => mapping (address => uint256)) _0xeca15b;
}

contract HumanStandardToken is StandardToken {


    string public _0x8bd1b9;
    uint8 public _0x9a6c1e;
    string public _0x17d93c;
    string public _0x7fb66e = 'H0.1';

    function HumanStandardToken(
        uint256 _0x9ec220,
        string _0x8646ef,
        uint8 _0xb49552,
        string _0xaeb9cd
        ) {
        _0x557220[msg.sender] = _0x9ec220;
        _0xa374a8 = _0x9ec220;
        _0x8bd1b9 = _0x8646ef;
        _0x9a6c1e = _0xb49552;
        _0x17d93c = _0xaeb9cd;
    }


    function _0xab3a19(address _0xe522b1, uint256 _0xca76b2, bytes _0xdfb637) returns (bool _0x04d512) {
        _0xeca15b[msg.sender][_0xe522b1] = _0xca76b2;
        Approval(msg.sender, _0xe522b1, _0xca76b2);


        require(_0xe522b1.call(bytes4(bytes32(_0xe7525e("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0xca76b2, this, _0xdfb637));
        return true;
    }
}