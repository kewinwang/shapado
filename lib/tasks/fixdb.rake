
desc "Fix all"
task :fixall => [:environment, "fixdb:openid", "fixdb:votes", "fixdb:sync_counts"] do
end

namespace :fixdb do
  task :openid => [:environment] do
    User.find_each do |user|
      next if user.identity_url.blank?

      puts "Updating: #{user.login}"
      user.push_uniq(:auth_keys => "open_id_#{user[:identity_url]}")
      user.unset(:identity_url => 1)
    end
  end

  task :sync_counts => [:environment] do
    Comment.find_each do |c|
      votes_average=0
      c.votes.each {|e| votes_average+=e.value }
      c.set("votes_count" => c.votes.size, "votes_average" => votes_average)
      if c.respond_to?(:flags)
        c.set("flags_count" => c.flags.size)
      end
    end

    Question.find_each do |q|
      votes_average=0
      q.votes.each {|e| votes_average+=e.value }
      q.set("flags_count" => q.flags.size, "votes_count" => q.votes.size, "votes_average" => votes_average)
    end
  end

  task :votes => [:environment] do
    Group.find_each do |group|
      count = 0

      comments = MongoMapper.database.collection("comments")
      questions = MongoMapper.database.collection("questions")
      MongoMapper.database.collection("votes").find({:group_id => group["_id"]}).each do |vote|
        vote.delete("group_id")
        id = vote.delete("voteable_id")
        klass = vote.delete("voteable_type")
        collection = comments
        if klass == "Question"
          collection = questions;
        end
        count += 1
        collection.update({:_id => id}, "$addToSet" => {:votes => vote})
      end
      if count > 0
        puts "Updated #{count} #{group["name"]} votes "
      end
    end
    MongoMapper.database.collection("votes").drop
  end
end

