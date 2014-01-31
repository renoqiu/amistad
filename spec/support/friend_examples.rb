shared_examples_for "a friend model" do
  context "when creating friendships" do
    it "should invite other users to friends" do
      @john.friendship_invite(@jane).should be_true
      @victoria.friendship_invite(@john).should be_true
    end

    it "should approve only friendships requested by other users" do
      @john.friendship_invite(@jane).should be_true
      @jane.approve(@john).should be_true
      @victoria.friendship_invite(@john).should be_true
      @john.approve(@victoria).should be_true
    end

    it "should not invite an already invited user" do
      @john.friendship_invite(@jane).should be_true
      @john.friendship_invite(@jane).should be_false
      @jane.friendship_invite(@john).should be_false
    end

    it "should not invite an already approved user" do
      @john.friendship_invite(@jane).should be_true
      @jane.approve(@john).should be_true
      @jane.friendship_invite(@john).should be_false
      @john.friendship_invite(@jane).should be_false
    end

    it "should not invite an already blocked user" do
      @john.friendship_invite(@jane).should be_true
      @jane.block(@john).should be_true
      @jane.friendship_invite(@john).should be_false
      @john.friendship_invite(@jane).should be_false
    end

    it "should not approve a self requested friendship" do
      @john.friendship_invite(@jane).should be_true
      @john.approve(@jane).should be_false
      @victoria.friendship_invite(@john).should be_true
      @victoria.approve(@john).should be_false
    end

    it "should not create a friendship with himself" do
      @john.friendship_invite(@john).should be_false
    end

    it "should not approve a non-existent friendship" do
      @peter.approve(@john).should be_false
    end
  end

  context "when listing friendships" do
    before(:each) do
      @john.friendship_invite(@jane).should be_true
      @peter.friendship_invite(@john).should be_true
      @john.friendship_invite(@james).should be_true
      @james.approve(@john).should be_true
      @mary.friendship_invite(@john).should be_true
      @john.approve(@mary).should be_true
    end

    it "should list all the friends" do
      @john.friends.should =~ [@mary, @james]
    end

    it "should not list non-friended users" do
      @victoria.friends.should be_empty
      @john.friends.should =~ [@mary, @james]
      @john.friends.should_not include(@peter)
      @john.friends.should_not include(@victoria)
    end

    it "should list the friends who invited him" do
      @john.friendship_invited_by.should == [@mary]
    end

    it "should list the friends who were invited by him" do
      @john.friendship_invited.should == [@james]
    end

    it "should list the pending friends who invited him" do
      @john.pending_friendship_invited_by.should == [@peter]
    end

    it "should list the pending friends who were invited by him" do
      @john.pending_friendship_invited.should == [@jane]
    end

    it "should list the friends he has in common with another user" do
      @james.common_friends_with(@mary).should == [@john]
    end

    it "should not list the friends he does not have in common" do
      @john.common_friends_with(@mary).count.should == 0
      @john.common_friends_with(@mary).should_not include(@james)
      @john.common_friends_with(@peter).count.should == 0
      @john.common_friends_with(@peter).should_not include(@jane)
    end

    it "should check if a user is a friend" do
      @john.friend_with?(@mary).should be_true
      @mary.friend_with?(@john).should be_true
      @john.friend_with?(@james).should be_true
      @james.friend_with?(@john).should be_true
    end

    it "should check if a user is not a friend" do
      @john.friend_with?(@jane).should be_false
      @jane.friend_with?(@john).should be_false
      @john.friend_with?(@peter).should be_false
      @peter.friend_with?(@john).should be_false
    end

    it "should check if a user has any connections with another user" do
      @john.connected_with?(@jane).should be_true
      @jane.connected_with?(@john).should be_true
      @john.connected_with?(@peter).should be_true
      @peter.connected_with?(@john).should be_true
    end

    it "should check if a user does not have any connections with another user" do
      @victoria.connected_with?(@john).should be_false
      @john.connected_with?(@victoria).should be_false
    end

    it "should check if a user was invited by another" do
      @jane.friendship_invited_by?(@john).should be_true
      @james.friendship_invited_by?(@john).should be_true
    end

    it "should check if a user was not invited by another" do
      @john.friendship_invited_by?(@jane).should be_false
      @victoria.friendship_invited_by?(@john).should be_false
    end

    it "should check if a user has invited another user" do
      @john.friendship_invited?(@jane).should be_true
      @john.friendship_invited?(@james).should be_true
    end

    it "should check if a user did not invite another user" do
      @jane.friendship_invited?(@john).should be_false
      @james.friendship_invited?(@john).should be_false
      @john.friendship_invited?(@victoria).should be_false
      @victoria.friendship_invited?(@john).should be_false
    end
  end

  context "when removing friendships" do
    before(:each) do
      @jane.friendship_invite(@james).should be_true
      @james.approve(@jane).should be_true
      @james.friendship_invite(@victoria).should be_true
      @victoria.approve(@james).should be_true
      @victoria.friendship_invite(@mary).should be_true
      @mary.approve(@victoria).should be_true
      @victoria.friendship_invite(@john).should be_true
      @john.approve(@victoria).should be_true
      @peter.friendship_invite(@victoria).should be_true
      @victoria.friendship_invite(@elisabeth).should be_true
    end

    it "should remove the friends invited by him" do
      @victoria.friends.size.should == 3
      @victoria.friends.should include(@mary)
      @victoria.friendship_invited.should include(@mary)
      @mary.friends.size.should == 1
      @mary.friends.should include(@victoria)
      @mary.friendship_invited_by.should include(@victoria)

      @victoria.remove_friendship(@mary).should be_true
      @victoria.friends.size.should == 2
      @victoria.friends.should_not include(@mary)
      @victoria.friendship_invited.should_not include(@mary)
      @mary.friends.size.should == 0
      @mary.friends.should_not include(@victoria)
      @mary.friendship_invited_by.should_not include(@victoria)
    end

    it "should remove the friends who invited him" do
      @victoria.friends.size.should == 3
      @victoria.friends.should include(@james)
      @victoria.friendship_invited_by.should include(@james)
      @james.friends.size.should == 2
      @james.friends.should include(@victoria)
      @james.friendship_invited.should include(@victoria)

      @victoria.remove_friendship(@james).should be_true
      @victoria.friends.size.should == 2
      @victoria.friends.should_not include(@james)
      @victoria.friendship_invited_by.should_not include(@james)
      @james.friends.size.should == 1
      @james.friends.should_not include(@victoria)
      @james.friendship_invited.should_not include(@victoria)
    end

    it "should remove the pending friends invited by him" do
      @victoria.pending_friendship_invited.size.should == 1
      @victoria.pending_friendship_invited.should include(@elisabeth)
      @elisabeth.pending_friendship_invited_by.size.should == 1
      @elisabeth.pending_friendship_invited_by.should include(@victoria)
      @victoria.remove_friendship(@elisabeth).should be_true
      [@victoria, @elisabeth].map(&:reload)
      @victoria.pending_friendship_invited.size.should == 0
      @victoria.pending_friendship_invited.should_not include(@elisabeth)
      @elisabeth.pending_friendship_invited_by.size.should == 0
      @elisabeth.pending_friendship_invited_by.should_not include(@victoria)
    end

    it "should remove the pending friends who invited him" do
      @victoria.pending_friendship_invited_by.count.should == 1
      @victoria.pending_friendship_invited_by.should include(@peter)
      @peter.pending_friendship_invited.count.should == 1
      @peter.pending_friendship_invited.should include(@victoria)
      @victoria.remove_friendship(@peter).should be_true
      [@victoria, @peter].map(&:reload)
      @victoria.pending_friendship_invited_by.count.should == 0
      @victoria.pending_friendship_invited_by.should_not include(@peter)
      @peter.pending_friendship_invited.count.should == 0
      @peter.pending_friendship_invited.should_not include(@victoria)
    end
  end

  context "when blocking friendships" do
    before(:each) do
      @john.friendship_invite(@james).should be_true
      @james.approve(@john).should be_true
      @james.block(@john).should be_true
      @mary.friendship_invite(@victoria).should be_true
      @victoria.approve(@mary).should be_true
      @victoria.block(@mary).should be_true
      @victoria.friendship_invite(@david).should be_true
      @david.block(@victoria).should be_true
      @john.friendship_invite(@david).should be_true
      @david.block(@john).should be_true
      @peter.friendship_invite(@elisabeth).should be_true
      @elisabeth.block(@peter).should be_true
      @jane.friendship_invite(@john).should be_true
      @jane.friendship_invite(@james).should be_true
      @james.approve(@jane).should be_true
      @victoria.friendship_invite(@jane).should be_true
      @victoria.friendship_invite(@james).should be_true
      @james.approve(@victoria).should be_true
    end

    it "should allow to block author of the invitation by invited user" do
      @john.block(@jane).should be_true
      @jane.block(@victoria).should be_true
    end

    it "should not allow to block invited user by invitation author" do
      @jane.block(@john).should be_false
      @victoria.block(@jane).should be_false
    end

    it "should allow to block approved users on both sides" do
      @james.block(@jane).should be_true
      @victoria.block(@james).should be_true
    end

    it "should not allow to block not connected user" do
      @david.block(@peter).should be_false
      @peter.block(@david).should be_false
    end

    it "should not allow to block already blocked user" do
      @john.block(@jane).should be_true
      @john.block(@jane).should be_false
      @james.block(@jane).should be_true
      @james.block(@jane).should be_false
    end

    it "should list the blocked users" do
      @jane.blocked.should be_empty
      @peter.blocked.should be_empty
      @james.blocked.should == [@john]
      @victoria.blocked.should == [@mary]
      @david.blocked.should =~ [@john, @victoria]
    end

    it "should not list blocked users in friends" do
      @james.friends.should =~ [@jane, @victoria]
      @james.blocked.each do |user|
        @james.friends.should_not include(user)
        user.friends.should_not include(@james)
      end
    end

    it "should not list blocked users in invited" do
      @victoria.friendship_invited.should == [@james]
      @victoria.blocked.each do |user|
        @victoria.friendship_invited.should_not include(user)
        user.friendship_invited_by.should_not include(@victoria)
      end
    end

    it "should not list blocked users in invited pending by" do
      @david.pending_friendship_invited_by.should be_empty
      @david.blocked.each do |user|
        @david.pending_friendship_invited_by.should_not include(user)
        user.pending_friendship_invited.should_not include(@david)
      end
    end

    it "should check if a user is blocked" do
      @james.blocked?(@john).should be_true
      @victoria.blocked?(@mary).should be_true
      @david.blocked?(@john).should be_true
      @david.blocked?(@victoria).should be_true
    end
  end

  context "when unblocking friendships" do
    before(:each) do
      @john.friendship_invite(@james).should be_true
      @james.approve(@john).should be_true
      @john.block(@james).should be_true
      @john.unblock(@james).should be_true
      @mary.friendship_invite(@victoria).should be_true
      @victoria.approve(@mary).should be_true
      @victoria.block(@mary).should be_true
      @victoria.unblock(@mary).should be_true
      @victoria.friendship_invite(@david).should be_true
      @david.block(@victoria).should be_true
      @david.unblock(@victoria).should be_true
      @john.friendship_invite(@david).should be_true
      @david.block(@john).should be_true
      @peter.friendship_invite(@elisabeth).should be_true
      @elisabeth.block(@peter).should be_true
      @jane.friendship_invite(@john).should be_true
      @jane.friendship_invite(@james).should be_true
      @james.approve(@jane).should be_true
      @victoria.friendship_invite(@jane).should be_true
      @victoria.friendship_invite(@james).should be_true
      @james.approve(@victoria).should be_true
    end

    it "should allow to unblock prevoiusly blocked user" do
      @david.unblock(@john).should be_true
      @elisabeth.unblock(@peter).should be_true
    end

    it "should not allow to unblock not prevoiusly blocked user" do
      @john.unblock(@jane).should be_false
      @james.unblock(@jane).should be_false
      @victoria.unblock(@jane).should be_false
      @james.unblock(@victoria).should be_false
    end

    it "should not allow to unblock blocked user by himself" do
      @john.unblock(@david).should be_false
      @peter.unblock(@elisabeth).should be_false
    end

    it "should list unblocked users in friends" do
      @john.friends.should == [@james]
      @mary.friends.should == [@victoria]
      @victoria.friends.should =~ [@mary, @james]
      @james.friends.should =~ [@john, @jane, @victoria]
    end

    it "should list unblocked users in invited" do
      @john.friendship_invited.should == [@james]
      @mary.friendship_invited.should == [@victoria]
    end

    it "should list unblocked users in invited by" do
      @victoria.friendship_invited_by.should == [@mary]
      @james.friendship_invited_by.should =~ [@john, @jane, @victoria]
    end

    it "should list unblocked users in pending invited" do
      @victoria.pending_friendship_invited.should =~ [@jane, @david]
    end

    it "should list unblocked users in pending invited by" do
      @david.pending_friendship_invited_by.should == [@victoria]
    end
  end

  context "when counting friendships and blocks" do
    before do
      @john.friendship_invite(@james).should be_true
      @james.approve(@john).should be_true
      @john.friendship_invite(@victoria).should be_true
      @victoria.approve(@john).should be_true
      @elisabeth.friendship_invite(@john).should be_true
      @john.approve(@elisabeth).should be_true

      @victoria.friendship_invite(@david).should be_true
      @david.block(@victoria).should be_true
      @mary.friendship_invite(@victoria).should be_true
      @victoria.block(@mary).should be_true
    end

    it "should return the correct count for total_friends" do
      @john.total_friends.should == 3
      @elisabeth.total_friends.should == 1
      @james.total_friends.should == 1
      @victoria.total_friends.should == 1
    end

    it "should return the correct count for total_blocked" do
      @david.total_blocked.should == 1
      @victoria.total_blocked.should == 1
    end
  end
end
