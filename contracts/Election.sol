pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import './Library.sol';

contract Election {
  mapping(bytes32 => uint) public ownerId;
  bytes32 private owner;
  bytes32 private title;
  bytes private imgURL;
  bytes32 private description;
  uint private startDate;
  uint private endDate;
  uint public candSize;
  uint public votrSize;
  Mode private mode;

  enum Mode { Private, Public }

  mapping(uint => Candidate) private candidates;
  mapping(bytes32 => Voter) private voters;
  mapping(bytes32 => uint) private voterId;
  mapping(uint => bytes32) private voterEmails;
  mapping(bytes32 => uint) private votedTo;
  mapping(bytes32 => uint) private pubVoterId;

  struct Candidate {
    uint id;
    string name;
    string imgURL;
    string description;
    uint voteCount;
  }

  struct Voter {
    uint id;
    string email;
    bool voted;
  }

  // Constructor that used to create Election object.
  constructor (
    bytes32[3] _content, bytes _imgURL, bool[2] _setup,
    bytes32[] _candidates,
    string[] _cImg,
    bytes32[] _candidatesDescription,
    bytes32[] _voters, uint[2] _start_end
  ) public {
    ownerId[_content[0]] = 1;   // Mark the organizer's email with 1, used for verification
    owner = _content[0];        // Set the organizer's email
    title = _content[1];        // Set the poll's title
    imgURL = _imgURL;           // Set the poll's image URL
    description = _content[2];  // Set the poll's description
    startDate = _start_end[0];  // Set the poll's start date
    // End date mode: Custom
    if (!_setup[0]) {
      endDate = _start_end[1];  // Set the poll's end date
    }
    // Add candidates
    addCandidates(_candidates, _cImg, _candidatesDescription);

    // Vote mode: Private
    if (!_setup[1]) {
      mode = Mode.Private;      // Set private mode
      addVoters(_voters);       // Add voters
    } else {
      // Vote mode: Public
      mode = Mode.Public;       // Set public mode
    }
  }

  // Add candidates
  function addCandidates(bytes32[] _names,
                         string[] _img,
                         bytes32[] _description) private {
    candSize = _names.length; // Set the candidate's size from the array of candidates' length

    // To store the candidates into the array of candidates.
    for (uint i = 0; i < candSize; i++) {
      // Assign the created Candidate object.
      candidates[i] = Candidate(
        i,
        Library.bytes32ToStr(_names[i]),
        _img[i],
        Library.bytes32ToStr(_description[i]),
        0);
    }
  }

  // Add voters
  function addVoters(bytes32[] _emails) private {
    votrSize = _emails.length; // Set the coter's size from the array of voters' length

    // To store the voters into the array of voters.
    for (uint i = 0; i < votrSize; i++) {
      voterId[_emails[i]] = i + 1;
      voterEmails[i] = _emails[i];
      voters[_emails[i]] = Voter(i, Library.bytes32ToStr(_emails[i]), false);
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
  function getVoterEmail(uint i) public view returns (string) {
    return Library.bytes32ToStr(voterEmails[i]);
  }
  /*
   * The logic for the vote process.
   * _email: voter's email.
   * _candidateId: candidate's ID.
   */
  function vote (bytes32 _email, uint _candidateId) public {
    // Vote mode: Private
    if (mode == Mode.Private) {
      // require the user's email is invited
      require(voterId[_email] != 0);
    } else {
      // Vote mode: Public
      // If the user's email is not registered
      if (voterId[_email] == 0) {
        // To store the voter's ID, set the key with the voter's email.
        voterId[_email] = votrSize;
        // To store the voter's email, indexing with the latest voter's size.
        voterEmails[votrSize] = _email;
        // Assign the created voter object to the array of voters
        voters[_email] = Voter(votrSize, Library.bytes32ToStr(_email), false);
        // Increment voter's size
        votrSize++;
      }
    }

    // End date mode: Custom
    if (endDate != 0) {
      // require the current date is not more than or equal to the end date
      require(now < endDate);
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
    return Library.bytes32ToStr(title);
  }
  function getImgURL() public view returns (string) {
    return string(imgURL);
  }
  function getDescription() public view returns (string) {
    return Library.bytes32ToStr(description);
  }
  function getOwner() public view returns (string) {
    return Library.bytes32ToStr(owner);
  }
  // Candidate
  function getCandidateName(uint i) public view returns (string) {
    return candidates[i].name;
  }
  function getCandidateImgURL(uint i) public view returns (string) {
    return string(candidates[i].imgURL);
  }
  function getCandidateDescription(uint i) public view returns (string) {
    return candidates[i].description;
  }
  function getCandidateVoteCount(uint i) public view returns (uint) {
    return candidates[i].voteCount;
  }
  function close(bytes32 _email) public {
    // require the owner is matched the organizer's email
    require(ownerId[_email] != 0);

    // require the end mode is 'Manually'
    require(endDate == 0);

    // update the end date to the current date
    endDate = now;
  }

  function getStartDate() public view returns (uint) {
    return startDate;
  }
  function getEndDate() public view returns (uint) {
    return endDate;
  }
  function getMode() public view returns (uint) {
    return uint(mode);
  }
}
