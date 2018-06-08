# Makes "git log --graph --all --simplify-by-decoration" much more useful.
# Creates a handful of branches named "merge-base-tmp1" (etc) at the merge-base for existing branches.
# This ensures that the git log command (above) shows the full branch structure between all existing branches
# This is helpful to run after "git remote prune origin".


require 'set'

branches = `git branch --all`

# Convert from one big string into lines
branches = branches.split("\n")

# Remove the "* " and "  remotes/" from the beginning of branch names.
# Cleans them into a format we can insert into "git log"
branches = branches.map {|e| e.gsub(/[* ]+(?:remotes\/)?/, '') }

# Remove the branch "origin/HEAD->..."
branches = branches.reject {|e| e.start_with?('origin/HEAD') }


# Remove all the old "merge-base-tmpX" branches
branches_to_delete = branches.select {|e| e.start_with?('merge-base-tmp') }
branches_to_delete.each do |branch_to_delete|
	puts `git branch -D #{branch_to_delete}`
end

branches = branches - branches_to_delete



# Gather all combinations of branches
branch_combs = branches.combination(2).to_a

# Gather the merge-bases of the combinations
mergebases = Set.new
branch_combs.each do |branch_pair|
	command = "git merge-base #{branch_pair[0]} #{branch_pair[1]}"
	puts command
	
	mergebase = `#{command}`
	mergebase = mergebase.strip
	mergebases.add(mergebase)
end


# Don't create a "merge-base-tmpX" branch if another branch already exists at that commit

# Find all the commit hashes for existing branches
existing_branch_hashes = `git show-ref -s`
existing_branch_hashes = existing_branch_hashes.split("\n")

# Removing existing branches from "mergebases"
mergebases = mergebases - existing_branch_hashes



# Generate branches at all the merge-bases
i = 1
mergebases.to_a.each do |merge_base|
	command = "git branch merge-base-tmp#{i.to_s} #{merge_base}"
	puts command
	`#{command}`
	i = i + 1
end

