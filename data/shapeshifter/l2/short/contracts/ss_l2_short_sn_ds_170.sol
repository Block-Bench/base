// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

/// @author Jordi Baylina
/// Auditors: Griff Green & psdev
/// @notice Based on http://hudsonjameson.com/ethereummarriage/
/// License: GNU-3

/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier o() {
        require(msg.sender == ab);
        _;
    }

    address public ab;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        ab = msg.sender;
    }

    address public u;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner
    ///  an unowned neutral vault, however that cannot be undone
    function j(address m) o {
        u = m;
    }
    /// @notice `newOwner` has to accept the ownership before it is transferred
    ///  Any account or any contract with the ability to call `acceptOwnership`
    ///  can be used to accept ownership of this contract, including a contract
    ///  with no other functions
    function c() {
        if (msg.sender == u) {
            ab = u;
        }
    }

    // This is a general safty function that allows the owner to do a lot
    //  of things in the unlikely event that something goes wrong
    // _dst is the contract being called making this like a 1/1 multisig
    function v(address ah, uint w, bytes z) o {
        ah.call.value(w)(z);
    }
}

contract Marriage is Owned
{
    // Marriage data variables
    string public q;
    string public s;
    uint public f;
    string public e;
    string public ae;

    Event[] public h;
    Message[] public r;

    struct Event {
        uint af;
        string ac;
        string g;
        string ai;
    }

    struct Message {
        uint af;
        string t;
        string ad;
        string ai;
        uint value;
    }

    modifier k {
        require(ag(e) == ag("Married"));
        _;
    }

    //Set Owner
    function Marriage(address y) {
        ab = y;
    }

    function a() constant public returns (uint) {
        return h.length;
    }

    function b() constant public returns (uint) {
        return r.length;
    }

    // Create initial marriage contract
    function d(
        string l,
        string n,
        string aa,
        string ai) o
    {
        require(h.length == 0);
        q = l;
        s = n;
        f = aj;
        ae = aa;
        e = "Married";
        h.push(Event(aj, "Marriage", ae, ai));
        MajorEvent("Marrigage", ae, ai);
    }

    // Set the marriage status if it changes
    function p(string x, string ai) o
    {
        e = x;
        setMajorEvent("Changed Status", x, ai);
    }

    // Set the IPFS hash of the image of the couple
    function setMajorEvent(string ac, string g, string ai) o k
    {
        h.push(Event(aj, ac, g, ai));
        MajorEvent(ac, g, ai);
    }

    function i(string t, string ad, string ai) payable k {
        if (msg.value > 0) {
            ab.transfer(this.balance);
        }
        r.push(Message(aj, t, ad, ai, msg.value));
        MessageSent(t, ad, ai, msg.value);
    }

    // Declare event structure
    event MajorEvent(string ac, string g, string ai);
    event MessageSent(string ac, string g, string ai, uint value);
}