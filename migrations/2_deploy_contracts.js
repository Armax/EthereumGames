var PokemonSpawner = artifacts.require ("./PokemonSpawner.sol");

module.exports = function(deployer) {
    deployer.deploy(PokemonSpawner);
}