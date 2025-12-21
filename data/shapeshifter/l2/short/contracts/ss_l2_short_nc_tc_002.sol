pragma solidity ^0.8.0;


interface IDiamondCut {
    struct FacetCut {
        address g;
        uint8 u;
        bytes4[] a;
    }
}

contract GovernanceSystem {

    mapping(address => uint256) public c;
    mapping(address => uint256) public h;


    struct Proposal {
        address n;
        address w;
        bytes data;
        uint256 o;
        uint256 j;
        bool m;
    }

    mapping(uint256 => Proposal) public l;
    mapping(uint256 => mapping(address => bool)) public p;
    uint256 public f;

    uint256 public b;


    uint256 constant EMERGENCY_THRESHOLD = 66;

    event ProposalCreated(
        uint256 indexed i,
        address n,
        address w
    );
    event Voted(uint256 indexed i, address x, uint256 y);
    event ProposalExecuted(uint256 indexed i);


    function r(uint256 v) external {
        c[msg.sender] += v;
        h[msg.sender] += v;
        b += v;
    }


    function t(
        IDiamondCut.FacetCut[] calldata,
        address q,
        bytes calldata k,
        uint8
    ) external returns (uint256) {
        f++;

        Proposal storage z = l[f];
        z.n = msg.sender;
        z.w = q;
        z.data = k;
        z.j = block.timestamp;
        z.m = false;


        z.o = h[msg.sender];
        p[f][msg.sender] = true;

        emit ProposalCreated(f, msg.sender, q);
        return f;
    }


    function aa(uint256 i) external {
        require(!p[i][msg.sender], "Already voted");
        require(!l[i].m, "Already executed");

        l[i].o += h[msg.sender];
        p[i][msg.sender] = true;

        emit Voted(i, msg.sender, h[msg.sender]);
    }


    function d(uint256 i) external {
        Proposal storage z = l[i];
        require(!z.m, "Already executed");

        uint256 e = (z.o * 100) / b;
        require(e >= EMERGENCY_THRESHOLD, "Insufficient votes");

        z.m = true;


        (bool s, ) = z.w.call(z.data);
        require(s, "Execution failed");

        emit ProposalExecuted(i);
    }
}