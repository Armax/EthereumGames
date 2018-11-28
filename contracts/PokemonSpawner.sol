pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

import "./safemath.sol";
import "./ownable.sol";

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
}

contract ContractName {
    
}


contract PokemonSpawner is Ownable, ERC721 {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    Pokemon[] public pokemons;
    mapping (uint => address) public pokemonOwner;
    mapping (address => uint) userPokemonCount;
    mapping (uint => address) Approvals;

    event NewPokemon(uint pokemonId, string name, uint dna);

    struct Pokemon {
        string name;
        uint dna;
        uint32 level;
    }

    function getPokemon(uint index) external view returns(Pokemon memory) {
        return pokemons[index];
    }

    function _addPokemon(string memory _name, uint _dna) internal {
        uint id = pokemons.push(Pokemon(_name, _dna, 1)) - 1;
        pokemonOwner[id] = msg.sender;
        userPokemonCount[msg.sender] = userPokemonCount[msg.sender].add(1);
        emit NewPokemon(id, _name, _dna);
    }

    function _generateDna(string memory _str) private view returns (uint) {
        uint rngDna = uint(keccak256(abi.encodePacked(_str)));
        uint rngPokemon = uint(keccak256(abi.encodePacked(now, msg.sender))) % 150;
        uint dna = (rngDna % (10 ** 10));
        dna = dna - dna % 1000 + rngPokemon;
        return dna;
    }

    function getStarter(string memory _name) public {
        require(userPokemonCount[msg.sender] == 0);
        uint randomDna = _generateDna(_name);
        _addPokemon(_name, randomDna);
    }

    function getUserPokemons(address _user) external view returns(uint[] memory) {
        uint[] memory result = new uint[](userPokemonCount[_user]);
        uint counter = 0;
        for (uint i = 0; i < pokemons.length; i++) {
            if (pokemonOwner[i] == _user) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return userPokemonCount[_owner];
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return pokemonOwner[_tokenId];
    }

    function _transfer(address _from, address _to, uint256 _tokenId) private {
        userPokemonCount[_to] = userPokemonCount[_to].add(1);
        userPokemonCount[msg.sender] = userPokemonCount[msg.sender].sub(1);
        pokemonOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require (pokemonOwner[_tokenId] == msg.sender || Approvals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) external {
        require (pokemonOwner[_tokenId] == msg.sender);
        _transfer(msg.sender, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) external payable {
        require(msg.sender == pokemonOwner[_tokenId]);
        Approvals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}
