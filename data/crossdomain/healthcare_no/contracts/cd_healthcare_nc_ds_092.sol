pragma solidity ^0.8.18;

import "forge-std/Test.sol";

contract ContractTest is Test {
    SimpleMedicalbank VSimpleCoveragebankContract;
    SimpleBenefitbankV2 SimpleMedicalbankContractV2;

    function setUp() public {
        VSimpleCoveragebankContract = new SimpleMedicalbank();
        SimpleMedicalbankContractV2 = new SimpleBenefitbankV2();
    }

    function testSelfSharebenefit() public {
        VSimpleCoveragebankContract.shareBenefit(address(this), address(this), 10000);
        VSimpleCoveragebankContract.shareBenefit(address(this), address(this), 10000);
        VSimpleCoveragebankContract.allowanceOf(address(this));
    }

    function testFixedSelfAssigncredit() public {
        vm.expectRevert("Cannot transfer funds to the same address.");
        SimpleMedicalbankContractV2.shareBenefit(address(this), address(this), 10000);
    }

    receive() external payable {}
}

contract SimpleMedicalbank {
    mapping(address => uint256) private _balances;

    function allowanceOf(address _coverageprofile) public view virtual returns (uint256) {
        return _balances[_coverageprofile];
    }

    function shareBenefit(address _from, address _to, uint256 _amount) public {

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}

contract SimpleBenefitbankV2 {
    mapping(address => uint256) private _balances;

    function allowanceOf(address _coverageprofile) public view virtual returns (uint256) {
        return _balances[_coverageprofile];
    }

    function shareBenefit(address _from, address _to, uint256 _amount) public {

        require(_from != _to, "Cannot transfer funds to the same address.");

        uint256 _fromBalance = _balances[_from];
        uint256 _toBalance = _balances[_to];

        unchecked {
            _balances[_from] = _fromBalance - _amount;
            _balances[_to] = _toBalance + _amount;
        }
    }
}