pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./Election.sol";
import './Library.sol';
import './strings.sol';

contract ElectionFactory {
  using strings for *;

  address[] public elections;

  constructor () public {
  }

  event electionCreated(address addr, string owner);
  event closedElection(address addr, string owner);
  event votedEvent(address addr);

  function getImgs(string _cImg) public pure returns (string[]) {
    strings.slice memory s = _cImg.toSlice();
    strings.slice memory delim = "|".toSlice();
    string[] memory parts = new string[](s.count(delim) + 1);
    for (uint i = 0; i < parts.length; i++) {
      parts[i] = s.split(delim).toString();
    }
    return parts;
  }

  function createElection (
    bytes32[3] _content, bytes _imgURL, bool[2] _setup,
    bytes32[] _candidates,
    string _cImg,
    bytes32[] _candidatesDescription,
    bytes32[] voters, uint[2] _start_end
  ) public {
    address addr = new Election(
      _content, _imgURL, _setup,
      _candidates, getImgs(_cImg), _candidatesDescription,
      voters, _start_end);
    elections.push(addr);

    emit electionCreated(addr, Library.bytes32ToStr(_content[0]));
  }

  function getSize() public view returns (uint) {
    return elections.length;
  }

  function getTitle(address addr) public view returns (string) {
    Election e = Election(addr);

    return e.getTitle();
  }
  function getContent(address addr) public view returns (string, string, string) {
    Election e = Election(addr);

    return (e.getTitle(), e.getImgURL(), e.getDescription());
  }
  function getOwner(address addr) public view returns (string) {
    Election e = Election(addr);

    return e.getOwner();
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

  function getCandidate(address addr, uint i) public view returns (uint, string, string, string, uint) {
    Election e = Election(addr);

    return (i, e.getCandidateName(i), e.getCandidateImgURL(i), e.getCandidateDescription(i), e.getCandidateVoteCount(i));
  }

  function vote(address addr, bytes32 _email, uint _candidateId) public {
    Election e = Election(addr);

    e.vote(_email, _candidateId);

    emit votedEvent(addr);
  }

  function close(address addr, bytes32 _email) public {
    Election e = Election(addr);

    e.close(_email);

    emit closedElection(addr, Library.bytes32ToStr(_email));
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
