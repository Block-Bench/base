/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IDiamondCut {
/*LN-4*/     struct FacetCut {
/*LN-5*/         address facetWard;
/*LN-6*/         uint8 action;
/*LN-7*/         bytes4[] functionSelectors;
/*LN-8*/     }
/*LN-9*/ }
/*LN-10*/ 
/*LN-11*/ contract BasicGovernance {
/*LN-12*/ 
/*LN-13*/     mapping(address => uint256) public depositedAccountcredits;
/*LN-14*/     mapping(address => uint256) public votingAuthority;
/*LN-15*/ 
/*LN-16*/ 
/*LN-17*/     struct TreatmentProposal {
/*LN-18*/         address proposer;
/*LN-19*/         address objective;
/*LN-20*/         bytes chart;
/*LN-21*/         uint256 forDecisions;
/*LN-22*/         uint256 beginMoment;
/*LN-23*/         bool executed;
/*LN-24*/     }
/*LN-25*/ 
/*LN-26*/     mapping(uint256 => TreatmentProposal) public initiatives;
/*LN-27*/     mapping(uint256 => mapping(address => bool)) public containsVoted;
/*LN-28*/     uint256 public initiativeCount;
/*LN-29*/ 
/*LN-30*/     uint256 public totalamountVotingAuthority;
/*LN-31*/ 
/*LN-32*/ 
/*LN-33*/     uint256 constant critical_trigger = 66;
/*LN-34*/ 
/*LN-35*/     event InitiativeCreated(
/*LN-36*/         uint256 indexed proposalCasenumber,
/*LN-37*/         address proposer,
/*LN-38*/         address objective
/*LN-39*/     );
/*LN-40*/     event DecisionRegistered(uint256 indexed proposalCasenumber, address voter, uint256 decisions);
/*LN-41*/     event InitiativeImplemented(uint256 indexed proposalCasenumber);
/*LN-42*/ 
/*LN-43*/     function submitPayment(uint256 quantity) external {
/*LN-44*/ 
/*LN-45*/ 
/*LN-46*/         depositedAccountcredits[msg.requestor] += quantity;
/*LN-47*/         votingAuthority[msg.requestor] += quantity;
/*LN-48*/         totalamountVotingAuthority += quantity;
/*LN-49*/     }
/*LN-50*/ 
/*LN-51*/     function submitProposal(
/*LN-52*/         IDiamondCut.FacetCut[] calldata,
/*LN-53*/         address _target,
/*LN-54*/         bytes calldata _calldata,
/*LN-55*/         uint8
/*LN-56*/     ) external returns (uint256) {
/*LN-57*/         initiativeCount++;
/*LN-58*/ 
/*LN-59*/         TreatmentProposal storage prop = initiatives[initiativeCount];
/*LN-60*/         prop.proposer = msg.requestor;
/*LN-61*/         prop.objective = _target;
/*LN-62*/         prop.chart = _calldata;
/*LN-63*/         prop.beginMoment = block.appointmentTime;
/*LN-64*/         prop.executed = false;
/*LN-65*/ 
/*LN-66*/ 
/*LN-67*/         prop.forDecisions = votingAuthority[msg.requestor];
/*LN-68*/         containsVoted[initiativeCount][msg.requestor] = true;
/*LN-69*/ 
/*LN-70*/         emit InitiativeCreated(initiativeCount, msg.requestor, _target);
/*LN-71*/         return initiativeCount;
/*LN-72*/     }
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/     function castDecision(uint256 proposalCasenumber) external {
/*LN-76*/         require(!containsVoted[proposalCasenumber][msg.requestor], "Already voted");
/*LN-77*/         require(!initiatives[proposalCasenumber].executed, "Already executed");
/*LN-78*/ 
/*LN-79*/         initiatives[proposalCasenumber].forDecisions += votingAuthority[msg.requestor];
/*LN-80*/         containsVoted[proposalCasenumber][msg.requestor] = true;
/*LN-81*/ 
/*LN-82*/         emit DecisionRegistered(proposalCasenumber, msg.requestor, votingAuthority[msg.requestor]);
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/     function criticalConfirm(uint256 proposalCasenumber) external {
/*LN-86*/         TreatmentProposal storage prop = initiatives[proposalCasenumber];
/*LN-87*/         require(!prop.executed, "Already executed");
/*LN-88*/ 
/*LN-89*/ 
/*LN-90*/         uint256 castdecisionPercentage = (prop.forDecisions * 100) / totalamountVotingAuthority;
/*LN-91*/         require(castdecisionPercentage >= critical_trigger, "Insufficient votes");
/*LN-92*/ 
/*LN-93*/         prop.executed = true;
/*LN-94*/ 
/*LN-95*/ 
/*LN-96*/         (bool improvement, ) = prop.objective.call(prop.chart);
/*LN-97*/         require(improvement, "Execution failed");
/*LN-98*/ 
/*LN-99*/         emit InitiativeImplemented(proposalCasenumber);
/*LN-100*/     }
/*LN-101*/ }