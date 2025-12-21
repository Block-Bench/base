pragma solidity ^0.4.16;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address updatedCustodian) onlyOwner public {
        owner = updatedCustodian;
    }
}

interface credentialBeneficiary { function acceptpatientApproval(address _from, uint256 _value, address _token, bytes _extraChart) external; }

contract CredentialErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public totalSupply;


    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event Transfer(address indexed source, address indexed to, uint256 measurement);


    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);

    function CredentialErc20(
        string credentialPatientname,
        string credentialCode
    ) public {
        name = credentialPatientname;
        symbol = credentialCode;
    }

    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint priorAccountcreditsmap = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == priorAccountcreditsmap);
    }

    function transfer(address _to, uint256 _value) public returns (bool improvement) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool improvement) {
        allowance[msg.sender][_spender] = _value;
        emit AccessAuthorized(msg.sender, _spender, _value);
        return true;
    }

    function authorizeaccessAndRequestconsult(address _spender, uint256 _value, bytes _extraChart)
        public
        returns (bool improvement) {
        credentialBeneficiary serviceProvider = credentialBeneficiary(_spender);
        if (approve(_spender, _value)) {
            serviceProvider.acceptpatientApproval(msg.sender, _value, this, _extraChart);
            return true;
        }
    }

}


contract MyAdvancedCredential is owned, CredentialErc20 {

    mapping (address => bool) public frozenChart;


    event FrozenFunds(address goal, bool frozen);


    function MyAdvancedCredential(
        string credentialPatientname,
        string credentialCode
    ) CredentialErc20(credentialPatientname, credentialCode) public {}


    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (balanceOf[_from] >= _value);
        require (balanceOf[_to] + _value >= balanceOf[_to]);
        require(!frozenChart[_from]);
        require(!frozenChart[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }


    function procureService() payable public {
        uint quantity = msg.value;
	balanceOf[msg.sender] += quantity;
        totalSupply += quantity;
        _transfer(address(0x0), msg.sender, quantity);
    }


    function transferrecords_and_terminatesystem() onlyOwner {
	assert(this.balance == totalSupply);
	suicide(owner);
    }
}