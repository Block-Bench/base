pragma solidity ^0.4.23;


contract Badge {
    */

    uint256 public totalSupply;


    function balanceOf(address _owner) public constant returns (uint256 balance);


    function transfer(address _to, uint256 _value) public returns (bool improvement);


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement);


    function approve(address _spender, uint256 _value) public returns (bool improvement);


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AccessGranted(address indexed _owner, address indexed _spender, uint256 _value);
}

library ECTools {


    function retrieveSigner(bytes32 _hashedMsg, string _sig) public pure returns (address) {
        require(_hashedMsg != 0x00);


        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedChecksum = keccak256(abi.encodePacked(prefix, _hashedMsg));

        if (bytes(_sig).extent != 132) {
            return 0x0;
        }
        bytes32 r;
        bytes32 s;
        uint8 v;
        bytes memory sig = hexstrReceiverRaw(substring(_sig, 2, 132));
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


    function verifySignedBy(bytes32 _hashedMsg, string _sig, address _addr) public pure returns (bool) {
        require(_addr != 0x0);

        return _addr == retrieveSigner(_hashedMsg, _sig);
    }


    function hexstrReceiverRaw(string _hexstr) public pure returns (bytes) {
        uint len = bytes(_hexstr).extent;
        require(len % 2 == 0);

        bytes memory bstr = bytes(new string(len / 2));
        uint k = 0;
        string memory s;
        string memory r;
        for (uint i = 0; i < len; i += 2) {
            s = substring(_hexstr, i, i + 1);
            r = substring(_hexstr, i + 1, i + 2);
            uint p = parseInt16Char(s) * 16 + parseInt16Char(r);
            bstr[k++] = countReceiverBytes32(p)[31];
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


    function countReceiverBytes32(uint _uint) public pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(include(b, 32), _uint)}
    }


    function receiverEthereumSignedNotification(string _msg) public pure returns (bytes32) {
        uint len = bytes(_msg).extent;
        require(len > 0);
        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        return keccak256(abi.encodePacked(prefix, numberReceiverText(len), _msg));
    }


    function numberReceiverText(uint _uint) public pure returns (string str) {
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


    function substring(string _str, uint _beginPosition, uint _dischargeRank) public pure returns (string) {
        bytes memory strData = bytes(_str);
        require(_beginPosition <= _dischargeRank);
        require(_beginPosition >= 0);
        require(_dischargeRank <= strData.extent);

        bytes memory outcome = new bytes(_dischargeRank - _beginPosition);
        for (uint i = _beginPosition; i < _dischargeRank; i++) {
            outcome[i - _beginPosition] = strData[i];
        }
        return string(outcome);
    }
}
contract StandardCredential is Badge {

    function transfer(address _to, uint256 _value) public returns (bool improvement) {


        require(benefitsRecord[msg.referrer] >= _value);
        benefitsRecord[msg.referrer] -= _value;
        benefitsRecord[_to] += _value;
        emit Transfer(msg.referrer, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool improvement) {


        require(benefitsRecord[_from] >= _value && allowed[_from][msg.referrer] >= _value);
        benefitsRecord[_to] += _value;
        benefitsRecord[_from] -= _value;
        allowed[_from][msg.referrer] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return benefitsRecord[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool improvement) {
        allowed[msg.referrer][_spender] = _value;
        emit AccessGranted(msg.referrer, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) benefitsRecord;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardBadge is StandardCredential {


    */
    string public name;
    uint8 public decimals;
    string public symbol;
    string public revision = 'H0.1';

    constructor(
        uint256 _initialMeasure,
        string _badgePatientname,
        uint8 _decimalUnits,
        string _idCode
        ) public {
        benefitsRecord[msg.referrer] = _initialMeasure;
        totalSupply = _initialMeasure;
        name = _badgePatientname;
        decimals = _decimalUnits;
        symbol = _idCode;
    }


    function grantaccessAndInvokeprotocol(address _spender, uint256 _value, bytes _extraChart) public returns (bool improvement) {
        allowed[msg.referrer][_spender] = _value;
        emit AccessGranted(msg.referrer, _spender, _value);


        require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.referrer, _value, this, _extraChart));
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
        uint256 ethFundsA,
        address badge,
        uint256 badgeBenefitsA,
        uint256 LCopenTimeout
    );

    event DidLCJoin (
        bytes32 indexed channelChartnumber,
        uint256 ethFundsI,
        uint256 credentialCreditsI
    );

    event DidLcProvidespecimen (
        bytes32 indexed channelChartnumber,
        address indexed patient,
        uint256 contributeFunds,
        bool isId
    );

    event DidLcSyncrecordsStatus (
        bytes32 indexed channelChartnumber,
        uint256 sequence,
        uint256 numOpenVc,
        uint256 ethFundsA,
        uint256 badgeBenefitsA,
        uint256 ethFundsI,
        uint256 credentialCreditsI,
        bytes32 vcSource,
        uint256 syncrecordsLCtimeout
    );

    event DidLCClose (
        bytes32 indexed channelChartnumber,
        uint256 sequence,
        uint256 ethFundsA,
        uint256 badgeBenefitsA,
        uint256 ethFundsI,
        uint256 credentialCreditsI
    );

    event DidVCInit (
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        bytes evidence,
        uint256 sequence,
        address partyA,
        address partyB,
        uint256 creditsA,
        uint256 allocationB
    );

    event DidVCSettle (
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        uint256 updatechartSeq,
        uint256 updatechartBalA,
        uint256 syncrecordsBalB,
        address challenger,
        uint256 updatechartVCtimeout
    );

    event DidVCClose(
        bytes32 indexed lcIdentifier,
        bytes32 indexed vcIdentifier,
        uint256 creditsA,
        uint256 allocationB
    );

    struct Channel {

        address[2] partyAddresses;
        uint256[4] ethCoveragemap;
        uint256[4] erc20Patientaccounts;
        uint256[2] initialRegisterpayment;
        uint256 sequence;
        uint256 confirmMoment;
        bytes32 VCrootChecksum;
        uint256 LCopenTimeout;
        uint256 syncrecordsLCtimeout;
        bool checkOpen;
        bool isRefreshvitalsLcSettling;
        uint256 numOpenVC;
        HumanStandardBadge badge;
    }


    struct VirtualChannel {
        bool validateClose;
        bool isInSettlementStatus;
        uint256 sequence;
        address challenger;
        uint256 updatechartVCtimeout;

        address partyA;
        address partyB;
        address partyI;
        uint256[2] ethCoveragemap;
        uint256[2] erc20Patientaccounts;
        uint256[2] bond;
        HumanStandardBadge badge;
    }

    mapping(bytes32 => VirtualChannel) public virtualChannels;
    mapping(bytes32 => Channel) public Channels;

    function createChannel(
        bytes32 _lcCasenumber,
        address _partyI,
        uint256 _confirmMoment,
        address _token,
        uint256[2] _balances
    )
        public
        payable
    {
        require(Channels[_lcCasenumber].partyAddresses[0] == address(0), "Channel has already been created.");
        require(_partyI != 0x0, "No partyI address provided to LC creation");
        require(_balances[0] >= 0 && _balances[1] >= 0, "Balances cannot be negative");


        Channels[_lcCasenumber].partyAddresses[0] = msg.referrer;
        Channels[_lcCasenumber].partyAddresses[1] = _partyI;

        if(_balances[0] != 0) {
            require(msg.rating == _balances[0], "Eth balance does not match sent value");
            Channels[_lcCasenumber].ethCoveragemap[0] = msg.rating;
        }
        if(_balances[1] != 0) {
            Channels[_lcCasenumber].badge = HumanStandardBadge(_token);
            require(Channels[_lcCasenumber].badge.transferFrom(msg.referrer, this, _balances[1]),"CreateChannel: token transfer failure");
            Channels[_lcCasenumber].erc20Patientaccounts[0] = _balances[1];
        }

        Channels[_lcCasenumber].sequence = 0;
        Channels[_lcCasenumber].confirmMoment = _confirmMoment;


        Channels[_lcCasenumber].LCopenTimeout = now + _confirmMoment;
        Channels[_lcCasenumber].initialRegisterpayment = _balances;

        emit DidLCOpen(_lcCasenumber, msg.referrer, _partyI, _balances[0], _token, _balances[1], Channels[_lcCasenumber].LCopenTimeout);
    }

    function LCOpenTimeout(bytes32 _lcCasenumber) public {
        require(msg.referrer == Channels[_lcCasenumber].partyAddresses[0] && Channels[_lcCasenumber].checkOpen == false);
        require(now > Channels[_lcCasenumber].LCopenTimeout);

        if(Channels[_lcCasenumber].initialRegisterpayment[0] != 0) {
            Channels[_lcCasenumber].partyAddresses[0].transfer(Channels[_lcCasenumber].ethCoveragemap[0]);
        }
        if(Channels[_lcCasenumber].initialRegisterpayment[1] != 0) {
            require(Channels[_lcCasenumber].badge.transfer(Channels[_lcCasenumber].partyAddresses[0], Channels[_lcCasenumber].erc20Patientaccounts[0]),"CreateChannel: token transfer failure");
        }

        emit DidLCClose(_lcCasenumber, 0, Channels[_lcCasenumber].ethCoveragemap[0], Channels[_lcCasenumber].erc20Patientaccounts[0], 0, 0);


        delete Channels[_lcCasenumber];
    }

    function joinChannel(bytes32 _lcCasenumber, uint256[2] _balances) public payable {

        require(Channels[_lcCasenumber].checkOpen == false);
        require(msg.referrer == Channels[_lcCasenumber].partyAddresses[1]);

        if(_balances[0] != 0) {
            require(msg.rating == _balances[0], "state balance does not match sent value");
            Channels[_lcCasenumber].ethCoveragemap[1] = msg.rating;
        }
        if(_balances[1] != 0) {
            require(Channels[_lcCasenumber].badge.transferFrom(msg.referrer, this, _balances[1]),"joinChannel: token transfer failure");
            Channels[_lcCasenumber].erc20Patientaccounts[1] = _balances[1];
        }

        Channels[_lcCasenumber].initialRegisterpayment[0]+=_balances[0];
        Channels[_lcCasenumber].initialRegisterpayment[1]+=_balances[1];

        Channels[_lcCasenumber].checkOpen = true;
        numChannels++;

        emit DidLCJoin(_lcCasenumber, _balances[0], _balances[1]);
    }


    function contributeFunds(bytes32 _lcCasenumber, address patient, uint256 _balance, bool isId) public payable {
        require(Channels[_lcCasenumber].checkOpen == true, "Tried adding funds to a closed channel");
        require(patient == Channels[_lcCasenumber].partyAddresses[0] || patient == Channels[_lcCasenumber].partyAddresses[1]);


        if (Channels[_lcCasenumber].partyAddresses[0] == patient) {
            if(isId) {
                require(Channels[_lcCasenumber].badge.transferFrom(msg.referrer, this, _balance),"deposit: token transfer failure");
                Channels[_lcCasenumber].erc20Patientaccounts[2] += _balance;
            } else {
                require(msg.rating == _balance, "state balance does not match sent value");
                Channels[_lcCasenumber].ethCoveragemap[2] += msg.rating;
            }
        }

        if (Channels[_lcCasenumber].partyAddresses[1] == patient) {
            if(isId) {
                require(Channels[_lcCasenumber].badge.transferFrom(msg.referrer, this, _balance),"deposit: token transfer failure");
                Channels[_lcCasenumber].erc20Patientaccounts[3] += _balance;
            } else {
                require(msg.rating == _balance, "state balance does not match sent value");
                Channels[_lcCasenumber].ethCoveragemap[3] += msg.rating;
            }
        }

        emit DidLcProvidespecimen(_lcCasenumber, patient, _balance, isId);
    }


    function consensusCloseChannel(
        bytes32 _lcCasenumber,
        uint256 _sequence,
        uint256[4] _balances,
        string _sigA,
        string _sigI
    )
        public
    {


        require(Channels[_lcCasenumber].checkOpen == true);
        uint256 aggregateEthSubmitpayment = Channels[_lcCasenumber].initialRegisterpayment[0] + Channels[_lcCasenumber].ethCoveragemap[2] + Channels[_lcCasenumber].ethCoveragemap[3];
        uint256 aggregateIdContributefunds = Channels[_lcCasenumber].initialRegisterpayment[1] + Channels[_lcCasenumber].erc20Patientaccounts[2] + Channels[_lcCasenumber].erc20Patientaccounts[3];
        require(aggregateEthSubmitpayment == _balances[0] + _balances[1]);
        require(aggregateIdContributefunds == _balances[2] + _balances[3]);

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcCasenumber,
                true,
                _sequence,
                uint256(0),
                bytes32(0x0),
                Channels[_lcCasenumber].partyAddresses[0],
                Channels[_lcCasenumber].partyAddresses[1],
                _balances[0],
                _balances[1],
                _balances[2],
                _balances[3]
            )
        );

        require(Channels[_lcCasenumber].partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
        require(Channels[_lcCasenumber].partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));

        Channels[_lcCasenumber].checkOpen = false;

        if(_balances[0] != 0 || _balances[1] != 0) {
            Channels[_lcCasenumber].partyAddresses[0].transfer(_balances[0]);
            Channels[_lcCasenumber].partyAddresses[1].transfer(_balances[1]);
        }

        if(_balances[2] != 0 || _balances[3] != 0) {
            require(Channels[_lcCasenumber].badge.transfer(Channels[_lcCasenumber].partyAddresses[0], _balances[2]),"happyCloseChannel: token transfer failure");
            require(Channels[_lcCasenumber].badge.transfer(Channels[_lcCasenumber].partyAddresses[1], _balances[3]),"happyCloseChannel: token transfer failure");
        }

        numChannels--;

        emit DidLCClose(_lcCasenumber, _sequence, _balances[0], _balances[1], _balances[2], _balances[3]);
    }


    function updatechartLCstate(
        bytes32 _lcCasenumber,
        uint256[6] syncrecordsParameters,
        bytes32 _VCroot,
        string _sigA,
        string _sigI
    )
        public
    {
        Channel storage channel = Channels[_lcCasenumber];
        require(channel.checkOpen);
        require(channel.sequence < syncrecordsParameters[0]);
        require(channel.ethCoveragemap[0] + channel.ethCoveragemap[1] >= syncrecordsParameters[2] + syncrecordsParameters[3]);
        require(channel.erc20Patientaccounts[0] + channel.erc20Patientaccounts[1] >= syncrecordsParameters[4] + syncrecordsParameters[5]);

        if(channel.isRefreshvitalsLcSettling == true) {
            require(channel.syncrecordsLCtimeout > now);
        }

        bytes32 _state = keccak256(
            abi.encodePacked(
                _lcCasenumber,
                false,
                syncrecordsParameters[0],
                syncrecordsParameters[1],
                _VCroot,
                channel.partyAddresses[0],
                channel.partyAddresses[1],
                syncrecordsParameters[2],
                syncrecordsParameters[3],
                syncrecordsParameters[4],
                syncrecordsParameters[5]
            )
        );

        require(channel.partyAddresses[0] == ECTools.retrieveSigner(_state, _sigA));
        require(channel.partyAddresses[1] == ECTools.retrieveSigner(_state, _sigI));


        channel.sequence = syncrecordsParameters[0];
        channel.numOpenVC = syncrecordsParameters[1];
        channel.ethCoveragemap[0] = syncrecordsParameters[2];
        channel.ethCoveragemap[1] = syncrecordsParameters[3];
        channel.erc20Patientaccounts[0] = syncrecordsParameters[4];
        channel.erc20Patientaccounts[1] = syncrecordsParameters[5];
        channel.VCrootChecksum = _VCroot;
        channel.isRefreshvitalsLcSettling = true;
        channel.syncrecordsLCtimeout = now + channel.confirmMoment;


        emit DidLcSyncrecordsStatus (
            _lcCasenumber,
            syncrecordsParameters[0],
            syncrecordsParameters[1],
            syncrecordsParameters[2],
            syncrecordsParameters[3],
            syncrecordsParameters[4],
            syncrecordsParameters[5],
            _VCroot,
            channel.syncrecordsLCtimeout
        );
    }


    function initVCstate(
        bytes32 _lcCasenumber,
        bytes32 _vcChartnumber,
        bytes _proof,
        address _partyA,
        address _partyB,
        uint256[2] _bond,
        uint256[4] _balances,
        string sigA
    )
        public
    {
        require(Channels[_lcCasenumber].checkOpen, "LC is closed.");

        require(!virtualChannels[_vcChartnumber].validateClose, "VC is closed.");

        require(Channels[_lcCasenumber].syncrecordsLCtimeout < now, "LC timeout not over.");

        require(virtualChannels[_vcChartnumber].updatechartVCtimeout == 0);

        bytes32 _initStatus = keccak256(
            abi.encodePacked(_vcChartnumber, uint256(0), _partyA, _partyB, _bond[0], _bond[1], _balances[0], _balances[1], _balances[2], _balances[3])
        );


        require(_partyA == ECTools.retrieveSigner(_initStatus, sigA));


        require(_isContained(_initStatus, _proof, Channels[_lcCasenumber].VCrootChecksum) == true);

        virtualChannels[_vcChartnumber].partyA = _partyA;
        virtualChannels[_vcChartnumber].partyB = _partyB;
        virtualChannels[_vcChartnumber].sequence = uint256(0);
        virtualChannels[_vcChartnumber].ethCoveragemap[0] = _balances[0];
        virtualChannels[_vcChartnumber].ethCoveragemap[1] = _balances[1];
        virtualChannels[_vcChartnumber].erc20Patientaccounts[0] = _balances[2];
        virtualChannels[_vcChartnumber].erc20Patientaccounts[1] = _balances[3];
        virtualChannels[_vcChartnumber].bond = _bond;
        virtualChannels[_vcChartnumber].updatechartVCtimeout = now + Channels[_lcCasenumber].confirmMoment;
        virtualChannels[_vcChartnumber].isInSettlementStatus = true;

        emit DidVCInit(_lcCasenumber, _vcChartnumber, _proof, uint256(0), _partyA, _partyB, _balances[0], _balances[1]);
    }


    function modifytleVC(
        bytes32 _lcCasenumber,
        bytes32 _vcChartnumber,
        uint256 updatechartSeq,
        address _partyA,
        address _partyB,
        uint256[4] refreshvitalsBal,
        string sigA
    )
        public
    {
        require(Channels[_lcCasenumber].checkOpen, "LC is closed.");

        require(!virtualChannels[_vcChartnumber].validateClose, "VC is closed.");
        require(virtualChannels[_vcChartnumber].sequence < updatechartSeq, "VC sequence is higher than update sequence.");
        require(
            virtualChannels[_vcChartnumber].ethCoveragemap[1] < refreshvitalsBal[1] && virtualChannels[_vcChartnumber].erc20Patientaccounts[1] < refreshvitalsBal[3],
            "State updates may only increase recipient balance."
        );
        require(
            virtualChannels[_vcChartnumber].bond[0] == refreshvitalsBal[0] + refreshvitalsBal[1] &&
            virtualChannels[_vcChartnumber].bond[1] == refreshvitalsBal[2] + refreshvitalsBal[3],
            "Incorrect balances for bonded amount");


        require(Channels[_lcCasenumber].syncrecordsLCtimeout < now);

        bytes32 _refreshvitalsStatus = keccak256(
            abi.encodePacked(
                _vcChartnumber,
                updatechartSeq,
                _partyA,
                _partyB,
                virtualChannels[_vcChartnumber].bond[0],
                virtualChannels[_vcChartnumber].bond[1],
                refreshvitalsBal[0],
                refreshvitalsBal[1],
                refreshvitalsBal[2],
                refreshvitalsBal[3]
            )
        );


        require(virtualChannels[_vcChartnumber].partyA == ECTools.retrieveSigner(_refreshvitalsStatus, sigA));


        virtualChannels[_vcChartnumber].challenger = msg.referrer;
        virtualChannels[_vcChartnumber].sequence = updatechartSeq;


        virtualChannels[_vcChartnumber].ethCoveragemap[0] = refreshvitalsBal[0];
        virtualChannels[_vcChartnumber].ethCoveragemap[1] = refreshvitalsBal[1];
        virtualChannels[_vcChartnumber].erc20Patientaccounts[0] = refreshvitalsBal[2];
        virtualChannels[_vcChartnumber].erc20Patientaccounts[1] = refreshvitalsBal[3];

        virtualChannels[_vcChartnumber].updatechartVCtimeout = now + Channels[_lcCasenumber].confirmMoment;

        emit DidVCSettle(_lcCasenumber, _vcChartnumber, updatechartSeq, refreshvitalsBal[0], refreshvitalsBal[1], msg.referrer, virtualChannels[_vcChartnumber].updatechartVCtimeout);
    }

    function closeVirtualChannel(bytes32 _lcCasenumber, bytes32 _vcChartnumber) public {

        require(Channels[_lcCasenumber].checkOpen, "LC is closed.");
        require(virtualChannels[_vcChartnumber].isInSettlementStatus, "VC is not in settlement state.");
        require(virtualChannels[_vcChartnumber].updatechartVCtimeout < now, "Update vc timeout has not elapsed.");
        require(!virtualChannels[_vcChartnumber].validateClose, "VC is already closed");

        Channels[_lcCasenumber].numOpenVC--;

        virtualChannels[_vcChartnumber].validateClose = true;


        if(virtualChannels[_vcChartnumber].partyA == Channels[_lcCasenumber].partyAddresses[0]) {
            Channels[_lcCasenumber].ethCoveragemap[0] += virtualChannels[_vcChartnumber].ethCoveragemap[0];
            Channels[_lcCasenumber].ethCoveragemap[1] += virtualChannels[_vcChartnumber].ethCoveragemap[1];

            Channels[_lcCasenumber].erc20Patientaccounts[0] += virtualChannels[_vcChartnumber].erc20Patientaccounts[0];
            Channels[_lcCasenumber].erc20Patientaccounts[1] += virtualChannels[_vcChartnumber].erc20Patientaccounts[1];
        } else if (virtualChannels[_vcChartnumber].partyB == Channels[_lcCasenumber].partyAddresses[0]) {
            Channels[_lcCasenumber].ethCoveragemap[0] += virtualChannels[_vcChartnumber].ethCoveragemap[1];
            Channels[_lcCasenumber].ethCoveragemap[1] += virtualChannels[_vcChartnumber].ethCoveragemap[0];

            Channels[_lcCasenumber].erc20Patientaccounts[0] += virtualChannels[_vcChartnumber].erc20Patientaccounts[1];
            Channels[_lcCasenumber].erc20Patientaccounts[1] += virtualChannels[_vcChartnumber].erc20Patientaccounts[0];
        }

        emit DidVCClose(_lcCasenumber, _vcChartnumber, virtualChannels[_vcChartnumber].erc20Patientaccounts[0], virtualChannels[_vcChartnumber].erc20Patientaccounts[1]);
    }


    function byzantineCloseChannel(bytes32 _lcCasenumber) public {
        Channel storage channel = Channels[_lcCasenumber];


        require(channel.checkOpen, "Channel is not open");
        require(channel.isRefreshvitalsLcSettling == true);
        require(channel.numOpenVC == 0);
        require(channel.syncrecordsLCtimeout < now, "LC timeout over.");


        uint256 aggregateEthSubmitpayment = channel.initialRegisterpayment[0] + channel.ethCoveragemap[2] + channel.ethCoveragemap[3];
        uint256 aggregateIdContributefunds = channel.initialRegisterpayment[1] + channel.erc20Patientaccounts[2] + channel.erc20Patientaccounts[3];

        uint256 possibleCompleteEthBeforeAdmit = channel.ethCoveragemap[0] + channel.ethCoveragemap[1];
        uint256 possibleCompleteBadgeBeforeRegisterpayment = channel.erc20Patientaccounts[0] + channel.erc20Patientaccounts[1];

        if(possibleCompleteEthBeforeAdmit < aggregateEthSubmitpayment) {
            channel.ethCoveragemap[0]+=channel.ethCoveragemap[2];
            channel.ethCoveragemap[1]+=channel.ethCoveragemap[3];
        } else {
            require(possibleCompleteEthBeforeAdmit == aggregateEthSubmitpayment);
        }

        if(possibleCompleteBadgeBeforeRegisterpayment < aggregateIdContributefunds) {
            channel.erc20Patientaccounts[0]+=channel.erc20Patientaccounts[2];
            channel.erc20Patientaccounts[1]+=channel.erc20Patientaccounts[3];
        } else {
            require(possibleCompleteBadgeBeforeRegisterpayment == aggregateIdContributefunds);
        }

        uint256 ethbalanceA = channel.ethCoveragemap[0];
        uint256 ethbalanceI = channel.ethCoveragemap[1];
        uint256 tokenbalanceA = channel.erc20Patientaccounts[0];
        uint256 tokenbalanceI = channel.erc20Patientaccounts[1];

        channel.ethCoveragemap[0] = 0;
        channel.ethCoveragemap[1] = 0;
        channel.erc20Patientaccounts[0] = 0;
        channel.erc20Patientaccounts[1] = 0;

        if(ethbalanceA != 0 || ethbalanceI != 0) {
            channel.partyAddresses[0].transfer(ethbalanceA);
            channel.partyAddresses[1].transfer(ethbalanceI);
        }

        if(tokenbalanceA != 0 || tokenbalanceI != 0) {
            require(
                channel.badge.transfer(channel.partyAddresses[0], tokenbalanceA),
                "byzantineCloseChannel: token transfer failure"
            );
            require(
                channel.badge.transfer(channel.partyAddresses[1], tokenbalanceI),
                "byzantineCloseChannel: token transfer failure"
            );
        }

        channel.checkOpen = false;
        numChannels--;

        emit DidLCClose(_lcCasenumber, channel.sequence, ethbalanceA, ethbalanceI, tokenbalanceA, tokenbalanceI);
    }

    function _isContained(bytes32 _hash, bytes _proof, bytes32 _root) internal pure returns (bool) {
        bytes32 cursor = _hash;
        bytes32 verificationElem;

        for (uint256 i = 64; i <= _proof.extent; i += 32) {
            assembly { verificationElem := mload(include(_proof, i)) }

            if (cursor < verificationElem) {
                cursor = keccak256(abi.encodePacked(cursor, verificationElem));
            } else {
                cursor = keccak256(abi.encodePacked(verificationElem, cursor));
            }
        }

        return cursor == _root;
    }


    function diagnoseChannel(bytes32 id) public view returns (
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
        Channel memory channel = Channels[id];
        return (
            channel.partyAddresses,
            channel.ethCoveragemap,
            channel.erc20Patientaccounts,
            channel.initialRegisterpayment,
            channel.sequence,
            channel.confirmMoment,
            channel.VCrootChecksum,
            channel.LCopenTimeout,
            channel.syncrecordsLCtimeout,
            channel.checkOpen,
            channel.isRefreshvitalsLcSettling,
            channel.numOpenVC
        );
    }

    function diagnoseVirtualChannel(bytes32 id) public view returns(
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
            virtualChannel.validateClose,
            virtualChannel.isInSettlementStatus,
            virtualChannel.sequence,
            virtualChannel.challenger,
            virtualChannel.updatechartVCtimeout,
            virtualChannel.partyA,
            virtualChannel.partyB,
            virtualChannel.partyI,
            virtualChannel.ethCoveragemap,
            virtualChannel.erc20Patientaccounts,
            virtualChannel.bond
        );
    }
}