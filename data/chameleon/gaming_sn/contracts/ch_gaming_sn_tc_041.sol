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
        require(balanceOf[msg.sender] >= measure, "Insufficient balance");
        balanceOf[msg.sender] -= measure;
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
            allowance[source][msg.sender] >= measure,
            "Insufficient allowance"
        );
        balanceOf[source] -= measure;
        balanceOf[to] += measure;
        allowance[source][msg.sender] -= measure;
        return true;
    }

    function approve(
        address consumer,
        uint256 measure
    ) external override returns (bool) {
        allowance[msg.sender][consumer] = measure;
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
        pledgeGem.transferFrom(msg.sender, address(this), measure);
        securityLootbalance[msg.sender] += measure;
    }

    function requestLoan(uint256 measure) external {
        uint256 ceilingSeekadvance = (securityLootbalance[msg.sender] * BASIS_POINTS) /
            pledge_factor;

        require(
            owingRewardlevel[msg.sender] + measure <= ceilingSeekadvance,
            "Insufficient collateral"
        );

        owingRewardlevel[msg.sender] += measure;

        shezUSD.transfer(msg.sender, measure);
    }

    function returnLoan(uint256 measure) external {
        require(owingRewardlevel[msg.sender] >= measure, "Excessive repayment");
        shezUSD.transferFrom(msg.sender, address(this), measure);
        owingRewardlevel[msg.sender] -= measure;
    }

    function retrieverewardsDeposit(uint256 measure) external {
        require(
            securityLootbalance[msg.sender] >= measure,
            "Insufficient collateral"
        );
        uint256 remainingSecurity = securityLootbalance[msg.sender] - measure;
        uint256 maximumLiability = (remainingSecurity * BASIS_POINTS) /
            pledge_factor;
        require(
            owingRewardlevel[msg.sender] <= maximumLiability,
            "Would be undercollateralized"
        );

        securityLootbalance[msg.sender] -= measure;
        pledgeGem.transfer(msg.sender, measure);
    }
}
