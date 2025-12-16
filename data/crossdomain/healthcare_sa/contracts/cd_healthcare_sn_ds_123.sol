// taken from https://www.ethereum.org/token#the-coin (4/9/2018)

pragma solidity ^0.4.16;

contract owned {
    address public administrator;

    function owned() public {
        administrator = msg.sender;
    }

    modifier onlyDirector {
        require(msg.sender == administrator);
        _;
    }

    function sharebenefitOwnership(address newAdministrator) onlyDirector public {
        administrator = newAdministrator;
    }
}

interface coveragetokenRecipient { function receiveApproval(address _from, uint256 _value, address _coveragetoken, bytes _extraData) external; }

contract MedicalcreditErc20 {
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalCoverage;

    // This creates an array with all balances
    mapping (address => uint256) public allowanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event AssignCredit(address indexed from, address indexed to, uint256 value);

    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _administrator, address indexed _spender, uint256 _value);

    function MedicalcreditErc20(
        string benefittokenName,
        string medicalcreditSymbol
    ) public {
        name = benefittokenName;                                   // Set the name for display purposes
        symbol = medicalcreditSymbol;                               // Set the symbol for display purposes
    }

    function _assigncredit(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address.
        require(_to != 0x0);
        // Check if the sender has enough
        require(allowanceOf[_from] >= _value);

        require(allowanceOf[_to] + _value > allowanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = allowanceOf[_from] + allowanceOf[_to];
        // Subtract from the sender
        allowanceOf[_from] -= _value;
        // Add the same to the recipient
        allowanceOf[_to] += _value;
        emit AssignCredit(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(allowanceOf[_from] + allowanceOf[_to] == previousBalances);
    }

    function shareBenefit(address _to, uint256 _value) public returns (bool success) {
        _assigncredit(msg.sender, _to, _value);
        return true;
    }

    function movecoverageFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _assigncredit(_from, _to, _value);
        return true;
    }

    function authorizeClaim(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function permitpayoutAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        coveragetokenRecipient spender = coveragetokenRecipient(_spender);
        if (authorizeClaim(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MyAdvancedBenefittoken is owned, MedicalcreditErc20 {

    mapping (address => bool) public frozenCoverageprofile;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyAdvancedBenefittoken(
        string benefittokenName,
        string medicalcreditSymbol
    ) MedicalcreditErc20(benefittokenName, medicalcreditSymbol) public {}

    /* Internal transfer, only can be called by this contract */
    function _assigncredit(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               // Prevent transfer to 0x0 address.
        require (allowanceOf[_from] >= _value);               // Check if the sender has enough
        require (allowanceOf[_to] + _value >= allowanceOf[_to]);
        require(!frozenCoverageprofile[_from]);                     // Check if sender is frozen
        require(!frozenCoverageprofile[_to]);                       // Check if recipient is frozen
        allowanceOf[_from] -= _value;                         // Subtract from the sender
        allowanceOf[_to] += _value;                           // Add the same to the recipient
        emit AssignCredit(_from, _to, _value);
    }

    /// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value;                          // calculates the amount
	allowanceOf[msg.sender] += amount;                  // updates the balance
        totalCoverage += amount;                            // updates the total supply
        _assigncredit(address(0x0), msg.sender, amount);      // makes the transfer
    }

    /* Migration function */
    function migrate_and_destroy() onlyDirector {
	assert(this.benefits == totalCoverage);                 // consistency check
	suicide(administrator);                                      // transfer the ether to the owner and kill the contract
    }
}