pragma solidity 0.4.15;

contract Token {

    uint256 public f;


    function i(address u) constant returns (uint256 balance);


    function transfer(address y, uint256 t) returns (bool o);


    function e(address v, address y, uint256 t) returns (bool o);


    function r(address l, uint256 t) returns (bool o);


    function k(address u, address l) constant returns (uint256 j);

    event Transfer(address indexed v, address indexed y, uint256 t);
    event Approval(address indexed u, address indexed l, uint256 t);
}

contract StandardToken is Token {

    function transfer(address y, uint256 t) returns (bool o) {


        require(m[msg.sender] >= t);
        m[msg.sender] -= t;
        m[y] += t;
        Transfer(msg.sender, y, t);
        return true;
    }

    function e(address v, address y, uint256 t) returns (bool o) {


        require(m[v] >= t && q[v][msg.sender] >= t);
        m[y] += t;
        m[v] -= t;
        q[v][msg.sender] -= t;
        Transfer(v, y, t);
        return true;
    }

    function i(address u) constant returns (uint256 balance) {
        return m[u];
    }

    function r(address l, uint256 t) returns (bool o) {
        q[msg.sender][l] = t;
        Approval(msg.sender, l, t);
        return true;
    }

    function k(address u, address l) constant returns (uint256 j) {
      return q[u][l];
    }

    mapping (address => uint256) m;
    mapping (address => mapping (address => uint256)) q;
}

contract HumanStandardToken is StandardToken {


    string public w;
    uint8 public n;
    string public s;
    string public p = 'H0.1';

    function HumanStandardToken(
        uint256 b,
        string g,
        uint8 c,
        string d
        ) {
        m[msg.sender] = b;
        f = b;
        w = g;
        n = c;
        s = d;
    }


    function a(address l, uint256 t, bytes h) returns (bool o) {
        q[msg.sender][l] = t;
        Approval(msg.sender, l, t);


        require(l.call(bytes4(bytes32(x("receiveApproval(address,uint256,address,bytes)"))), msg.sender, t, this, h));
        return true;
    }
}