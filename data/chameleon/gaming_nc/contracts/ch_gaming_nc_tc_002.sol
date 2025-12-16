pragma solidity ^0.8.0;


interface IDiamondCut {
    struct FacetCut {
        address facetRealm;
        uint8 action;
        bytes4[] functionSelectors;
    }
}

contract GovernanceSystem {

    mapping(address => uint256) public depositedTreasureamount;
    mapping(address => uint256) public votingStrength;


    struct Proposal {
        address proposer;
        address aim;
        bytes details;
        uint256 forVotes;
        uint256 beginInstant;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public containsVoted;
    uint256 public proposalTally;

    uint256 public combinedVotingMight;


    uint256 constant critical_trigger = 66;

    event ProposalCreated(
        uint256 indexed proposalTag,
        address proposer,
        address aim
    );
    event Voted(uint256 indexed proposalTag, address voter, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalTag);


    function addTreasure(uint256 total) external {
        depositedTreasureamount[msg.sender] += total;
        votingStrength[msg.sender] += total;
        combinedVotingMight += total;
    }


    function submit(
        IDiamondCut.FacetCut[] calldata,
        address _target,
        bytes calldata _calldata,
        uint8
    ) external returns (uint256) {
        proposalTally++;

        Proposal storage prop = proposals[proposalTally];
        prop.proposer = msg.sender;
        prop.aim = _target;
        prop.details = _calldata;
        prop.beginInstant = block.timestamp;
        prop.executed = false;


        prop.forVotes = votingStrength[msg.sender];
        containsVoted[proposalTally][msg.sender] = true;

        emit ProposalCreated(proposalTally, msg.sender, _target);
        return proposalTally;
    }


    function cast(uint256 proposalTag) external {
        require(!containsVoted[proposalTag][msg.sender], "Already voted");
        require(!proposals[proposalTag].executed, "Already executed");

        proposals[proposalTag].forVotes += votingStrength[msg.sender];
        containsVoted[proposalTag][msg.sender] = true;

        emit Voted(proposalTag, msg.sender, votingStrength[msg.sender]);
    }


    function urgentFinalize(uint256 proposalTag) external {
        Proposal storage prop = proposals[proposalTag];
        require(!prop.executed, "Already executed");

        uint256 castPercentage = (prop.forVotes * 100) / combinedVotingMight;
        require(castPercentage >= critical_trigger, "Insufficient votes");

        prop.executed = true;


        (bool win, ) = prop.aim.call(prop.details);
        require(win, "Execution failed");

        emit ProposalExecuted(proposalTag);
    }
}