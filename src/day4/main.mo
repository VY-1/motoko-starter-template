import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";

import Account "Account";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";

actor class MotoCoin() {
  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);
  public type Account = Account.Account;


  // Returns the name of the token
  public query func name() : async Text {
    return "MotoCoin";
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    return "MOC";
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    var balance = 0;
    for((account, value) in ledger.entries()){
      balance += value;
    };
    return balance;
    
  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    switch(ledger.get(account)){
      case(null){
        return 0;
      };
      case(?balance){
        return balance;
      };
    };
  };

  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {


    return #ok;
  };

  let bootcampCanister: actor{
    getAllStudentsPrincipal: shared() -> async [Principal];
  } = actor("rww3b-zqaaa-aaaam-abioa-cai");

  public func showStudents(): async [Principal]{
    
    return await bootcampCanister.getAllStudentsPrincipal();
  };

  // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
    try{
      let students = await bootcampCanister.getAllStudentsPrincipal();
      for(p in students.vals()){
        let account :Account = {
          owner = p;
          subaccount = null;
        };
        let currentValue = Option.get(ledger.get(account), 0);
        let newValue = currentValue + 100;
        ledger.put(account, newValue);
      };
      return #ok();

    }catch(e){
      return #err("Something went wrong when call the bootcamp canister");
    };
  };
  
};
