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

    function transferOwnership(address updatedSupervisor) onlyOwner public {
        owner = updatedSupervisor;
    }
}

interface idPatient { function acceptpatientApproval(address _from, uint256 _value, address _token, bytes _extraInfo) external; }

contract CredentialErc20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;

    uint256 public totalSupply;


    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;


    event Transfer(address indexed source, address indexed to, uint256 assessment);


    event AccessGranted(address indexed _owner, address indexed _spender, uint256 _value);

    function CredentialErc20(
        string idLabel,
        string credentialCode
    ) public {
        name = idLabel;
        symbol = credentialCode;
    }

    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0);

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to] + _value > balanceOf[_to]);

        uint priorPatientaccounts = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;

        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == priorPatientaccounts);
    }

    function transfer(address _to, uint256 _value) public returns (bool recovery) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool recovery) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool recovery) {
        allowance[msg.sender][_spender] = _value;
        emit AccessGranted(msg.sender, _spender, _value);
        return true;
    }

    function allowprocedureAndInvokeprotocol(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool recovery) {
        idPatient subscriber = idPatient(_spender);
        if (approve(_spender, _value)) {
            subscriber.acceptpatientApproval(msg.sender, _value, this, _extraInfo);
            return true;
        }
    }

}


contract MyAdvancedCredential is owned, CredentialErc20 {

    mapping (address => bool) public frozenChart;


    event FrozenFunds(address objective, bool frozen);


    function MyAdvancedCredential(
        string idLabel,
        string credentialCode
    ) CredentialErc20(idLabel, credentialCode) public {}


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


    function buy() payable public {
        uint measure = msg.value;
	balanceOf[msg.sender] += measure;
        totalSupply += measure;
        _transfer(address(0x0), msg.sender, measure);
    }


    function migrate_and_destroy() onlyOwner {
	assert(this.balance == totalSupply);
	suicide(owner);
    }
}