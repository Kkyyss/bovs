pragma solidity ^0.4.24;

import "./Election.sol";
import './Type.sol';

contract ElectionFactory {
  address[] public elections;

  constructor () public {
  }

  event electionCreated(address addr, string owner);
  event closedElection(address addr, string owner);
  event votedEvent(address addr);

  function createElection (
    bytes32 owner, bytes title, bool _public,
    bytes32[] candidates, bytes32[] voters,
    bool manual, uint start, uint end
  ) public {
    address addr = new Election(owner, title, _public, candidates, voters, manual, start, end);
    elections.push(addr);

    emit electionCreated(addr, Type.bytes32ToStr(owner));
  }

  function getSize() public view returns (uint) {
    return elections.length;
  }

  function getTitle(address addr) public view returns (string) {
    Election e = Election(addr);

    return string(e.getTitle());
  }
  function getOwner(address addr) public view returns (string) {
    Election e = Election(addr);

    return string(e.getOwner());
  }
  function getCandidateSize(address addr) public view returns (uint) {
    Election e = Election(addr);

    return e.candSize();
  }
  function getVoterSize(address addr) public view returns (uint) {
    Election e = Election(addr);

    return e.votrSize();
  }
  function getVoterElectionAddress(bytes32 _email, uint i) public view returns (address, bool) {
    Election e = Election(elections[i]);

    if (e.getMode() == 1) {
      return (elections[i], true);
    }

    if (e.isVoter(_email)) {
      return (elections[i], true);
    }
    return (0, false);
  }
  function getOwnerElectionAddress(bytes32 _email, uint i) public view returns (address, bool) {
    Election e = Election(elections[i]);

    if (e.isOwner(_email)) {
      return (elections[i], true);
    }
    return (0, false);
  }
  function isVoted(address addr, bytes32 _email) public view returns (bool) {
    Election e = Election(addr);

    return e.isVoted(_email);
  }
  function getVotedTo(address addr, bytes32 _email) public view returns (string) {
    Election e = Election(addr);

    return e.getVotedTo(_email);
  }

  function getCandidate(address addr, uint i) public view returns (uint, string, uint) {
    Election e = Election(addr);

    return (i, e.getCandidateName(i), e.getCandidateVoteCount(i));
  }

  function vote(address addr, bytes32 _email, uint _candidateId) public {
    Election e = Election(addr);

    e.vote(_email, _candidateId);

    emit votedEvent(addr);
  }

  function close(address addr, bytes32 _email) public {
    Election e = Election(addr);

    e.close(_email);

    emit closedElection(addr, Type.bytes32ToStr(_email));
  }
  function getStartDate(address addr) public view returns (uint) {
    Election e = Election(addr);

    return e.getStartDate();
  }
  function getEndDate(address addr) public view returns (uint) {
    Election e = Election(addr);

    return e.getEndDate();
  }
  function getMode(address addr) public view returns (uint) {
    Election e = Election(addr);

    return e.getMode();
  }
}
