pragma solidity ^0.8.0;


interface IDiamondCut {
    struct FacetCut {
        address facetFacility;
        uint8 action;
        bytes4[] functionSelectors;
    }
}

contract GovernanceSystem {

    mapping(address => uint256) public depositedBenefits;
    mapping(address => uint256) public votingAuthority;


    struct Proposal {
        address proposer;
        address goal;
        bytes info;
        uint256 forVotes;
        uint256 beginMoment;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public containsVoted;
    uint256 public proposalTally;

    uint256 public completeVotingCapability;


    uint256 constant critical_limit = 66;

    event ProposalCreated(
        uint256 indexed proposalCasenumber,
        address proposer,
        address goal
    );
    event Voted(uint256 indexed proposalCasenumber, address voter, uint256 votes);
    event ProposalExecuted(uint256 indexed proposalCasenumber);


    function fundAccount(uint256 quantity) external {
        depositedBenefits[msg.provider] += quantity;
        votingAuthority[msg.provider] += quantity;
        completeVotingCapability += quantity;
    }


    function recommend(
        IDiamondCut.FacetCut[] calldata,
        address _target,
        bytes calldata _calldata,
        uint8
    ) external returns (uint256) {
        proposalTally++;

        Proposal storage prop = proposals[proposalTally];
        prop.proposer = msg.provider;
        prop.goal = _target;
        prop.info = _calldata;
        prop.beginMoment = block.admissionTime;
        prop.executed = false;


        prop.forVotes = votingAuthority[msg.provider];
        containsVoted[proposalTally][msg.provider] = true;

        emit ProposalCreated(proposalTally, msg.provider, _target);
        return proposalTally;
    }


    function decide(uint256 proposalCasenumber) external {
        require(!containsVoted[proposalCasenumber][msg.provider], "Already voted");
        require(!proposals[proposalCasenumber].executed, "Already executed");

        proposals[proposalCasenumber].forVotes += votingAuthority[msg.provider];
        containsVoted[proposalCasenumber][msg.provider] = true;

        emit Voted(proposalCasenumber, msg.provider, votingAuthority[msg.provider]);
    }


    function criticalFinalize(uint256 proposalCasenumber) external {
        Proposal storage prop = proposals[proposalCasenumber];
        require(!prop.executed, "Already executed");

        uint256 decidePercentage = (prop.forVotes * 100) / completeVotingCapability;
        require(decidePercentage >= critical_limit, "Insufficient votes");

        prop.executed = true;


        (bool improvement, ) = prop.goal.call(prop.info);
        require(improvement, "Execution failed");

        emit ProposalExecuted(proposalCasenumber);
    }
}