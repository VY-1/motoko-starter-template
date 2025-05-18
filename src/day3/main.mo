import Type "Types";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Order "mo:base/Order";


actor class StudentWall() {
  type Message = Type.Message;
  type Content = Type.Content;
  type Survey = Type.Survey;
  type Answer = Type.Answer;

  let messages = HashMap.HashMap<Nat, Message>(0, Nat.equal, Hash.hash);

  // Add a new message to the wall
  public shared ({ caller }) func writeMessage(c : Content) : async Nat {
    let index = messages.size();
    let message = {
      content = c;
      vote = 0;
      creator = caller;
    };
    messages.put(index, message);
    
    return index;
  };

  // Get a specific message by ID
  public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
    switch(messages.get(messageId)){
      case(null){
        return #err("Message not found id: " # Nat.toText(messageId));
      };
      case(?message){
        return #ok(message);
      };
    };
  };

  // Update the content for a specific message by ID
  public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
    switch(messages.get(messageId)){
      case(null){
        return #err("Message not found id: " # Nat.toText(messageId));
      };
      case(?message){
        let newMessage = {
          content = c;
          vote = message.vote;
          creator = caller;
        };
        messages.put(messageId, newMessage);
        return #ok();
      };
    };
  };

  // Delete a specific message by ID
  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    switch(messages.get(messageId)){
      case(null){
        return #err("Message not found id: " # Nat.toText(messageId));
      };
      case(?message){
        ignore messages.remove(messageId);
        return #ok();
      };
    };
    
  };

  // Voting
  public func upVote(messageId : Nat) : async Result.Result<(), Text> {
    switch(messages.get(messageId)){
      case(null){
        return #err("Message not found id: " # Nat.toText(messageId));
      };
      case(?message){
        let newMessage = {
          content = message.content;
          vote = message.vote + 1;
          creator = message.creator;
        };
        messages.put(messageId, newMessage);
        return #ok();
      };
    };
  };

  public func downVote(messageId : Nat) : async Result.Result<(), Text> {
    switch(messages.get(messageId)){
      case(null){
        return #err("Message not found id: " # Nat.toText(messageId));
      };
      case(?message){
        let newMessage = {
          content = message.content;
          vote = message.vote - 1;
          creator = message.creator;
        };
        messages.put(messageId, newMessage);
        return #ok();
      };
    };
  };

  // Get all messages
  public func getAllMessages() : async [Message] {
    let array : [Message] = Iter.toArray(messages.vals());
    return array;
  };
  
  type Order = Order.Order;
  func compareMessage(m1: Message, m2: Message): Order{
    if(m1.vote == m2.vote){
      return #equal;
    }
    else if(m1.vote > m2.vote){
      return #less;
    }
    else{
      return #greater;
    };
    
  };
  //Get all messages ordered by votes
  public func getAllMessagesRanked() : async [Message] {
    let array = Iter.toArray(messages.vals());
    return Array.sort<Message>(array, compareMessage);
  };
};
