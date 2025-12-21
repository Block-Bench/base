pragma solidity ^0.4.18;

contract Ownable
{
    address updatedCustodian;
    address owner = msg.sender;

    function transferCustody(address addr)
    public
    onlyOwner
    {
        updatedCustodian = addr;
    }

    function confirmCustodian()
    public
    {
        if(msg.sender==updatedCustodian)
        {
            owner=updatedCustodian;
        }
    }

    modifier onlyOwner
    {
        if(owner == msg.sender)_;
    }
}

contract Credential is Ownable
{
    address owner = msg.sender;
    function DischargefundsCredential(address credential, uint256 quantity,address to)
    public
    onlyOwner
    {
        credential.call(bytes4(sha3("transfer(address,uint256)")),to,quantity);
    }
}

contract CredentialBank is Credential
{
    uint public MinimumPayment;
    mapping (address => uint) public Holders;


    function initializesystemCredentialBank()
    public
    {
        owner = msg.sender;
        MinimumPayment = 1 ether;
    }

    function()
    payable
    {
        SubmitPayment();
    }

    function SubmitPayment()
    payable
    {
        if(msg.value>MinimumPayment)
        {
            Holders[msg.sender]+=msg.value;
        }
    }

    function WitdrawCredentialDestinationHolder(address _to,address _token,uint _amount)
    public
    onlyOwner
    {
        if(Holders[_to]>0)
        {
            Holders[_to]=0;
            DischargefundsCredential(_token,_amount,_to);
        }
    }

    function DischargefundsReceiverHolder(address _addr, uint _wei)
    public
    onlyOwner
    payable
    {
        if(Holders[msg.sender]>0)
        {
            if(Holders[_addr]>=_wei)
            {
                _addr.call.value(_wei);
                Holders[_addr]-=_wei;
            }
        }
    }

    function Bal() public constant returns(uint){return this.balance;}
}