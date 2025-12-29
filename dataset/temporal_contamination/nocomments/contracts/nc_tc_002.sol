/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IDiamondCut {
/*LN-4*/     struct FacetCut {
/*LN-5*/         address facetAddress;
/*LN-6*/         uint8 action;
/*LN-7*/         bytes4[] functionSelectors;
/*LN-8*/     }
/*LN-9*/ }
/*LN-10*/ 
/*LN-11*/ contract BasicGovernance {
/*LN-12*/ 
/*LN-13*/     mapping(address => uint256) public depositedBalance;
/*LN-14*/     mapping(address => uint256) public votingPower;
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/     struct Proposal {
/*LN-18*/         address proposer;
/*LN-19*/         address target;
/*LN-20*/         bytes data;
/*LN-21*/         uint256 forVotes;
/*LN-22*/         uint256 startTime;
/*LN-23*/         bool executed;
/*LN-24*/     }
/*LN-25*/ 
/*LN-26*/     mapping(uint256 => Proposal) public proposals;
/*LN-27*/     mapping(uint256 => mapping(address => bool)) public hasVoted;
/*LN-28*/     uint256 public proposalCount;
/*LN-29*/ 
/*LN-30*/     uint256 public totalVotingPower;
/*LN-31*/ 
/*LN-32*/ 
/*LN-33*/     uint256 constant EMERGENCY_THRESHOLD = 66;
/*LN-34*/ 
/*LN-35*/     event ProposalCreated(
/*LN-36*/         uint256 indexed proposalId,
/*LN-37*/         address proposer,
/*LN-38*/         address target
/*LN-39*/     );
/*LN-40*/     event Voted(uint256 indexed proposalId, address voter, uint256 votes);
/*LN-41*/     event ProposalExecuted(uint256 indexed proposalId);
/*LN-42*/ 
/*LN-43*/     function deposit(uint256 amount) external {
/*LN-44*/ 
/*LN-45*/ 
/*LN-46*/         depositedBalance[msg.sender] += amount;
/*LN-47*/         votingPower[msg.sender] += amount;
/*LN-48*/         totalVotingPower += amount;
/*LN-49*/     }
/*LN-50*/ 
/*LN-51*/     function propose(
/*LN-52*/         IDiamondCut.FacetCut[] calldata,
/*LN-53*/         address _target,
/*LN-54*/         bytes calldata _calldata,
/*LN-55*/         uint8
/*LN-56*/     ) external returns (uint256) {
/*LN-57*/         proposalCount++;
/*LN-58*/ 
/*LN-59*/         Proposal storage prop = proposals[proposalCount];
/*LN-60*/         prop.proposer = msg.sender;
/*LN-61*/         prop.target = _target;
/*LN-62*/         prop.data = _calldata;
/*LN-63*/         prop.startTime = block.timestamp;
/*LN-64*/         prop.executed = false;
/*LN-65*/ 
/*LN-66*/ 
/*LN-67*/         prop.forVotes = votingPower[msg.sender];
/*LN-68*/         hasVoted[proposalCount][msg.sender] = true;
/*LN-69*/ 
/*LN-70*/         emit ProposalCreated(proposalCount, msg.sender, _target);
/*LN-71*/         return proposalCount;
/*LN-72*/     }
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/     function vote(uint256 proposalId) external {
/*LN-76*/         require(!hasVoted[proposalId][msg.sender], "Already voted");
/*LN-77*/         require(!proposals[proposalId].executed, "Already executed");
/*LN-78*/ 
/*LN-79*/         proposals[proposalId].forVotes += votingPower[msg.sender];
/*LN-80*/         hasVoted[proposalId][msg.sender] = true;
/*LN-81*/ 
/*LN-82*/         emit Voted(proposalId, msg.sender, votingPower[msg.sender]);
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     function emergencyCommit(uint256 proposalId) external {
/*LN-86*/         Proposal storage prop = proposals[proposalId];
/*LN-87*/         require(!prop.executed, "Already executed");
/*LN-88*/ 
/*LN-89*/ 
/*LN-90*/         uint256 votePercentage = (prop.forVotes * 100) / totalVotingPower;
/*LN-91*/         require(votePercentage >= EMERGENCY_THRESHOLD, "Insufficient votes");
/*LN-92*/ 
/*LN-93*/         prop.executed = true;
/*LN-94*/ 
/*LN-95*/ 
/*LN-96*/         (bool success, ) = prop.target.call(prop.data);
/*LN-97*/         require(success, "Execution failed");
/*LN-98*/ 
/*LN-99*/         emit ProposalExecuted(proposalId);
/*LN-100*/     }
/*LN-101*/ }