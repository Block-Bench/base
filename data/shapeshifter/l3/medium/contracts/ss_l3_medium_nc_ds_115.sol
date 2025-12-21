pragma solidity 0.4.15;

contract Token {

    uint256 public _0xad2adf;


    function _0x29f801(address _0xda1775) constant returns (uint256 balance);


    function transfer(address _0x3eeae7, uint256 _0x969771) returns (bool _0xfcb37e);


    function _0xba2509(address _0x5cf8e4, address _0x3eeae7, uint256 _0x969771) returns (bool _0xfcb37e);


    function _0xf1ba54(address _0x0af0ed, uint256 _0x969771) returns (bool _0xfcb37e);


    function _0xd618dd(address _0xda1775, address _0x0af0ed) constant returns (uint256 _0x50d01f);

    event Transfer(address indexed _0x5cf8e4, address indexed _0x3eeae7, uint256 _0x969771);
    event Approval(address indexed _0xda1775, address indexed _0x0af0ed, uint256 _0x969771);
}

contract StandardToken is Token {

    function transfer(address _0x3eeae7, uint256 _0x969771) returns (bool _0xfcb37e) {


        require(_0x7e20c2[msg.sender] >= _0x969771);
        _0x7e20c2[msg.sender] -= _0x969771;
        _0x7e20c2[_0x3eeae7] += _0x969771;
        Transfer(msg.sender, _0x3eeae7, _0x969771);
        return true;
    }

    function _0xba2509(address _0x5cf8e4, address _0x3eeae7, uint256 _0x969771) returns (bool _0xfcb37e) {


        require(_0x7e20c2[_0x5cf8e4] >= _0x969771 && _0x6dc3f9[_0x5cf8e4][msg.sender] >= _0x969771);
        _0x7e20c2[_0x3eeae7] += _0x969771;
        _0x7e20c2[_0x5cf8e4] -= _0x969771;
        _0x6dc3f9[_0x5cf8e4][msg.sender] -= _0x969771;
        Transfer(_0x5cf8e4, _0x3eeae7, _0x969771);
        return true;
    }

    function _0x29f801(address _0xda1775) constant returns (uint256 balance) {
        return _0x7e20c2[_0xda1775];
    }

    function _0xf1ba54(address _0x0af0ed, uint256 _0x969771) returns (bool _0xfcb37e) {
        _0x6dc3f9[msg.sender][_0x0af0ed] = _0x969771;
        Approval(msg.sender, _0x0af0ed, _0x969771);
        return true;
    }

    function _0xd618dd(address _0xda1775, address _0x0af0ed) constant returns (uint256 _0x50d01f) {
      return _0x6dc3f9[_0xda1775][_0x0af0ed];
    }

    mapping (address => uint256) _0x7e20c2;
    mapping (address => mapping (address => uint256)) _0x6dc3f9;
}

contract HumanStandardToken is StandardToken {


    string public _0xa9ac04;
    uint8 public _0xf96a38;
    string public _0x664093;
    string public _0x45fa36 = 'H0.1';

    function HumanStandardToken(
        uint256 _0xfd8eae,
        string _0x304439,
        uint8 _0x02b0fa,
        string _0xcab90a
        ) {
        _0x7e20c2[msg.sender] = _0xfd8eae;
        _0xad2adf = _0xfd8eae;
        _0xa9ac04 = _0x304439;
        _0xf96a38 = _0x02b0fa;
        _0x664093 = _0xcab90a;
    }


    function _0xf37354(address _0x0af0ed, uint256 _0x969771, bytes _0x8dfe7d) returns (bool _0xfcb37e) {
        _0x6dc3f9[msg.sender][_0x0af0ed] = _0x969771;
        Approval(msg.sender, _0x0af0ed, _0x969771);


        require(_0x0af0ed.call(bytes4(bytes32(_0xee28ae("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _0x969771, this, _0x8dfe7d));
        return true;
    }
}