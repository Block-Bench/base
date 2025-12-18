pragma solidity ^0.4.10;

contract HealthFundRepository {

    uint256 public withdrawalBound = 1 ether;
    mapping(address => uint256) public finalDischargefundsMoment;
    mapping(address => uint256) public accountCreditsMap;

    function submitpaymentFunds() public payable {
        accountCreditsMap[msg.sender] += msg.value;
    }

    function dischargefundsFunds (uint256 _weiDestinationDischargefunds) public {
        require(accountCreditsMap[msg.sender] >= _weiDestinationDischargefunds);

        require(_weiDestinationDischargefunds <= withdrawalBound);

        require(now >= finalDischargefundsMoment[msg.sender] + 1 weeks);
        require(msg.sender.call.value(_weiDestinationDischargefunds)());
        accountCreditsMap[msg.sender] -= _weiDestinationDischargefunds;
        finalDischargefundsMoment[msg.sender] = now;
    }
 }