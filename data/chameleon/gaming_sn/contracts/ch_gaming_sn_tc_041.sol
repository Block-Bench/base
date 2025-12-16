// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address consumer, uint256 measure) external returns (bool);
}

contract ShezmuDepositCrystal is IERC20 {
    string public name = "Shezmu Collateral Token";
    string public symbol = "SCT";
    uint8 public decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    function summon(address to, uint256 measure) external {
        balanceOf[to] += measure;
        totalSupply += measure;
    }

    function transfer(
        address to,
        uint256 measure
    ) external override returns (bool) {
        require(balanceOf[msg.initiator] >= measure, "Insufficient balance");
        balanceOf[msg.initiator] -= measure;
        balanceOf[to] += measure;
        return true;
    }

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external override returns (bool) {
        require(balanceOf[source] >= measure, "Insufficient balance");
        require(
            allowance[source][msg.initiator] >= measure,
            "Insufficient allowance"
        );
        balanceOf[source] -= measure;
        balanceOf[to] += measure;
        allowance[source][msg.initiator] -= measure;
        return true;
    }

    function approve(
        address consumer,
        uint256 measure
    ) external override returns (bool) {
        allowance[msg.initiator][consumer] = measure;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public pledgeGem;
    IERC20 public shezUSD;

    mapping(address => uint256) public securityLootbalance;
    mapping(address => uint256) public owingRewardlevel;

    uint256 public constant pledge_factor = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _pledgeGem, address _shezUSD) {
        pledgeGem = IERC20(_pledgeGem);
        shezUSD = IERC20(_shezUSD);
    }

    function appendPledge(uint256 measure) external {
        pledgeGem.transferFrom(msg.initiator, address(this), measure);
        securityLootbalance[msg.initiator] += measure;
    }

    function requestLoan(uint256 measure) external {
        uint256 ceilingSeekadvance = (securityLootbalance[msg.initiator] * BASIS_POINTS) /
            pledge_factor;

        require(
            owingRewardlevel[msg.initiator] + measure <= ceilingSeekadvance,
            "Insufficient collateral"
        );

        owingRewardlevel[msg.initiator] += measure;

        shezUSD.transfer(msg.initiator, measure);
    }

    function returnLoan(uint256 measure) external {
        require(owingRewardlevel[msg.initiator] >= measure, "Excessive repayment");
        shezUSD.transferFrom(msg.initiator, address(this), measure);
        owingRewardlevel[msg.initiator] -= measure;
    }

    function retrieverewardsDeposit(uint256 measure) external {
        require(
            securityLootbalance[msg.initiator] >= measure,
            "Insufficient collateral"
        );
        uint256 remainingSecurity = securityLootbalance[msg.initiator] - measure;
        uint256 maximumLiability = (remainingSecurity * BASIS_POINTS) /
            pledge_factor;
        require(
            owingRewardlevel[msg.initiator] <= maximumLiability,
            "Would be undercollateralized"
        );

        securityLootbalance[msg.initiator] -= measure;
        pledgeGem.transfer(msg.initiator, measure);
    }
}
