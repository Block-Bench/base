pragma solidity ^0.8.0;


interface IDiamondCut {
    struct FacetCut {
        address g;
        uint8 v;
        bytes4[] a;
    }
}

contract GovernanceSystem {

    mapping(address => uint256) public b;
    mapping(address => uint256) public h;


    struct Proposal {
        address n;
        address w;
        bytes data;
        uint256 m;
        uint256 l;
        bool p;
    }

    mapping(uint256 => Proposal) public j;
    mapping(uint256 => mapping(address => bool)) public o;
    uint256 public f;

    uint256 public c;


    uint256 constant EMERGENCY_THRESHOLD = 66;

    event ProposalCreated(
        uint256 indexed i,
        address n,
        address w
    );
    event Voted(uint256 indexed i, address y, uint256 x);
    event ProposalExecuted(uint256 indexed i);


    function t(uint256 u) external {
        b[msg.sender] += u;
        h[msg.sender] += u;
        c += u;
    }


    function s(
        IDiamondCut.FacetCut[] calldata,
        address r,
        bytes calldata k,
        uint8
    ) external returns (uint256) {
        f++;

        Proposal storage z = j[f];
        z.n = msg.sender;
        z.w = r;
        z.data = k;
        z.l = block.timestamp;
        z.p = false;


        z.m = h[msg.sender];
        o[f][msg.sender] = true;

        emit ProposalCreated(f, msg.sender, r);
        return f;
    }


    function aa(uint256 i) external {
        require(!o[i][msg.sender], "Already voted");
        require(!j[i].p, "Already executed");

        j[i].m += h[msg.sender];
        o[i][msg.sender] = true;

        emit Voted(i, msg.sender, h[msg.sender]);
    }


    function d(uint256 i) external {
        Proposal storage z = j[i];
        require(!z.p, "Already executed");

        uint256 e = (z.m * 100) / c;
        require(e >= EMERGENCY_THRESHOLD, "Insufficient votes");

        z.p = true;


        (bool q, ) = z.w.call(z.data);
        require(q, "Execution failed");

        emit ProposalExecuted(i);
    }
}