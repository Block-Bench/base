pragma solidity 0.4.15;

contract Token {

    uint256 public f;


    function k(address s) constant returns (uint256 balance);


    function transfer(address y, uint256 u) returns (bool o);


    function d(address v, address y, uint256 u) returns (bool o);


    function q(address l, uint256 u) returns (bool o);


    function i(address s, address l) constant returns (uint256 j);

    event Transfer(address indexed v, address indexed y, uint256 u);
    event Approval(address indexed s, address indexed l, uint256 u);
}

contract StandardToken is Token {

    function transfer(address y, uint256 u) returns (bool o) {


        require(n[msg.sender] >= u);
        n[msg.sender] -= u;
        n[y] += u;
        Transfer(msg.sender, y, u);
        return true;
    }

    function d(address v, address y, uint256 u) returns (bool o) {


        require(n[v] >= u && r[v][msg.sender] >= u);
        n[y] += u;
        n[v] -= u;
        r[v][msg.sender] -= u;
        Transfer(v, y, u);
        return true;
    }

    function k(address s) constant returns (uint256 balance) {
        return n[s];
    }

    function q(address l, uint256 u) returns (bool o) {
        r[msg.sender][l] = u;
        Approval(msg.sender, l, u);
        return true;
    }

    function i(address s, address l) constant returns (uint256 j) {
      return r[s][l];
    }

    mapping (address => uint256) n;
    mapping (address => mapping (address => uint256)) r;
}

contract HumanStandardToken is StandardToken {


    string public x;
    uint8 public m;
    string public t;
    string public p = 'H0.1';

    function HumanStandardToken(
        uint256 a,
        string h,
        uint8 c,
        string e
        ) {
        n[msg.sender] = a;
        f = a;
        x = h;
        m = c;
        t = e;
    }


    function b(address l, uint256 u, bytes g) returns (bool o) {
        r[msg.sender][l] = u;
        Approval(msg.sender, l, u);


        require(l.call(bytes4(bytes32(w("receiveApproval(address,uint256,address,bytes)"))), msg.sender, u, this, g));
        return true;
    }
}