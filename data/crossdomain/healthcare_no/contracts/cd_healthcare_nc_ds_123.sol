pragma solidity ^0.4.16;

contract owned {
    address public coordinator;

    function owned() public {
        coordinator = msg.sender;
    }

    modifier onlyManager {
        require(msg.sender == coordinator);
        _;
    }

    function assigncreditOwnership(address newCoordinator) onlyManager public {
        coordinator = newCoordinator;
    }
}

interface medicalcreditRecipient { function receiveApproval(address _from, uint256 _value, address _healthtoken, bytes _extraData) external; }

contract CoveragetokenErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public fundTotal;


    mapping (address => uint256) public creditsOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event AssignCredit(address indexed from, address indexed to, uint256 value);


    event Approval(address indexed _supervisor, address indexed _spender, uint256 _value);

    function CoveragetokenErc20(
        string healthtokenName,
        string coveragetokenSymbol
    ) public {
        name = healthtokenName;
        symbol = coveragetokenSymbol;
    }

    function _transferbenefit(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(creditsOf[_from] >= _value);

        require(creditsOf[_to] + _value > creditsOf[_to]);

        uint previousBalances = creditsOf[_from] + creditsOf[_to];

        creditsOf[_from] -= _value;

        creditsOf[_to] += _value;
        emit AssignCredit(_from, _to, _value);

        assert(creditsOf[_from] + creditsOf[_to] == previousBalances);
    }

    function shareBenefit(address _to, uint256 _value) public returns (bool success) {
        _transferbenefit(msg.sender, _to, _value);
        return true;
    }

    function transferbenefitFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transferbenefit(_from, _to, _value);
        return true;
    }

    function approveBenefit(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function permitpayoutAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        medicalcreditRecipient spender = medicalcreditRecipient(_spender);
        if (approveBenefit(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}


contract MyAdvancedMedicalcredit is owned, CoveragetokenErc20 {

    mapping (address => bool) public frozenPatientaccount;


    event FrozenFunds(address target, bool frozen);


    function MyAdvancedMedicalcredit(
        string healthtokenName,
        string coveragetokenSymbol
    ) CoveragetokenErc20(healthtokenName, coveragetokenSymbol) public {}


    function _transferbenefit(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (creditsOf[_from] >= _value);
        require (creditsOf[_to] + _value >= creditsOf[_to]);
        require(!frozenPatientaccount[_from]);
        require(!frozenPatientaccount[_to]);
        creditsOf[_from] -= _value;
        creditsOf[_to] += _value;
        emit AssignCredit(_from, _to, _value);
    }


    function buy() payable public {
        uint amount = msg.value;
	creditsOf[msg.sender] += amount;
        fundTotal += amount;
        _transferbenefit(address(0x0), msg.sender, amount);
    }


    function migrate_and_destroy() onlyManager {
	assert(this.allowance == fundTotal);
	suicide(coordinator);
    }
}