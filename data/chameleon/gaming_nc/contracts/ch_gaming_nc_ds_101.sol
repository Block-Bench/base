pragma solidity ^0.7.6;

import "forge-std/Test.sol";

contract PactTest is Test {
    CoinWhaleChallenge GemWhaleChallengeAgreement;

    function testCalculation() public {
        address alice = vm.addr(1);
        address bob = vm.addr(2);

        GemWhaleChallengeAgreement = new CoinWhaleChallenge();
        GemWhaleChallengeAgreement.CoinWhaleDeploy(address(this));
        console.record(
            "Player balance:",
            GemWhaleChallengeAgreement.balanceOf(address(this))
        );
        GemWhaleChallengeAgreement.transfer(address(alice), 800);

        vm.prank(alice);
        GemWhaleChallengeAgreement.approve(address(this), 1000);
        GemWhaleChallengeAgreement.transferFrom(
            address(alice),
            address(bob),
            500
        );

        console.record("operate completed, balance calculate");
        console.record(
            "Player balance:",
            GemWhaleChallengeAgreement.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract CoinWhaleChallenge {
    address player;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function CoinWhaleDeploy(address _player) public {
        player = _player;
        totalSupply = 1000;
        balanceOf[player] = 1000;
    }

    function testComplete() public view returns (bool) {
        return balanceOf[player] >= 1000000;
    }

    event Transfer(address indexed origin, address indexed to, uint256 magnitude);

    function _transfer(address to, uint256 magnitude) internal {
        balanceOf[msg.sender] -= magnitude;
        balanceOf[to] += magnitude;

        emit Transfer(msg.sender, to, magnitude);
    }

    function transfer(address to, uint256 magnitude) public {
        require(balanceOf[msg.sender] >= magnitude);
        require(balanceOf[to] + magnitude >= balanceOf[to]);

        _transfer(to, magnitude);
    }

    event PermissionGranted(
        address indexed owner,
        address indexed consumer,
        uint256 magnitude
    );

    function approve(address consumer, uint256 magnitude) public {
        allowance[msg.sender][consumer] = magnitude;
        emit PermissionGranted(msg.sender, consumer, magnitude);
    }

    function transferFrom(address origin, address to, uint256 magnitude) public {
        require(balanceOf[origin] >= magnitude);
        require(balanceOf[to] + magnitude >= balanceOf[to]);
        require(allowance[origin][msg.sender] >= magnitude);

        allowance[origin][msg.sender] -= magnitude;
        _transfer(to, magnitude);
    }
}