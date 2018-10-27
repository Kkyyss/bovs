pragma solidity ^0.4.24;

import "./Type.sol";

contract Election {
  mapping(bytes32 => uint) public ownerId;
  bytes32 private owner;
  bytes private title;
  bool private manual;
  uint private startDate;
  uint private endDate;
  uint public candSize;
  uint public votrSize;
  Status private status;
  Mode private mode;

  enum Status { Start, Closed, Pending }
  enum Mode { Private, Public }

  mapping(uint => Candidate) private candidates;
  mapping(bytes32 => Voter) private voters;
  mapping(bytes32 => uint) private voterId;
  mapping(bytes32 => uint) private votedTo;
  mapping(bytes32 => uint) private pubVoterId;

  struct Candidate {
    uint id;
    string name;
    uint voteCount;
  }

  struct Voter {
    uint id;
    string email;
    bool voted;
  }

  constructor (
    bytes32 _owner, bytes _title, bool _public,
    bytes32[] _candidates, bytes32[] _voters,
    bool _manual, bool _startNow, uint _start, uint _end
  ) public {
    ownerId[_owner] = 1;
    owner = _owner;
    title = _title;
    manual = _manual;
    if (!manual) {
      startDate = _start;
      endDate = _end;
    }
    addCandidates(_candidates);

    if (!_public) {
      mode = Mode.Private;
      addVoters(_voters);
    } else {
      mode = Mode.Public;
    }

    status = Status.Pending;
    if (_startNow) {
      if (manual) {
        status = Status.Start;
      }
      startDate = now;
    }
  }

  function addCandidates(bytes32[] _names) private {
    candSize = _names.length;

    for (uint i = 0; i < candSize; i++) {
      candidates[i] = Candidate(i, Type.bytes32ToStr(_names[i]), 0);
    }
  }

  function addVoters(bytes32[] _emails) private {
    votrSize = _emails.length;

    for (uint i = 0; i < votrSize; i++) {
      voterId[_emails[i]] = i + 1;
      voters[_emails[i]] = Voter(i, Type.bytes32ToStr(_emails[i]), false);
    }
  }
  function isVoter(bytes32 _email) public view returns (bool) {
    return (voterId[_email] != 0);
  }
  function isOwner(bytes32 _email) public view returns (bool) {
    return (ownerId[_email] != 0);
  }
  function isVoted(bytes32 _email) public view returns (bool) {
    return (voters[_email].voted);
  }
  function getVotedTo(bytes32 _email) public view returns (string) {
    return (candidates[votedTo[_email]].name);
  }

  function vote (bytes32 _email, uint _candidateId) public {
    if (mode == Mode.Private) {
      require(voterId[_email] != 0);
    } else {
      if (voterId[_email] == 0) {
        voters[_email] = Voter(votrSize, Type.bytes32ToStr(_email), false);
        votrSize++;
      }
    }

    if (!manual) {
      // Due date
      require(now < endDate);
    } else {
      // Event manually closed
      require(status == Status.Start);
    }

    // require that they haven't voted before
    require(!voters[_email].voted);

    // require a valid candidate
    require(_candidateId >= 0 && _candidateId < candSize);

    // record the voter has voted
    voters[_email].voted = true;

    // update the voter vote to
    votedTo[_email] = _candidateId;

    // update candidate vote Count
    candidates[_candidateId].voteCount ++;
  }

  function getTitle() public view returns (string) {
    return string(title);
  }
  function getOwner() public view returns (string) {
    return Type.bytes32ToStr(owner);
  }
  // Candidate
  function getCandidateName(uint i) public view returns (string) {
    return candidates[i].name;
  }
  function getCandidateVoteCount(uint i) public view returns (uint) {
    return candidates[i].voteCount;
  }
  function close(bytes32 _email) public {
    require(ownerId[_email] != 0);

    // Is manual mode and not closed
    if (manual) {
      require(status == Status.Start);
      status = Status.Closed;
    }

    endDate = now;
  }

  function start(bytes32 _email) public {
    require(ownerId[_email] != 0);

    if (manual) {
      require(status == Status.Pending);
      status = Status.Start;
    }

    startDate = now;
  }
  function getStartDate() public view returns (uint) {
    return startDate;
  }
  function getEndDate() public view returns (uint) {
    return endDate;
  }

  function getStatus() public view returns (uint) {
    require (manual);
    return uint(status);
  }
  function isManual() public view returns (bool) {
    return manual;
  }
  function getMode() public view returns (uint) {
    return uint(mode);
  }
}
