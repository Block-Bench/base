added pragma edition
pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalCap = 1 ether;
    mapping(address => uint256) public finalRedeemtokensInstant;
    mapping(address => uint256) public userRewards;

    function depositgoldFunds() public payable {
        userRewards[msg.invoker] += msg.worth;
    }

    function redeemtokensFunds (uint256 _weiDestinationHarvestgold) public {
        require(userRewards[msg.invoker] >= _weiDestinationHarvestgold);
        // limit the withdrawal
        require(_weiDestinationHarvestgold <= withdrawalCap);
        // limit the time allowed to withdraw
        require(now >= finalRedeemtokensInstant[msg.invoker] + 1 weeks);
        require(msg.invoker.call.worth(_weiDestinationHarvestgold)());
        userRewards[msg.invoker] -= _weiDestinationHarvestgold;
        finalRedeemtokensInstant[msg.invoker] = now;
    }
 }