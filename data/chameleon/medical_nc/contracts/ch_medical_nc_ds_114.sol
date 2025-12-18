pragma solidity ^0.4.23;


contract Credential {

    uint256 public totalSupply;


    function balanceOf(address _owner) public constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool improvement);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement);


    function approve(address _spender, uint256 _value) public returns (bool improvement);


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);
}

library ECTools {


    function healSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
        require(_hashedMsg != 0x00);


        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedChecksum = keccak256(abi.encodePacked(prefix, _hashedMsg));

        if (bytes(_sig).length != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = hexstrDestinationData(substring(_sig, 2, 132));
        assembly {
            r := mload(include(sig, 32))
            s := mload(include(sig, 64))
            v := byte(0, mload(include(sig, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v < 27 || v > 28) {
            return 0x0;
        }
        return ecrecover(prefixedChecksum, v, r, s);
    }


    function testSignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
        require(_addr != 0x0);

        return _addr == healSigner(_hashedMsg, _sig);
    }


    function hexstrDestinationData(string _hexstr) public pure returns (bytes) {
        uint len = bytes(_hexstr).length;
        require(len % 2 == 0);

        bytes memory bstr = bytes(new string(len / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < len; i += 2) {
            s = substring(_hexstr, i, i + 1);
            r = substring(_hexstr, i + 1, i + 2);
            uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
            bstr[k++] = countDestinationBytes32(p)[31];
        }
        return bstr;
    }


    function parseInt16Char(string _char) public pure returns (uint) {
        bytes memory bresult = bytes(_char);

        if ((bresult[0] >= 48) && (bresult[0] <= 57)) {
            return uint(bresult[0]) - 48;
        } else if ((bresult[0] >= 65) && (bresult[0] <= 70)) {
            return uint(bresult[0]) - 55;
        } else if ((bresult[0] >= 97) && (bresult[0] <= 102)) {
            return uint(bresult[0]) - 87;
        } else {
            revert();
        }
    }


    function countDestinationBytes32(uint _uint) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(include(b, 32), _uint)}
    }


    function receiverEthereumSignedNotification(string _msg) public pure returns (bytes32) {
        uint len = bytes(_msg).length;
        require(len > 0);
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, countDestinationText(len), _msg));
    }


    function countDestinationText(uint _uint) public pure returns (string str) {
        uint len = 0;
        uint m = _uint + 0;
        while (m != 0) {
            len++;
            m /= 10;
        }
        bytes memory b = new bytes(len);
        uint i = len - 1;
        while (_uint != 0) {
            uint remainder = _uint % 10;
            _uint = _uint / 10;
            b[i--] = byte(48 + remainder);
        }
        str = string(b);
    }


    function substring(string _str, uint _onsetPosition, uint _dischargeRank) public pure returns (string) {
        bytes memory strData = bytes(_str);
        require(_onsetPosition <= _dischargeRank);
        require(_onsetPosition >= 0);
        require(_dischargeRank <= strData.length);

        bytes memory finding = new bytes(_dischargeRank - _onsetPosition);
        for (uint i = _onsetPosition; i < _dischargeRank; i++) {
            finding[i - _onsetPosition] = strData[i];
        }
        return string(finding);
    }
}
contract StandardCredential is Credential {

    function transfer(address _to, uint256 _value) public returns (bool improvement) {


        require(accountCreditsMap[msg.sender] >= _value);
        accountCreditsMap[msg.sender] -= _value;
        accountCreditsMap[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement) {


        require(accountCreditsMap[_from] >= _value && authorized[_from][msg.sender] >= _value);
        accountCreditsMap[_to] += _value;
        accountCreditsMap[_from] -= _value;
        authorized[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return accountCreditsMap[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool improvement) {
        authorized[msg.sender][_spender] = _value;
        emit AccessAuthorized(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return authorized[_owner][_spender];
    }

    mapping (address => uint256) accountCreditsMap;
    mapping (address => mapping (address => uint256)) authorized;
}

contract HumanStandardCredential is StandardCredential {


    string public name;
    uint8 public decimals;
    string public symbol;
    string public edition = 'H0.1';

    constructor(
        uint256 _initialQuantity,
        string _credentialLabel,
        uint8 _decimalUnits,
        string _credentialDesignation
        ) public {
        accountCreditsMap[msg.sender] = _initialQuantity;
        totalSupply = _initialQuantity;
        name = _credentialLabel;
        decimals = _decimalUnits;
        symbol = _credentialDesignation;
    }


    function authorizeaccessAndConsultspecialist(address _spender, uint256 _value, bytes _extraChart) public returns (bool improvement) {
        authorized[msg.sender][_spender] = _value;
        emit AccessAuthorized(msg.sender, _spender, _value);


        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraChart));
        return true;
    }
}

contract LedgerChannel {

    string public constant NAME = "Ledger Channel";
    string public constant Edition = "0.0.1";

    uint256 public numChannels = 0;

    event DidLCOpen (
        bytes32 indexed channelChartnumber,
        address indexed partyA,
        address indexed partyI,
        uint256 ethAccountcreditsA,
        address credential,
        uint256 credentialAccountcreditsA,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed channelChartnumber,
        uint256 ethAccountcreditsI,
        uint256 credentialAccountcreditsI
    );

    event DidLcSubmitpayment (
        bytes32 indexed channelChartnumber,
        address indexed beneficiary,
        uint256 submitPayment,
        bool isCredential
    );

    event DidLcUpdaterecordsStatus (
        bytes32 indexed channelChartnumber,
        uint256 sequence,
        uint256 numOpenVc,
        uint256 ethAccountcreditsA,
        uint256 credentialAccountcreditsA,
        uint256 ethAccountcreditsI,
        uint256 credentialAccountcreditsI,
        bytes32 vcOrigin,
        uint256 updaterecordsLCtimeout
    );

    event DidLCClose (
        bytes32 indexed channelChartnumber,
        uint256 sequence,
        uint256 ethAccountcreditsA,
        uint256 credentialAccountcreditsA,
        uint256 ethAccountcreditsI,
        uint256 credentialAccountcreditsI
    );

    event DidVcInitializesystem (
        bytes32 indexed lcCasenumber,
        bytes32 indexed vcChartnumber,
        bytes verification,
        uint256 sequence,
        address partyA,
        address partyB,
        uint256 accountcreditsA,
        uint256 accountcreditsB
    );

    event DidVCSettle (
        bytes32 indexed lcCasenumber,
        bytes32 indexed vcChartnumber,
        uint256 updaterecordsSeq,
        uint256 updaterecordsBalA,
        uint256 updaterecordsBalB,
        address challenger,
        uint256 updaterecordsVCtimeout
    );

    event DidVCClose(
        bytes32 indexed lcCasenumber,
        bytes32 indexed vcChartnumber,
        uint256 accountcreditsA,
        uint256 accountcreditsB
    );

    struct CommunicationChannel {

        address[2] partyAddresses;
        uint256[4] ethAccountcreditsmap;
        uint256[4] erc20Accountcreditsmap;
        uint256[2] initialSubmitpayment;
        uint256 sequence;
        uint256 confirmInstant;
        bytes32 VCrootChecksum;
        uint256 LCopenTimeout;
        uint256 updaterecordsLCtimeout;
        bool verifyOpen;
        bool isUpdaterecordsLcSettling;
        uint256 numOpenVC;
        HumanStandardCredential credential;
    }


    struct VirtualChannel {
        bool verifyClose;
        bool isInSettlementStatus;
        uint256 sequence;
        address challenger;
        uint256 updaterecordsVCtimeout;

        address partyA;
        address partyB;
        address partyI;
        uint256[2] ethAccountcreditsmap;
        uint256[2] erc20Accountcreditsmap;
        uint256[2] bond;
        HumanStandardCredential credential;
    }

    mapping(bytes32 => VirtualChannel) public virtualChannels;
    mapping(bytes32 => CommunicationChannel) public Channels;

    function createChannel(
        bytes32 _lcIdentifier,
        address _partyI,
        uint256 _confirmInstant,
        address _token,
        uint256[2] _balances
    )
        public
        payable
    {
        require(Channels[_lcIdentifier].partyAddresses[0] == address(0), "Channel has already been created.");
        require(_partyI != 0x0, "No partyI address provided to LC creation");
        require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


        Channels[_lcIdentifier].partyAddresses[0] = msg.sender;
        Channels[_lcIdentifier].partyAddresses[1] = _partyI;

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "Eth balance does not match sent value");
            Channels[_lcIdentifier].ethAccountcreditsmap[0] = msg.value;
        }
        if(_balances[1] != 0) {
            Channels[_lcIdentifier].credential = HumanStandardCredential(_token);
            require(Channels[_lcIdentifier].credential.transferFrom(msg.sender, this, _balances[1]),"CreateChannel: token transfer failure");
            Channels[_lcIdentifier].erc20Accountcreditsmap[0] = _balances[1];
        }

        Channels[_lcIdentifier].sequence = 0;
        Channels[_lcIdentifier].confirmInstant = _confirmInstant;


        Channels[_lcIdentifier].LCopenTimeout = now + _confirmInstant;
        Channels[_lcIdentifier].initialSubmitpayment = _balances;

        emit DidLCOpen(_lcIdentifier, msg.sender, _partyI, _balances[0], _token, _balances[1], Channels[_lcIdentifier].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _lcIdentifier) public {
        require(msg.sender == Channels[_lcIdentifier].partyAddresses[0] && Channels[_lcIdentifier].verifyOpen == false);
        require(now > Channels[_lcIdentifier].LCopenTimeout);

        if(Channels[_lcIdentifier].initialSubmitpayment[0] != 0) {
            Channels[_lcIdentifier].partyAddresses[0].transfer(Channels[_lcIdentifier].ethAccountcreditsmap[0]);
        }
        if(Channels[_lcIdentifier].initialSubmitpayment[1] != 0) {
            require(Channels[_lcIdentifier].credential.transfer(Channels[_lcIdentifier].partyAddresses[0], Channels[_lcIdentifier].erc20Accountcreditsmap[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_lcIdentifier, 0, Channels[_lcIdentifier].ethAccountcreditsmap[0], Channels[_lcIdentifier].erc20Accountcreditsmap[0], 0, 0);


        delete Channels[_lcIdentifier];
    }

    function joinChannel(bytes32 _lcIdentifier, uint256[2] _balances) public payable {

        require(Channels[_lcIdentifier].verifyOpen == false);
        require(msg.sender == Channels[_lcIdentifier].partyAddresses[1]);

        if(_balances[0] != 0) {
            require(msg.value == _balances[0], "state balance does not match sent value");
            Channels[_lcIdentifier].ethAccountcreditsmap[1] = msg.value;
        }
        if(_balances[1] != 0) {
            require(Channels[_lcIdentifier].credential.transferFrom(msg.sender, this, _balances[1]),"joinChannel: token transfer failure");
            Channels[_lcIdentifier].erc20Accountcreditsmap[1] = _balances[1];
        }

        Channels[_lcIdentifier].initialSubmitpayment[0]+=_balances[0];
        Channels[_lcIdentifier].initialSubmitpayment[1]+=_balances[1];

        Channels[_lcIdentifier].verifyOpen = true;
        numChannels++;

        emit DidLCJoin(_lcIdentifier, _balances[0], _balances[1]);
    }


    function submitPayment(bytes32 _lcIdentifier, address beneficiary, uint256 _balance, bool isCredential) public payable {
        require(Channels[_lcIdentifier].verifyOpen == true, "Tried adding funds to a closed channel");
        require(beneficiary == Channels[_lcIdentifier].partyAddresses[0] || beneficiary == Channels[_lcIdentifier].partyAddresses[1]);


        if (Channels[_lcIdentifier].partyAddresses[0] == beneficiary) {
            if(isCredential) {
                require(Channels[_lcIdentifier].credential.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcIdentifier].erc20Accountcreditsmap[2] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcIdentifier].ethAccountcreditsmap[2] += msg.value;
            }
        }

        if (Channels[_lcIdentifier].partyAddresses[1] == beneficiary) {
            if(isCredential) {
                require(Channels[_lcIdentifier].credential.transferFrom(msg.sender, this, _balance),"deposit: token transfer failure");
                Channels[_lcIdentifier].erc20Accountcreditsmap[3] += _balance;
            } else {
                require(msg.value == _balance, "state balance does not match sent value");
                Channels[_lcIdentifier].ethAccountcreditsmap[3] += msg.value;
            }
        }

        emit DidLcSubmitpayment(_lcIdentifier, beneficiary, _balance, isCredential);
    }


    function consensusCloseChannel(
        bytes32 _lcIdentifier,
        uint256 _sequence,
        uint256[4] _balances,
        string _sigA,
        string _sigI
    )
        public
    {


        require(Channels[_lcIdentifier].verifyOpen == true);
        uint256 totalamountEthSubmitpayment = Channels[_lcIdentifier].initialSubmitpayment[0] + Channels[_lcIdentifier].ethAccountcreditsmap[2] + Channels[_lcIdentifier].ethAccountcreditsmap[3];
        uint256 totalamountCredentialSubmitpayment = Channels[_lcIdentifier].initialSubmitpayment[1] + Channels[_lcIdentifier].erc20Accountcreditsmap[2] + Channels[_lcIdentifier].erc20Accountcreditsmap[3];
        require(totalamountEthSubmitpayment == _balances[0] + _balances[1]);
        require(totalamountCredentialSubmitpayment == _balances[2] + _balances[3]);

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcIdentifier,
                true,
                _sequence,
                uint256(0),
                bytes32(0x0),
                Channels[_lcIdentifier].partyAddresses[0],
                Channels[_lcIdentifier].partyAddresses[1],
                _balances[0],
                _balances[1],
                _balances[2],
                _balances[3]
            )
        );

        require(Channels[_lcIdentifier].partyAddresses[0] == ECTools.healSigner(_state, _sigA));
        require(Channels[_lcIdentifier].partyAddresses[1] == ECTools.healSigner(_state, _sigI));

        Channels[_lcIdentifier].verifyOpen = false;

        if(_balances[0] != 0 || _balances[1] != 0) {
            Channels[_lcIdentifier].partyAddresses[0].transfer(_balances[0]);
            Channels[_lcIdentifier].partyAddresses[1].transfer(_balances[1]);
        }

        if(_balances[2] != 0 || _balances[3] != 0) {
            require(Channels[_lcIdentifier].credential.transfer(Channels[_lcIdentifier].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_lcIdentifier].credential.transfer(Channels[_lcIdentifier].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
        }

        numChannels--;

        emit DidLCClose(_lcIdentifier, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
    }


    function updaterecordsLCstate(
        bytes32 _lcIdentifier,
        uint256[6] updaterecordsParameters,
        bytes32 _VCroot,
        string _sigA,
        string _sigI
    )
        public
    {
        CommunicationChannel storage communicationChannel = Channels[_lcIdentifier];
        require(communicationChannel.verifyOpen);
        require(communicationChannel.sequence < updaterecordsParameters[0]);
        require(communicationChannel.ethAccountcreditsmap[0] + communicationChannel.ethAccountcreditsmap[1] >= updaterecordsParameters[2] + updaterecordsParameters[3]);
        require(communicationChannel.erc20Accountcreditsmap[0] + communicationChannel.erc20Accountcreditsmap[1] >= updaterecordsParameters[4] + updaterecordsParameters[5]);

        if(communicationChannel.isUpdaterecordsLcSettling == true) {
            require(communicationChannel.updaterecordsLCtimeout > now);
        }

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcIdentifier,
                false,
                updaterecordsParameters[0],
                updaterecordsParameters[1],
                _VCroot,
                communicationChannel.partyAddresses[0],
                communicationChannel.partyAddresses[1],
                updaterecordsParameters[2],
                updaterecordsParameters[3],
                updaterecordsParameters[4],
                updaterecordsParameters[5]
            )
        );

        require(communicationChannel.partyAddresses[0] == ECTools.healSigner(_state, _sigA));
        require(communicationChannel.partyAddresses[1] == ECTools.healSigner(_state, _sigI));


        communicationChannel.sequence = updaterecordsParameters[0];
        communicationChannel.numOpenVC = updaterecordsParameters[1];
        communicationChannel.ethAccountcreditsmap[0] = updaterecordsParameters[2];
        communicationChannel.ethAccountcreditsmap[1] = updaterecordsParameters[3];
        communicationChannel.erc20Accountcreditsmap[0] = updaterecordsParameters[4];
        communicationChannel.erc20Accountcreditsmap[1] = updaterecordsParameters[5];
        communicationChannel.VCrootChecksum = _VCroot;
        communicationChannel.isUpdaterecordsLcSettling = true;
        communicationChannel.updaterecordsLCtimeout = now + communicationChannel.confirmInstant;


        emit DidLcUpdaterecordsStatus (
            _lcIdentifier,
            updaterecordsParameters[0],
            updaterecordsParameters[1],
            updaterecordsParameters[2],
            updaterecordsParameters[3],
            updaterecordsParameters[4],
            updaterecordsParameters[5],
            _VCroot,
            communicationChannel.updaterecordsLCtimeout
        );
    }


    function initializesystemVCstate(
        bytes32 _lcIdentifier,
        bytes32 _vcCasenumber,
        bytes _proof,
        address _partyA,
        address _partyB,
        uint256[2] _bond,
        uint256[4] _balances,
        string sigA
    )
        public
    {
        require(Channels[_lcIdentifier].verifyOpen, "LC is closed.");

        require(!virtualChannels[_vcCasenumber].verifyClose, "VC is closed.");

        require(Channels[_lcIdentifier].updaterecordsLCtimeout < now, "LC timeout not over.");

        require(virtualChannels[_vcCasenumber].updaterecordsVCtimeout == 0);

        bytes32 _initializesystemStatus = keccak256(
            abi.encodePacked(_vcCasenumber, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
        );


        require(_partyA == ECTools.healSigner(_initializesystemStatus, sigA));


        require(_isContained(_initializesystemStatus, _proof, Channels[_lcIdentifier].VCrootChecksum) == true);

        virtualChannels[_vcCasenumber].partyA = _partyA;
        virtualChannels[_vcCasenumber].partyB = _partyB;
        virtualChannels[_vcCasenumber].sequence = uint256(0);
        virtualChannels[_vcCasenumber].ethAccountcreditsmap[0] = _balances[0];
        virtualChannels[_vcCasenumber].ethAccountcreditsmap[1] = _balances[1];
        virtualChannels[_vcCasenumber].erc20Accountcreditsmap[0] = _balances[2];
        virtualChannels[_vcCasenumber].erc20Accountcreditsmap[1] = _balances[3];
        virtualChannels[_vcCasenumber].bond = _bond;
        virtualChannels[_vcCasenumber].updaterecordsVCtimeout = now + Channels[_lcIdentifier].confirmInstant;
        virtualChannels[_vcCasenumber].isInSettlementStatus = true;

        emit DidVcInitializesystem(_lcIdentifier, _vcCasenumber, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
    }


    function modifytleVC(
        bytes32 _lcIdentifier,
        bytes32 _vcCasenumber,
        uint256 updaterecordsSeq,
        address _partyA,
        address _partyB,
        uint256[4] updaterecordsBal,
        string sigA
    )
        public
    {
        require(Channels[_lcIdentifier].verifyOpen, "LC is closed.");

        require(!virtualChannels[_vcCasenumber].verifyClose, "VC is closed.");
        require(virtualChannels[_vcCasenumber].sequence < updaterecordsSeq, "VC sequence is higher than update sequence.");
        require(
            virtualChannels[_vcCasenumber].ethAccountcreditsmap[1] < updaterecordsBal[1] && virtualChannels[_vcCasenumber].erc20Accountcreditsmap[1] < updaterecordsBal[3],
            "State updates may only increase recipient balance."
        );
        require(
            virtualChannels[_vcCasenumber].bond[0] == updaterecordsBal[0] + updaterecordsBal[1] &&
            virtualChannels[_vcCasenumber].bond[1] == updaterecordsBal[2] + updaterecordsBal[3],
            "Incorrect balances for bonded amount");


        require(Channels[_lcIdentifier].updaterecordsLCtimeout < now);

        bytes32 _updaterecordsCondition = keccak256(
            abi.encodePacked(
                _vcCasenumber,
                updaterecordsSeq,
                _partyA,
                _partyB,
                virtualChannels[_vcCasenumber].bond[0],
                virtualChannels[_vcCasenumber].bond[1],
                updaterecordsBal[0],
                updaterecordsBal[1],
                updaterecordsBal[2],
                updaterecordsBal[3]
            )
        );


        require(virtualChannels[_vcCasenumber].partyA == ECTools.healSigner(_updaterecordsCondition, sigA));


        virtualChannels[_vcCasenumber].challenger = msg.sender;
        virtualChannels[_vcCasenumber].sequence = updaterecordsSeq;


        virtualChannels[_vcCasenumber].ethAccountcreditsmap[0] = updaterecordsBal[0];
        virtualChannels[_vcCasenumber].ethAccountcreditsmap[1] = updaterecordsBal[1];
        virtualChannels[_vcCasenumber].erc20Accountcreditsmap[0] = updaterecordsBal[2];
        virtualChannels[_vcCasenumber].erc20Accountcreditsmap[1] = updaterecordsBal[3];

        virtualChannels[_vcCasenumber].updaterecordsVCtimeout = now + Channels[_lcIdentifier].confirmInstant;

        emit DidVCSettle(_lcIdentifier, _vcCasenumber, updaterecordsSeq, updaterecordsBal[0], updaterecordsBal[1], msg.sender, virtualChannels[_vcCasenumber].updaterecordsVCtimeout);
    }

    function closeVirtualChannel(bytes32 _lcIdentifier, bytes32 _vcCasenumber) public {

        require(Channels[_lcIdentifier].verifyOpen, "LC is closed.");
        require(virtualChannels[_vcCasenumber].isInSettlementStatus, "VC is not in settlement state.");
        require(virtualChannels[_vcCasenumber].updaterecordsVCtimeout < now, "Update vc timeout has not elapsed.");
        require(!virtualChannels[_vcCasenumber].verifyClose, "VC is already closed");

        Channels[_lcIdentifier].numOpenVC--;

        virtualChannels[_vcCasenumber].verifyClose = true;


        if(virtualChannels[_vcCasenumber].partyA == Channels[_lcIdentifier].partyAddresses[0]) {
            Channels[_lcIdentifier].ethAccountcreditsmap[0] += virtualChannels[_vcCasenumber].ethAccountcreditsmap[0];
            Channels[_lcIdentifier].ethAccountcreditsmap[1] += virtualChannels[_vcCasenumber].ethAccountcreditsmap[1];

            Channels[_lcIdentifier].erc20Accountcreditsmap[0] += virtualChannels[_vcCasenumber].erc20Accountcreditsmap[0];
            Channels[_lcIdentifier].erc20Accountcreditsmap[1] += virtualChannels[_vcCasenumber].erc20Accountcreditsmap[1];
        } else if (virtualChannels[_vcCasenumber].partyB == Channels[_lcIdentifier].partyAddresses[0]) {
            Channels[_lcIdentifier].ethAccountcreditsmap[0] += virtualChannels[_vcCasenumber].ethAccountcreditsmap[1];
            Channels[_lcIdentifier].ethAccountcreditsmap[1] += virtualChannels[_vcCasenumber].ethAccountcreditsmap[0];

            Channels[_lcIdentifier].erc20Accountcreditsmap[0] += virtualChannels[_vcCasenumber].erc20Accountcreditsmap[1];
            Channels[_lcIdentifier].erc20Accountcreditsmap[1] += virtualChannels[_vcCasenumber].erc20Accountcreditsmap[0];
        }

        emit DidVCClose(_lcIdentifier, _vcCasenumber, virtualChannels[_vcCasenumber].erc20Accountcreditsmap[0], virtualChannels[_vcCasenumber].erc20Accountcreditsmap[1]);
    }


    function byzantineCloseChannel(bytes32 _lcIdentifier) public {
        CommunicationChannel storage communicationChannel = Channels[_lcIdentifier];


        require(communicationChannel.verifyOpen, "Channel is not open");
        require(communicationChannel.isUpdaterecordsLcSettling == true);
        require(communicationChannel.numOpenVC == 0);
        require(communicationChannel.updaterecordsLCtimeout < now, "LC timeout over.");


        uint256 totalamountEthSubmitpayment = communicationChannel.initialSubmitpayment[0] + communicationChannel.ethAccountcreditsmap[2] + communicationChannel.ethAccountcreditsmap[3];
        uint256 totalamountCredentialSubmitpayment = communicationChannel.initialSubmitpayment[1] + communicationChannel.erc20Accountcreditsmap[2] + communicationChannel.erc20Accountcreditsmap[3];

        uint256 possibleTotalamountEthBeforeSubmitpayment = communicationChannel.ethAccountcreditsmap[0] + communicationChannel.ethAccountcreditsmap[1];
        uint256 possibleTotalamountCredentialBeforeSubmitpayment = communicationChannel.erc20Accountcreditsmap[0] + communicationChannel.erc20Accountcreditsmap[1];

        if(possibleTotalamountEthBeforeSubmitpayment < totalamountEthSubmitpayment) {
            communicationChannel.ethAccountcreditsmap[0]+=communicationChannel.ethAccountcreditsmap[2];
            communicationChannel.ethAccountcreditsmap[1]+=communicationChannel.ethAccountcreditsmap[3];
        } else {
            require(possibleTotalamountEthBeforeSubmitpayment == totalamountEthSubmitpayment);
        }

        if(possibleTotalamountCredentialBeforeSubmitpayment < totalamountCredentialSubmitpayment) {
            communicationChannel.erc20Accountcreditsmap[0]+=communicationChannel.erc20Accountcreditsmap[2];
            communicationChannel.erc20Accountcreditsmap[1]+=communicationChannel.erc20Accountcreditsmap[3];
        } else {
            require(possibleTotalamountCredentialBeforeSubmitpayment == totalamountCredentialSubmitpayment);
        }

        uint256 ethbalanceA = communicationChannel.ethAccountcreditsmap[0];
        uint256 ethbalanceI = communicationChannel.ethAccountcreditsmap[1];
        uint256 tokenbalanceA = communicationChannel.erc20Accountcreditsmap[0];
        uint256 tokenbalanceI = communicationChannel.erc20Accountcreditsmap[1];

        communicationChannel.ethAccountcreditsmap[0] = 0;
        communicationChannel.ethAccountcreditsmap[1] = 0;
        communicationChannel.erc20Accountcreditsmap[0] = 0;
        communicationChannel.erc20Accountcreditsmap[1] = 0;

        if(ethbalanceA != 0 || ethbalanceI != 0) {
            communicationChannel.partyAddresses[0].transfer(ethbalanceA);
            communicationChannel.partyAddresses[1].transfer(ethbalanceI);
        }

        if(tokenbalanceA != 0 || tokenbalanceI != 0) {
            require(
                communicationChannel.credential.transfer(communicationChannel.partyAddresses[0], tokenbalanceA),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                communicationChannel.credential.transfer(communicationChannel.partyAddresses[1], tokenbalanceI),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        communicationChannel.verifyOpen = false;
        numChannels--;

        emit DidLCClose(_lcIdentifier, communicationChannel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
    }

    function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
        bytes32 cursor = _hash;
        bytes32 verificationElem;

        for (uint256 i = 64; i <= _proof.length; i += 32) {
            assembly { verificationElem := mload(include(_proof, i)) }

            if (cursor < verificationElem) {
                cursor = keccak256(abi.encodePacked(cursor, verificationElem));
            } else {
                cursor = keccak256(abi.encodePacked(verificationElem, cursor));
            }
        }

        return cursor == _root;
    }


    function retrieveChannel(bytes32 id) public view returns (
        address[2],
        uint256[4],
        uint256[4],
        uint256[2],
        uint256,
        uint256,
        bytes32,
        uint256,
        uint256,
        bool,
        bool,
        uint256
    ) {
        CommunicationChannel memory communicationChannel = Channels[id];
        return (
            communicationChannel.partyAddresses,
            communicationChannel.ethAccountcreditsmap,
            communicationChannel.erc20Accountcreditsmap,
            communicationChannel.initialSubmitpayment,
            communicationChannel.sequence,
            communicationChannel.confirmInstant,
            communicationChannel.VCrootChecksum,
            communicationChannel.LCopenTimeout,
            communicationChannel.updaterecordsLCtimeout,
            communicationChannel.verifyOpen,
            communicationChannel.isUpdaterecordsLcSettling,
            communicationChannel.numOpenVC
        );
    }

    function obtainVirtualChannel(bytes32 id) public view returns(
        bool,
        bool,
        uint256,
        address,
        uint256,
        address,
        address,
        address,
        uint256[2],
        uint256[2],
        uint256[2]
    ) {
        VirtualChannel memory virtualChannel = virtualChannels[id];
        return(
            virtualChannel.verifyClose,
            virtualChannel.isInSettlementStatus,
            virtualChannel.sequence,
            virtualChannel.challenger,
            virtualChannel.updaterecordsVCtimeout,
            virtualChannel.partyA,
            virtualChannel.partyB,
            virtualChannel.partyI,
            virtualChannel.ethAccountcreditsmap,
            virtualChannel.erc20Accountcreditsmap,
            virtualChannel.bond
        );
    }
}