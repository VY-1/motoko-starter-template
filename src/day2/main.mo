import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Nat "mo:base/Nat";
import Text "mo:base/Text";

import Type "Types";

actor class Homework() {
  public type Homework = Type.Homework;

  let homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared func addHomework(homework : Homework) : async Nat {
    let index = homeworkDiary.size();
    homeworkDiary.add(homework);
    return index;
  };

  // Get a specific homework task by id
  public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
    switch(homeworkDiary.getOpt(id)){
      case(null){
        return #err("Homework not found with id: " # Nat.toText(id));
      };
      case(?homework){
        return #ok(homework);
      };
    };
    
  };

  // Update a homework task's title, description, and/or due date
  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
    let homeworkToUpdate = homeworkDiary.getOpt(id);
    switch(homeworkToUpdate){
      case(null){
        return #err("Homework not found with id: " # Nat.toText(id));
      };
      case(?homework){
        homeworkDiary.put(id, homework);
        return #ok();
      };
    };
    
  };

  // Mark a homework task as completed
  public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
    let homeworkOpt : ?Homework = homeworkDiary.getOpt(id);
    switch(homeworkOpt){
      case(null){
        return #err("Homework not found with the provided id: " # Nat.toText(id));
      };
      case(?homework){
        //create new homework object
        let newHomework = {
          title = homework.title;
          description = homework.description;
          dueDate = homework.dueDate;
          completed = true;
        };
        homeworkDiary.put(id, newHomework); //put newHomework at the index id
        return #ok();
      };
    };
    
  };

  // Delete a homework task by id
  public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
    let homeworkToDelete = homeworkDiary.getOpt(id);
    switch(homeworkToDelete){
      case(null){
        return #err("Homework with id: " # Nat.toText(id) # " not found");
      };
      case(homework){
        ignore homeworkDiary.remove(id);
        return #ok();
      };
    };
   
  };

  // Get the list of all homework tasks
  public shared query func getAllHomework() : async [Homework] {
    return Buffer.toArray(homeworkDiary);
  };

  // Get the list of pending (not completed) homework tasks
  public shared query func getPendingHomework() : async [Homework] {
    let incompleteHomeworks = Buffer.Buffer<Homework>(0);
    for(homework in homeworkDiary.vals()){
      if(not homework.completed){
        incompleteHomeworks.add(homework);
      };
    };

    return Buffer.toArray(incompleteHomeworks);
  };

  // Search for homework tasks based on a search terms
  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
    let searchedHomeworks = Buffer.Buffer<Homework>(0);
    for(homework in homeworkDiary.vals()){
      if(homework.title == searchTerm){
        searchedHomeworks.add(homework);
      };
      
    };
    return Buffer.toArray(searchedHomeworks);
  };
};
